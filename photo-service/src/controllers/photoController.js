const {
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
    convertToAnime
} = require('../services/photoService');

const upload = async(req, res) => {
    try {
        const userId = req.user.userId; // Lấy userId từ token thay vì request body
        const file = req.file;
        await uploadPhoto(userId, file);
        res.status(201).json({ message: "Tải ảnh thành công" });
    } catch (error) {
        res.status(400).json({ message: "Tải ảnh thất bại" });
    }
};

const getAll = async(req, res) => {
    try {
        const userId = req.user.userId;
        const photos = await getPhotos(userId);
        res.json({message: "Tải ảnh thành công", photos});
    } catch (error) {
        res.status(400).json({ message: "Tải ảnh thất bại" });
    }
};

const getById = async(req, res) => {
    try {
        const photoId = req.params.id;
        const userId = req.user.userId;
        const result = await getPhoto(photoId, userId);
        res.json({message: "Tải ảnh thành công", result});
    } catch (error) {
        res.status(400).json({ message: "Tải ảnh thất bại" });
    }
};

const update = async(req, res) => {
    try {
        const photoId = req.params.id;
        const userId = req.user.userId;
        const file = req.file;
        const photo = await updatePhoto(photoId, userId, file);
        res.json(photo);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

const remove = async(req, res) => {
    try {
        const photoId = req.params.id;
        const userId = req.user.userId;
        const result = await deletePhoto(photoId, userId);
        res.json(result);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

const removeBackground = async(req, res) => {
    try {
        const { imagePath } = req.body; 
        const userId = req.user.userId;
        const photo  = await removeBackgroundService(userId,imagePath);
        console.log(photo);
        res.status(200).json(photo);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const extractHead = async (req, res) => {
    try {
        const { imagePath } = req.body;
        const userId = req.user.userId;
        if (!imagePath) {
            return res.status(400).json({ message: 'Vui lòng cung cấp imagePath!' });
        }
        const photo = await extractHeadAndRemoveBackground(userId, imagePath);
        res.status(200).json(photo);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const detectExpression = async (req, res) => {
    try {
      const { imagePath } = req.body;
      const userId = req.user.userId; 
      const result = await detectFaceExpression(imagePath, userId);
      
      res.status(200).json(result);
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  };

  const enhance = async (req, res) => {
    try {
        const { imagePath } = req.body;
        const userId = req.user.userId;
        // Kiểm tra imagePath
        if (!imagePath || typeof imagePath !== 'string') {
            return res.status(400).json({ message: 'Vui lòng cung cấp imagePath hợp lệ!' });
        }
        // Gọi service để xử lý nâng cấp ảnh
        const photo = await enhancePhoto(userId, imagePath);

        // Trả về kết quả
        res.status(200).json({
            id: photo.id,
            imagePath: photo.imagePath,
        });
    } catch (error) {
        res.status(500).json({ message: `Nâng cấp ảnh thất bại: ${error.message}` });
    }
};

const convertAnime = async (req, res) => {
    try {
        const { imagePath, model = 'Hayao' } = req.body; // Lấy imagePath và model từ body
        const userId = req.user.userId;
        if (!imagePath || typeof imagePath !== 'string') {
            return res.status(400).json({ message: 'Vui lòng cung cấp imagePath hợp lệ!' });
        }
        
        // Gọi hàm convertToAnime từ service để xử lý chuyển đổi
        const photo = await convertToAnime(userId, imagePath, model);

        // Trả về thông tin ảnh đã xử lý
        res.status(200).json({
            id: photo.id,
            imagePath: photo.imagePath,
            message: 'Chuyển đổi sang anime thành công!',
            modelUsed: model
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = {
    upload,
    getAll,
    getById,
    update,
    remove,
    removeBackground,
    extractHead,
    detectExpression,
    enhance,
    convertAnime
};