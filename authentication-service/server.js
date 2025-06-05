const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const morgan = require('morgan');
const authRoutes = require('./src/routes/authRoutes');
const internalRoutes = require('./src/routes/internalRoutes');
const cors = require('cors');
const connectDB = require('./src/config/database');


// Tải biến môi trường
dotenv.config({ path: './.env' });

const app = express();
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ limit: '10mb', extended: true }));
// Middleware
app.use(express.json());
app.use(morgan('dev'));
app.use(cors());

// Kết nối MongoDB
connectDB();

// Routes
app.use('/', authRoutes);
app.use('/internal', internalRoutes);

// Health check
app.get('/health', (req, res) => {
    res.status(200).json({ status: 'Authentication service is running' });
});

// Khởi động server
const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
    console.log(`Authentication service running on port ${PORT}`);
});