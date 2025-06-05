const multer = require('multer');
const path = require('path');
const fs = require('fs');
const Photo = require('../models/photoModel');

const storageCharacter = multer.diskStorage({
    destination: (req, file, cb) => {
        const uploadDir = path.join(__dirname, '../../characters/');
        if (!fs.existsSync(uploadDir)) {
            fs.mkdirSync(uploadDir, { recursive: true });
        }
        cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, `${uniqueSuffix}.PNG`);
    }
});

const uploadMulterCharacter = multer({ storage: storageCharacter });
// Cấu hình multer để lưu file vào thư mục 'uploads/<userId>'
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        const { userId } = req.body; // Lấy userId từ body của request
        if (!userId) {
            return cb(new Error('Thiếu userId trong request!'), null);
        }

        const uploadDir = path.join(__dirname, '../../uploads/', userId);
        if (!fs.existsSync(uploadDir)) {
            fs.mkdirSync(uploadDir, { recursive: true });
        }
        cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, `${uniqueSuffix}.PNG`);
    }
});

const uploadMulter = multer({ storage });


const uploadToLocal = async(photoId, userId, filePath) => {
    try {
        // Đường dẫn file đã được multer lưu vào thư mục uploads/<userId>
        const fileName = path.basename(filePath);
        const localPath = `/uploads/${userId}/${fileName}`; // Đường dẫn tương đối để lưu vào MongoDB

        // Cập nhật đường dẫn file vào MongoDB
        await Photo.findByIdAndUpdate(photoId, { imagePath: localPath });

        return localPath;
    } catch (error) {
        // Nếu có lỗi, xóa file đã lưu để tránh rác
        if (fs.existsSync(filePath)) {
            fs.unlinkSync(filePath);
        }
        throw new Error(`Lỗi khi lưu file trên local: ${error.message}`);
    }
};
const uploadCharacterToLocal = async(photoId,filePath) => {
    try {
        // Đường dẫn file đã được multer lưu vào thư mục uploads/<userId>
        const fileName = path.basename(filePath);
        const localPath = `/characters/${fileName}`; // Đường dẫn tương đối để lưu vào MongoDB
    
        // Cập nhật đường dẫn file vào MongoDB
        await Photo.findByIdAndUpdate(photoId, { imagePath: localPath });

        return localPath;
    } catch (error) {
        // Nếu có lỗi, xóa file đã lưu để tránh rác
        if (fs.existsSync(filePath)) {
            fs.unlinkSync(filePath);
        }
        throw new Error(`Lỗi khi lưu file trên local: ${error.message}`);
    }
};

const deleteFromLocal = async(photoId) => {
    try {
        const photo = await Photo.findById(photoId);
        if (!photo) throw new Error('Không tìm thấy ảnh!');

        const filePath = path.join(__dirname,'./../../',photo.imagePath);
        if (fs.existsSync(filePath)) {
            fs.unlinkSync(filePath);
        }

        // Kiểm tra xem thư mục user có còn file nào không, nếu không thì xóa thư mục
        const userDir = path.dirname(filePath);
        if (fs.existsSync(userDir) && fs.readdirSync(userDir).length === 0) {
            fs.rmdirSync(userDir);
        }

        return true;
    } catch (error) {
        throw new Error(`Lỗi khi xóa file trên local: ${error.message}`);
    }
};

module.exports = { uploadMulter, uploadToLocal, deleteFromLocal,uploadCharacterToLocal, uploadMulterCharacter };