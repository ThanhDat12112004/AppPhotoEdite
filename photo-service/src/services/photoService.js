const multer = require('multer');
const path = require('path');
const fs = require('fs');
const axios = require('axios');
const Photo = require('../models/photoModel');
const faceapi = require('../lib/faceapi_models/face-api.js');
const { Canvas, Image } = require('canvas');
const sharp = require('sharp');
const { exec } = require("child_process");
const { removeBackground } = require('@imgly/background-removal-node');
const ort = require('onnxruntime-node');
const FormData = require('form-data');

faceapi.env.monkeyPatch({ Canvas, Image });

const channels = 3;
const MAX_DIMENSION = 1024;

// Cấu hình multer để lưu file tạm thời
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        const tempDir = path.join(__dirname, '../temp');
        if (!fs.existsSync(tempDir)) {
            fs.mkdirSync(tempDir, { recursive: true });
        }
        cb(null, tempDir);
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, `${uniqueSuffix}.PNG`);
    }
});

const uploadMulter = multer({ storage });

async function loadModels() {
    const MODEL_PATH = path.join(__dirname, '../lib/faceapi_models');
    try {
        await faceapi.nets.ssdMobilenetv1.loadFromDisk(MODEL_PATH);
        await faceapi.nets.faceLandmark68Net.loadFromDisk(MODEL_PATH);
        await faceapi.nets.faceExpressionNet.loadFromDisk(MODEL_PATH);
    } catch (error) {
        throw new Error('Không thể tải mô hình nhận diện khuôn mặt!');
    }
}

const getPhotos = async(userId) => {
    try {
        const photos = await Photo.find({ userId: userId })
            .select('_id imagePath createdAt updatedAt')
            .sort({ createdAt: -1 });
            return photos;
    } catch (error) {
        throw new Error(`Lỗi khi lấy danh sách ảnh: ${error.message}`);
    }
};

const getPhoto = async(photoId, userId) => {
    try {
        const photo = await Photo.findOne({ _id: photoId, userId: userId });
        if (!photo) throw new Error('Không tìm thấy ảnh hoặc bạn không có quyền truy cập!');
        return photo;
    } catch (error) {
        throw new Error(`Lỗi khi lấy thông tin ảnh: ${error.message}`);
    }
};

const uploadPhoto = async(userId, file) => {
    try {
        const tempPath = file.path;
        const newPhoto = new Photo({
            userId: userId,
            imagePath: tempPath, // Lưu tạm thời đường dẫn trên disk
        });
        await newPhoto.save();
        // Gọi API của cdn-service để lưu file vào thư mục uploads/<userId>
        const formData = new FormData();
        formData.append('photoId', newPhoto._id.toString());
        formData.append('userId', userId.toString()); // Chuyển userId thành string
        formData.append('file', fs.createReadStream(tempPath));
     
        const response = await axios.post(`${process.env.CDN_SERVICE_URL}/upload`, formData).catch((error) => {throw error;});
       
        // Cập nhật imagePath với đường dẫn từ cdn-service
        newPhoto.imagePath = response.data.imagePath;
        await newPhoto.save();

        return newPhoto;
        // Xóa file tạm trên disk của photo-processing-service
        fs.unlinkSync(tempPath);
    } catch {
        fs.unlinkSync(tempPath);
    }
};

const updatePhoto = async(photoId, userId, file) => {
    try {
        const tempPath = file.path;
        const photo = await Photo.findOne({ _id: photoId, userId: userId });
        if (!photo) throw new Error('Không tìm thấy ảnh hoặc bạn không có quyền truy cập!');

        // Gọi API của cdn-service để lưu file mới
        const formData = new FormData();
        formData.append('photoId', photo._id.toString());
        formData.append('userId', userId.toString()); 
        formData.append('file', fs.createReadStream(tempPath));
        formData.append('originalName', file.originalname);

        const response = await axios.post(`${process.env.CDN_SERVICE_URL}/update`, formData).catch(() => {})

        // Cập nhật imagePath với đường dẫn mới
        photo.imagePath = response.data.imagePath;
        await photo.save();

        // Xóa file tạm trên disk của photo-processing-service
        fs.unlinkSync(tempPath);

        return photo;
    } catch (error) {;
    }
};

