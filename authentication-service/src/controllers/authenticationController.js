// src/controllers/authController.js
const { registerUser, loginUser, getAuthInfo } = require('../services/authService');

const register = async(req, res) => {
    try {
        const { username, email, password } = req.body;
        const response = await registerUser(username, email, password);
        res.status(201).json(response);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

const login = async(req, res) => {
    try {
        const { email, username, password } = req.body;
        const result = await loginUser(email, username, password);
        res.status(200).json(result);
    } catch (error) {
        res.status(400).json({ message: "Thông tin đăng nhập không chính xác" });
    }
};

const getAuthInfoController = async(req, res) => {
    try {
        const auth = await getAuthInfo(req.user.id); // 'id' remains correct since this is the authId in the token
        res.json(auth);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

module.exports = { register, login, getAuthInfo: getAuthInfoController };