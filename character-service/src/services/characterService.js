const mongoose = require('mongoose');
const Character = require('../models/characterModel');
const axios = require('axios');
const FormData = require('form-data');
const fs = require('fs');
const path = require('path');
const multer = require('multer');

// Cấu hình multer để lưu file tạm thời
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        const tempDir = path.join(__dirname, '../temp');
        if (!fs.existsSync(tempDir)) {
            fs.mkdirSync(tempDir, { recursive: true });
        }
        cb(null, tempDir);
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, `${uniqueSuffix}.PNG`);
    }
});

const uploadMulter = multer({ storage });

const uploadCharacter = async (name, file) => {
    try {
        const existingCharacter = await Character.findOne({ name });
        if (existingCharacter) {
            throw new Error('Nhân vật với tên này đã tồn tại');
        }

        const character = new Character({
            name,
            imageURL: 'temp',
        });
        await character.save();

        const formData = new FormData();
        formData.append('photoId', character._id.toString());
        formData.append('file', fs.createReadStream(file.path)); // Đảm bảo file.path tồn tại

        const response = await axios.post(
            `${process.env.CDN_SERVICE_URL}/upload-character`,
            formData,
            { headers: formData.getHeaders() }
        );

        character.imagePath = response.data.imagePath;
        await character.save();

        fs.unlinkSync(file.path);

        return {character: character, message: 'Tải nhân vật lên thành công!'};
    } catch (error) {
        if (character) {
            await Character.findByIdAndDelete(character._id);
        }
        throw new Error(`Lỗi khi tải nhân vật lên: ${error.message}`);
    }
};

const deleteCharacter = async (id) => {
    try {
        const character = await Character.findById(id);
        if (!character) {
            throw new Error('Không tìm thấy nhân vật');
        }

        // Gọi API xóa file trên CDN, dùng _id làm photoId
        await axios.post(`${process.env.CDN_SERVICE_URL}/delete-character`, { photoId: character._id.toString() }).catch((error) => {
            console.error('Error from CDN Service:', error.message);
            throw new Error(`Lỗi khi xóa file trên CDN: ${error.message}`);
        });

        // Xóa character khỏi MongoDB bằng _id
        await Character.findByIdAndDelete(id);
        return { message: 'Xóa nhân vật thành công!' };
    } catch (error) {
        throw new Error(`Lỗi khi xóa nhân vật: ${error.message}`);
    }
};

const getCharacters = async () => {
    try {
        const characters = await Character.find().sort({ createdAt: -1 });
        return characters;
    } catch (error) {
        throw error;
    }
};

const getCharacter = async (id) => {
    try {
        const character = await Character.findById(id);
        if (!character) {
            throw new Error('Không tìm thấy nhân vật');
        }
        return character;
    } catch (error) {
        throw error;
    }
};
const updateCharacter = async (id, updateData) => {
    try {
        const character = await Character.findByIdAndUpdate(id, updateData, { new: true, runValidators: true });
        if (!character) {
            throw new Error('Không tìm thấy nhân vật');
        }
        return character;
    } catch (error) {
        throw error;
    }
};

module.exports = {
    uploadMulter,
    uploadCharacter,
    getCharacters,
    getCharacter,
    updateCharacter,
    deleteCharacter,
};