const deletePhoto = async(photoId, userId) => {
    try {        const response = await axios.post(`${process.env.CDN_SERVICE_URL}/delete`, { photoId }).catch((error) => {
            throw error;
        });
        const photo = await Photo.findOneAndDelete({ _id: photoId, userId: userId });
        if (!photo) throw new Error('Không tìm thấy ảnh hoặc bạn không có quyền truy cập!');
        return { message: 'Xóa ảnh thành công!' };
    } catch (error) {
        throw new Error(`Lỗi khi xóa ảnh: ${error.message}`);
    }
};

const removeBackgroundService = async (userId, imagePath) => {
    try {
        if (!imagePath || typeof imagePath !== 'string') {
            throw new Error('URL ảnh không hợp lệ!');
        }

        if (!userId) {
            throw new Error('Thiếu userId!');
        }

        // Tải ảnh gốc từ CDN   
        const response = await axios.get(`${process.env.CDN_SERVICE_URL}${imagePath}`, { responseType: 'arraybuffer' });
    
        const imageBuffer = Buffer.from(response.data);

        // Xóa nền ảnh
        const blob = new Blob([imageBuffer], { type: 'image/png' });
    
        const resultBlob = await removeBackground(blob, {
            model: 'medium',
            output: { format: 'image/png' },
        });

        const processedBuffer = Buffer.from(await resultBlob.arrayBuffer());

        // Tạo file object giả để tương thích với uploadPhoto
        const tempDir = path.join(__dirname, '../temp');
        if (!fs.existsSync(tempDir)) {
            fs.mkdirSync(tempDir, { recursive: true });
        }
        const tempFileName = `${Date.now()}.png`;
        const tempPath = path.join(tempDir, tempFileName);
        fs.writeFileSync(tempPath, processedBuffer);

        const file = {
            path: tempPath,
            originalname: tempFileName
        };

        // Sử dụng uploadPhoto để xử lý upload
        const uploadResult = await uploadPhoto(userId, file);

        // File tạm sẽ được xóa trong uploadPhoto, không cần xóa ở đây nữa

        return {
            _id: uploadResult._id,
            imagePath: uploadResult.imagePath,
            message: 'Xóa nền ảnh thành công!'
        };
    } catch (error) {
        // Xóa file tạm nếu có lỗi
        const tempPath = path.join(__dirname, '../temp', `${Date.now()}-${Math.round(Math.random() * 1E9)}.png`);
        if (fs.existsSync(tempPath)) {
            fs.unlinkSync(tempPath);
        }
        return message = `Lỗi khi xóa nền ảnh: ${error.message}`;
    }
};

const extractHeadAndRemoveBackground = async (userId, imagePath) => {
    try {
        if (!imagePath || typeof imagePath !== 'string') {
            throw new Error('URL ảnh không hợp lệ!');
        }

        if (!userId) {
            throw new Error('Thiếu userId!');
        }

        // Tải ảnh từ CDN
        const response = await axios.get(`${process.env.CDN_SERVICE_URL}${imagePath}`, { responseType: 'arraybuffer' });
        const imageBuffer = Buffer.from(response.data);

        // Tạo canvas để phát hiện khuôn mặt
        const img = new Image();
        img.src = imageBuffer;
        const canvas = new Canvas(img.width, img.height);
        const ctx = canvas.getContext('2d');
        ctx.drawImage(img, 0, 0);

        // Tải mô hình và phát hiện khuôn mặt
        await loadModels();
        const detections = await faceapi.detectSingleFace(canvas).withFaceLandmarks();
        if (!detections) throw new Error('Không phát hiện được khuôn mặt trong ảnh!');

        // Trích xuất vùng đầu
        const { x, y, width, height } = detections.detection.box;
        const maxLeft = Math.max(0, Math.floor(x - width * 0.4));
        const maxTop = Math.max(0, Math.floor(y - height * 0.9));
        const extractWidth = Math.min(Math.floor(width * 1.6), img.width);
        const extractHeight = Math.min(Math.floor(height * 2.2), img.height);

        const headBuffer = await sharp(imageBuffer)
            .extract({ left: maxLeft, top: maxTop, width: extractWidth, height: extractHeight })
            .toBuffer();

        // Xóa nền của vùng đầu
        const headBlob = new Blob([headBuffer], { type: 'image/png' });
        const resultBlob = await removeBackground(headBlob, {
            model: 'medium',
            output: { format: 'image/png' },
        });
        const headNoBgBuffer = Buffer.from(await resultBlob.arrayBuffer());

        // Lưu ảnh đã xử lý vào file tạm
        const tempDir = path.join(__dirname, '../temp');
        if (!fs.existsSync(tempDir)) {
            fs.mkdirSync(tempDir, { recursive: true });
        }
        const tempFileName = `${Date.now()}.png`;
        const tempPath = path.join(tempDir, tempFileName);
        fs.writeFileSync(tempPath, headNoBgBuffer);

        // Tạo file object để upload
        const file = {
            path: tempPath,
            originalname: tempFileName
        };

        // Upload ảnh đã xử lý lên CDN và lưu vào database
        const uploadResult = await uploadPhoto(userId, file);

        return {
            id: uploadResult.id,
            imagePath: uploadResult.imagePath
        };
    } catch (error) {
        // Xóa file tạm nếu có lỗi
        const tempPath = path.join(__dirname, '../temp', `${Date.now()}-${Math.round(Math.random() * 1E9)}.png`);
        if (fs.existsSync(tempPath)) {
            fs.unlinkSync(tempPath);
        }
        throw new Error(`Lỗi khi trích xuất và xóa nền ảnh: ${error.message}`);
    }
};

