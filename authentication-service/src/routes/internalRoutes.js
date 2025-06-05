// src/routes/internalRoutes.js
const express = require('express');
const { getAuthInfo } = require('../controllers/authenticationController');

const router = express.Router();

// Internal route để lấy thông tin auth cho các service khác
router.get('/auth/:authId', async (req, res) => {
    try {
        const { authId } = req.params;
        const authInfo = await require('../services/authService').getAuthInfo(authId);
        res.json(authInfo);
    } catch (error) {
        res.status(404).json({ message: error.message });
    }
});

module.exports = router;
