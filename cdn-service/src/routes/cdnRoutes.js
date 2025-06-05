const express = require('express');
const { uploadMulter } = require('../services/cdnService');
const { uploadMulterCharacter } = require('../services/cdnService');
const { upload, update, remove,uploadCharacter, updateCharacter, removeCharacter } = require('../controllers/cdnController');

const router = express.Router();
router.post('/upload', uploadMulter.single('file'), upload);
router.post('/update', uploadMulter.single('file'), update);
router.post('/delete', remove);
router.post('/upload-character', uploadMulterCharacter.single('file'), uploadCharacter);
router.post('/update-character', uploadMulterCharacter.single('file'), updateCharacter);
router.post('/delete-character', removeCharacter);

module.exports = router;