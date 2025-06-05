const {
    uploadCharacter,
    getCharacters,
    getCharacter,
    updateCharacter,
    deleteCharacter
} = require('../services/characterService');

const upload = async (req, res) => {
    try {
        const { name } = req.body;
        const file = req.file;
        if (!name || !file) {
            return res.status(400).json({ message: 'Thiếu name hoặc file ảnh!' });
        }

        const character = await uploadCharacter(name, file);
        res.status(201).json(character);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

const remove = async (req, res) => {
    try {
        const characterId = req.params.id; // _id từ params
        const result = await deleteCharacter(characterId);
        res.json(result);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

const getAll = async (req, res) => {
    try {
        const characters = await getCharacters();
        res.json(characters);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

const getById = async (req, res) => {
    try {
        const characterId = req.params.id; // _id từ params
        const character = await getCharacter(characterId);
        res.json(character);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

const update = async (req, res) => {
    try {
        const characterId = req.params.id; // _id từ params
        const updateData = req.body;
        const character = await updateCharacter(characterId, updateData);
        res.json(character);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

module.exports = { upload, getAll, getById, update, remove };