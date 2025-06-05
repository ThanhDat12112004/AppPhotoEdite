const express = require('express');
const authMiddleware = require('../middleware/authMiddleware');
const {
    upload,
    getAll,
    getById,
    update,
    remove
} = require('../controllers/characterController');
const { uploadMulter } = require('../services/characterService');

const router = express.Router();

router.use(authMiddleware);

router.post('/', uploadMulter.single('file'), upload);
router.get('/', getAll);
router.get('/:id', getById);
router.put('/:id', update); 
router.delete('/:id', remove); 

module.exports = router;