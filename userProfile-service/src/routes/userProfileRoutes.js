// src/routes/userProfileRoutes.js
const express = require('express');
const authMiddleware = require('../middleware/authMiddleware');
const {
    getUserById,
    updateUser,
    deleteUser,
    createUserProfile,
    getUserByAuthId
} = require('../controllers/userProfileController');

const router = express.Router();

router.get('/:authId', getUserByAuthId);
router.post('/:authId', createUserProfile);
router.use(authMiddleware);
router.get('/', getUserById);
router.put('/', updateUser);
router.delete('/', deleteUser);

module.exports = router;