const detectFaceExpression = async (imagePath, userId) => {
  try {
    // Tạo URL đầy đủ bằng cách kết hợp CDN_SERVICE_URL và imagePath
    const baseUrl = process.env.CDN_SERVICE_URL;
    const fullimagePath = `${baseUrl}${imagePath}`;

    // Tải ảnh từ URL đầy đủ
    const response = await axios.get(fullimagePath, { responseType: 'arraybuffer' });
    const imageBuffer = Buffer.from(response.data, 'binary');

    const img = new Image();
    img.src = imageBuffer;
    const canvas = new Canvas(img.width, img.height);
    const ctx = canvas.getContext('2d');
    ctx.drawImage(img, 0, 0);

    await loadModels();
    const detection = await faceapi
      .detectSingleFace(canvas)
      .withFaceLandmarks()
      .withFaceExpressions();

    if (!detection) {
      throw new Error('Không phát hiện được khuôn mặt trong ảnh!');
    }
    const expressions = detection.expressions;
    const dominantEmotion = Object.keys(expressions).reduce((a, b) =>
      expressions[a] > expressions[b] ? a : b
    );

    const emotionTranslations = {
      neutral: 'Bình thường',
      happy: 'Vui vẻ',
      sad: 'Buồn',
      angry: 'Tức giận',
      fearful: 'Sợ hãi',
      disgusted: 'Ghê tởm',
      surprised: 'Ngạc nhiên',
    };

    const translatedEmotion = emotionTranslations[dominantEmotion] || dominantEmotion;

    // Chuyển đổi allExpressions thành mảng các đối tượng
    const allExpressions = Object.entries(expressions).map(([emotion, confidence]) => ({
      expression: emotionTranslations[emotion] || emotion,
      confidence: confidence,
    }));

    return {
      mainExpression: translatedEmotion, // Đổi tên từ "emotion" thành "mainExpression" để khớp với Flutter
      confidence: expressions[dominantEmotion],
      allExpressions: allExpressions, // Đây là một mảng, phù hợp với Flutter
    };
  } catch (error) {
    throw new Error(`Phát hiện cảm xúc thất bại: ${error.message}`);
  }
};

