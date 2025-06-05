const express = require('express');
const dotenv = require('dotenv');
const morgan = require('morgan');
const connectDB = require('./src/config/database');
const userProfileRoutes = require('./src/routes/userProfileRoutes');
const cors = require('cors');

// Tải biến môi trường
dotenv.config({ path: './.env' });

// Kết nối database
connectDB();

const app = express();

// Middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ limit: '10mb', extended: true }));
app.use(express.json());
app.use(morgan('dev'));
app.use(cors());


// Routes
app.use('/', userProfileRoutes);


// Health check
app.get('/health', (req, res) => {
    res.status(200).json({ status: 'UserProfile service is running' });
});

// Khởi động server
const PORT = process.env.PORT || 3004;
app.listen(PORT, () => {
    console.log(`UserProfile service running on port ${PORT}`);
});