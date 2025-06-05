const express = require('express');
const authMiddleware = require('../middleware/authMiddleware');
const { register, login, getAuthInfo } = require('../controllers/authenticationController');

const router = express.Router();

// Đăng ký
router.post('/register', register);

// Đăng nhập
router.post('/login', login);

// Lấy thông tin auth (yêu cầu token)
router.get('/auth-info', authMiddleware, getAuthInfo);

module.exports = router;