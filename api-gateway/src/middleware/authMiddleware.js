const jwt = require('jsonwebtoken');

const  authMiddleware = (req, res, next) => {
    const token = req.header('Authorization');
    if (!token) return res.status(401).json({ message: 'Access Denied' });

    try {
        const verified = jwt.verify(token.split(" ")[1], process.env.JWT_SECRET);
        req.user = verified;
        // Đảm bảo có cả id (authId) và userId trong token
        if (!verified.id) {
            return res.status(400).json({ message: 'Token không chứa id (authId)' });
        }
        if (!verified.userId) {
            return res.status(400).json({ message: 'Token không chứa userId' });
        }
        next();
    } catch (error) {
        res.status(400).json({ message: 'Invalid Token' });
    }
};

module.exports = authMiddleware;