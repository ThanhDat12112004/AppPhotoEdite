const express = require('express');
const authMiddleware = require('../middleware/authMiddleware');
const {
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
} = require('../controllers/photoController');
const { uploadMulter } = require('../services/photoService');

const router = express.Router();
router.use(authMiddleware);

// Upload ảnh
router.post('/upload', uploadMulter.single('file'), upload);

// Lấy tất cả ảnh của user
router.get('/', getAll);

// Lấy một ảnh theo ID
router.get('/:id', getById);

// Cập nhật ảnh
router.put('/:id', uploadMulter.single('image'), update);

// Xóa ảnh
router.delete('/:id', remove);

// Xóa nền ảnh
router.post('/remove-background', removeBackground);

// Tách phần đầu và xóa nền
router.post('/extract-head', extractHead);

// Nhận diện cảm xúc trên khuôn mặt
router.post('/detect-expression', detectExpression);

// Nâng cấp ảnh
router.post('/enhance', enhance);

// Chuyển đổi sang anime
router.post('/convert-to-anime', convertAnime);

module.exports = router;