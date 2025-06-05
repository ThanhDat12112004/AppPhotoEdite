const express = require('express');
const dotenv = require('dotenv');
const morgan = require('morgan');
const connectDB = require('./src/config/database');
const characterRoutes = require('./src/routes/characterRoutes');
const cors = require('cors');

// Tải biến môi trường
dotenv.config();

// Kết nối database
connectDB();

const app = express();
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ limit: '10mb', extended: true }));
// Middleware
app.use(morgan('dev'));
app.use(cors());
// Routes
app.use('/', characterRoutes);

// Health check endpoint
app.get('/health', (req, res) => {
    res.status(200).json({ status: 'Character service is running' });
});

// Khởi động server
const PORT = process.env.PORT || 3002;
app.listen(PORT, () => {
    console.log(`Character service running on port ${PORT}`);
});