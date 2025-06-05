// src/controllers/userController.js
const {
    getUserById,
    updateUser,
    deleteUser,
    createUserProfile,
} = require('../services/userService');


const getUserByIdController = async(req, res) => {
    try {
        // Access authId directly from the token
        const authId = req.user.id; // This should remain as id since it refers to authId
        const user = await getUserById(authId);
        res.json(user);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};
const getUserByAuthIdController = async(req, res) => {
    try {
        console.log("aaaaaaaaaaaaaadasdas");
        const authId = req.params.authId; 
        const user = await getUserById(authId);
        res.json(user);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

const updateUserController = async(req, res) => {
    try {
        // Access authId directly from the token
        const authId = req.user.id; // This should remain as id since it refers to authId
        const user = await updateUser(authId, req.body);
        res.json({ message: 'Cập nhật thông tin User thành công!', user });
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

const deleteUserController = async(req, res) => {
    try {
        // Access authId directly from the token
        const authId = req.user.id; // This should remain as id since it refers to authId
        const result = await deleteUser(authId);
        res.json(result);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

const createUserProfileController = async(req, res) => {
    try {
        console.log("Creating user profile...");
        const { authId } = req.body;
        console.log('Received authId:', authId);
        const profile = await createUserProfile(authId);
        console.log('Profile created:', profile);
        res.status(201).json({ message: 'Tạo profile thành công!', profile });
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

module.exports = {
    getUserById: getUserByIdController,
    updateUser: updateUserController,
    deleteUser: deleteUserController,
    createUserProfile: createUserProfileController,
    getUserByAuthId: getUserByAuthIdController
};