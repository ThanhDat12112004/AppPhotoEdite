const { uploadToLocal, deleteFromLocal, uploadCharacterToLocal } = require('../services/cdnService');

const upload = async(req, res) => {
    try {
        const { photoId, userId} = req.body;
        const file = req.file;

        if (!photoId || !userId || !file) {
            return res.status(400).json({ message: 'Thiếu photoId, userId hoặc file!' });
        }

        const imagePath = await uploadToLocal(photoId, userId, file.path);
        res.status(200).json({ imagePath });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
const uploadCharacter = async (req, res) => {
    try {
        const { photoId } = req.body;
        const file = req.file;

        if (!photoId || !file) {
            return res.status(400).json({ message: 'Thiếu photoId hoặc file!' });
        }
        const imagePath = await uploadCharacterToLocal(photoId, file.path);
        res.status(200).json({ imagePath });
    } catch (error) {
        console.error('Lỗi trong uploadCharacter:', error);
        res.status(500).json({ message: error.message });
    }
};
const update = async (req, res) => {
    try {
        const { photoId, userId, originalName } = req.body;
        const file = req.file;
        if (!photoId || !userId || !file) {
            return res.status(400).json({ message: 'Thiếu photoId, userId hoặc file!' });
        }
        await deleteFromLocal(photoId);
        const imagePath = await uploadToLocal(photoId, userId, file.path, originalName);

        res.status(200).json({ imagePath });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
const updateCharacter = async (req, res) => {
    try {
        const { photoId, userId, originalName } = req.body;
        const file = req.file;
        if (!photoId || !userId || !file) {
            return res.status(400).json({ message: 'Thiếu photoId, userId hoặc file!' });
        }
        await deleteFromLocal(photoId);
        const imagePath = await uploadToLocal(photoId, userId, file.path, originalName);

        res.status(200).json({ imagePath });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
const remove = async(req, res) => {
    try {
        const { photoId } = req.body;
        if (!photoId) {
            return res.status(400).json({ message: 'Thiếu photoId!' });
        }
        await deleteFromLocal(photoId);
        res.status(200).json({ message: 'Xóa file thành công!' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
const removeCharacter = async(req, res) => {
    try {
        const { photoId } = req.body;
        if (!photoId) {
            return res.status(400).json({ message: 'Thiếu photoId!' });
        }

        await deleteFromLocal(photoId);
        res.status(200).json({ message: 'Xóa file thành công!' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = { upload, remove,update,uploadCharacter, updateCharacter, removeCharacter };