const enhancePhoto = async (userId, imagePath) => {
    try {
        if (!imagePath || typeof imagePath !== 'string') {
            throw new Error('URL ảnh không hợp lệ!');
        }
        // Tải ảnh từ CDN
        const response = await axios.get(`${process.env.CDN_SERVICE_URL}${imagePath}`, {
            responseType: 'arraybuffer',
        });
        const imageBuffer = Buffer.from(response.data);

        // Lưu ảnh tạm vào thư mục temp
        const tempDir = path.join(__dirname, '../temp');
        if (!fs.existsSync(tempDir)) {
            fs.mkdirSync(tempDir, { recursive: true });
        }
        const tempInputFileName = `${Date.now()}-${Math.round(Math.random() * 1E9)}.PNG`;
        const tempInputPath = path.join(tempDir, tempInputFileName);
        fs.writeFileSync(tempInputPath, imageBuffer);

        // Gửi ảnh tới server Python
        const formData = new FormData();
        formData.append('image', fs.createReadStream(tempInputPath), tempInputFileName);

        const pythonServerUrl = process.env.PYTHON_ENHANCE_URL+'/enhance';
        const pythonResponse = await axios.post(pythonServerUrl, formData, {
            headers: {
                ...formData.getHeaders(),
            },
            responseType: 'arraybuffer',
        });
    
        // Lưu ảnh đã nâng cấp từ server Python vào thư mục temp
        const tempOutputFileName = `${Date.now()}-${Math.round(Math.random() * 1E9)}.PNG`;
        const tempOutputPath = path.join(tempDir, tempOutputFileName);
        fs.writeFileSync(tempOutputPath, pythonResponse.data);

        // Tạo file object để upload lên CDN
        const file = {
            path: tempOutputPath,
            originalname: tempOutputFileName,
        };
    
        // Upload ảnh đã nâng cấp lên CDN và lưu vào database
        const uploadResult = await uploadPhoto(userId, file);
        return {
            id: uploadResult.id,
            imagePath: uploadResult.imagePath,
        };
    } catch (error) {
        // Xóa file tạm nếu có lỗi
        const tempDir = path.join(__dirname, '../temp');
        if (fs.existsSync(tempDir)) {
            fs.readdirSync(tempDir).forEach((file) => {
                const filePath = path.join(tempDir, file);
                if (fs.existsSync(filePath)) {
                    fs.unlinkSync(filePath);
                }
            });
        }
        throw new Error(`Nâng cấp ảnh thất bại: ${error.message}`);
    }
};

async function preprocessImage(imageBuffer) {
    try {
        if (!imageBuffer || imageBuffer.length === 0) {
            throw new Error('Buffer ảnh đầu vào không hợp lệ!');
        }

        const metadata = await sharp(imageBuffer).metadata();
        let originalWidth = metadata.width;
        let originalHeight = metadata.height;

        if (!originalWidth || !originalHeight) {
            throw new Error('Không thể đọc metadata của ảnh!');
        }

        let resizedBuffer = imageBuffer;
        if (originalWidth > MAX_DIMENSION || originalHeight > MAX_DIMENSION) {
            const newDimension = Math.min(MAX_DIMENSION, Math.max(originalWidth, originalHeight));
            resizedBuffer = await sharp(imageBuffer)
                .resize({
                    width: originalWidth > originalHeight ? newDimension : null,
                    height: originalHeight > originalWidth ? newDimension : null,
                    fit: 'inside',
                    withoutEnlargement: true
                })
                .toBuffer();

            const newMetadata = await sharp(resizedBuffer).metadata();
            originalWidth = newMetadata.width;
            originalHeight = newMetadata.height;
        }

        // Làm tròn kích thước lớn nhất LÊN bội số của 16
        let fixedDimension = Math.max(originalHeight, originalWidth);
        fixedDimension = Math.ceil(fixedDimension / 16) * 16; // Làm tròn lên bội số của 16

        // Tính padding để đạt kích thước fixedDimension x fixedDimension
        let paddingXLeft, paddingXRight, paddingYTop, paddingYBottom;
        // Padding cho chiều rộng
        const totalPaddingX = fixedDimension - originalWidth;
        paddingXLeft = Math.floor(totalPaddingX / 2);
        paddingXRight = totalPaddingX - paddingXLeft;

        // Padding cho chiều cao
        const totalPaddingY = fixedDimension - originalHeight;
        paddingYTop = Math.floor(totalPaddingY / 2);
        paddingYBottom = totalPaddingY - paddingYTop;

        const image = await sharp(resizedBuffer)
            .extend({
                top: paddingYTop,
                bottom: paddingYBottom,
                left: paddingXLeft,
                right: paddingXRight,
                background: { r: 0, g: 0, b: 0, alpha: 0 }
            })
            .toColourspace('srgb')
            .removeAlpha()
            .raw()
            .toBuffer({ resolveWithObject: true });

        const expectedSize = fixedDimension * fixedDimension * channels;
        if (!image.data || image.data.length !== expectedSize) {
            throw new Error(`Dữ liệu ảnh sau khi xử lý không hợp lệ! Expected size: ${expectedSize}, Actual size: ${image.data.length}`);
        }

        const data = new Float32Array(fixedDimension * fixedDimension * channels);
        let index = 0;
        for (let i = 0; i < image.data.length && index < data.length; i++) {
            data[index++] = (image.data[i] / 127.5) - 1; // Chuẩn hóa về [-1, 1]
        }

        return {
            data,
            size: fixedDimension,
            originalWidth,
            originalHeight,
            paddingX: paddingXLeft,
            paddingY: paddingYTop
        };
    } catch (error) {
        throw error;
    }
}

