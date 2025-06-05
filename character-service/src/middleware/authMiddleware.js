const jwt = require('jsonwebtoken');

/**
 * Middleware xác thực người dùng bằng JWT
 * Kiểm tra token trong header Authorization
 */
const authMiddleware = (req, res, next) => {
    try {
        // Lấy token từ header
        const authHeader = req.headers.authorization;
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({ message: 'Không có token xác thực' });
        }

        const token = authHeader.split(' ')[1];        // Xác thực token
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        // Gán thông tin người dùng vào request
        req.user = decoded;
        
        // Kiểm tra userId có tồn tại trong token không
        if (!decoded.userId) {
            return res.status(400).json({ message: 'Token không chứa userId' });
        }

        next();
    } catch (error) {
        return res.status(401).json({ message: 'Token không hợp lệ' });
    }
};

module.exports = authMiddleware;