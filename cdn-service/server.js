const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const morgan = require('morgan');
const cors = require('cors');
const path = require('path');
const connectDB = require('./src/config/database');
const cdnRoutes = require('./src/routes/cdnRoutes');

// Tải biến môi trường
dotenv.config();

const app = express();

app.use(express.json());
app.use(morgan('dev'));
app.use(cors());

// Phục vụ file tĩnh
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
app.use('/characters', express.static(path.join(__dirname, 'characters')));
// Kết nối MongoDB
connectDB();

app.use('/', cdnRoutes);

// Health check
app.get('/health', (req, res) => {
    res.status(200).json({ status: 'CDN Service is running' });
});

const PORT = process.env.PORT || 3005;
app.listen(PORT, () => {
    console.log(`CDN Service running on port ${PORT}`);
});