async function saveOutput(outputTensor, size, originalWidth, originalHeight, paddingX, paddingY) {
    try {
        const outputData = outputTensor.data;
        const buffer = new Uint8Array(size * size * channels);
        let index = 0;
        for (let i = 0; i < outputData.length && index < buffer.length; i++) {
            buffer[index++] = Math.min(255, Math.max(0, (outputData[i] + 1) * 127.5)); // Chuyển từ [-1, 1] về [0, 255]
        }

        const outputBuffer = await sharp(buffer, {
                raw: {
                    width: size,
                    height: size,
                    channels: channels
                }
            })
            .extract({
                left: paddingX,
                top: paddingY,
                width: originalWidth,
                height: originalHeight
            })
            .toFormat('png')
            .toBuffer();

        return outputBuffer;
    } catch (error) {
        throw error;
    }
}

const convertToAnime = async (userId, imagePath, model = 'Hayao') => {
    try {
        if (!imagePath || typeof imagePath !== 'string') {
            throw new Error('URL ảnh không hợp lệ!');
        }

        if (!userId) {
            throw new Error('Thiếu userId!');
        }

        // Tải ảnh từ CDN
        const response = await axios.get(`${process.env.CDN_SERVICE_URL}${imagePath}`, {
            responseType: 'arraybuffer',
        });
        const imageBuffer = Buffer.from(response.data);

        // Lưu ảnh tạm vào thư mục temp
        const tempDir = path.join(__dirname, '../temp');
        if (!fs.existsSync(tempDir)) {
            fs.mkdirSync(tempDir, { recursive: true });
        }
        const tempInputFileName = `${Date.now()}-${Math.round(Math.random() * 1E9)}.PNG`;
        const tempInputPath = path.join(tempDir, tempInputFileName);
        fs.writeFileSync(tempInputPath, imageBuffer);

        // Gửi ảnh tới server Python
        const formData = new FormData();
        formData.append('image', fs.createReadStream(tempInputPath), tempInputFileName);
        formData.append('model', model);
        
        const pythonServerUrl = process.env.PYTHON_ENHANCE_URL +'/convert-to-anime';
        const pythonResponse = await axios.post(pythonServerUrl, formData, {
            headers: {
                ...formData.getHeaders(),
            },
            responseType: 'arraybuffer',
        });
        // Lưu ảnh đã chuyển đổi từ server Python vào thư mục temp
        const tempOutputFileName = `${Date.now()}-${Math.round(Math.random() * 1E9)}.PNG`;
        const tempOutputPath = path.join(tempDir, tempOutputFileName);
        fs.writeFileSync(tempOutputPath, pythonResponse.data);

        // Tạo file object để upload lên CDN
        const file = {
            path: tempOutputPath,
            originalname: tempOutputFileName,
        };

        const uploadResult = await uploadPhoto(userId, file);

        // Xóa file tạm
        if (fs.existsSync(tempInputPath)) fs.unlinkSync(tempInputPath);
        if (fs.existsSync(tempOutputPath)) fs.unlinkSync(tempOutputPath);

        return {
            id: uploadResult.id,
            imagePath: uploadResult.imagePath,
        };
    } catch (error) {
        const tempPath = path.join(__dirname, '../temp', `${Date.now()}.png`);
        if (fs.existsSync(tempPath)) {
            fs.unlinkSync(tempPath);
        }
        throw new Error(`Chuyển đổi sang anime thất bại: ${error.message}`);
    }
};

module.exports = {
    uploadMulter,
    uploadPhoto,
    getPhotos,
    getPhoto,
    updatePhoto,
    deletePhoto,
    removeBackgroundService,
    extractHeadAndRemoveBackground,
    detectFaceExpression,
    enhancePhoto,
    convertToAnime,
    loadModels
};