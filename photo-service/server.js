const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const morgan = require('morgan');
const photoRoutes = require('./src/routes/photoRoutes');
const cors = require('cors');
const connetDB = require('./src/config/database');

// Tải biến môi trường
dotenv.config();

const app = express();

app.use(express.json({ limit: '100mb' }));
app.use(express.urlencoded({ limit: '100mb', extended: true }));
// Middleware
app.use(express.json());
app.use(morgan('dev'));
app.use(cors());
// Kết nối MongoDB
connetDB();
app.use('/', photoRoutes);

// Health check
app.get('/health', (req, res) => {
    res.status(200).json({ status: 'Photo service is running' });
});

// Khởi động server
const PORT = process.env.PORT || 3003;
app.listen(PORT, () => {
    console.log(`Photo service running on port ${PORT}`);
});