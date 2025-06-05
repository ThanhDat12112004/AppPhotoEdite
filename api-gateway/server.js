const express = require('express');
const dotenv = require('dotenv');
const routes = require('./src/routes');
const cors = require('cors');
const multer = require('multer'); // Thêm multer

// Tải biến môi trường
dotenv.config();

const app = express();

// Middleware để parse JSON và multipart/form-data
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ limit: '10mb', extended: true }));

// Parse multipart/form-data cho các route upload


// Sử dụng routes
app.use('/', routes);

// Xử lý lỗi chung
app.use((err, req, res, next) => {
    if (err.type === 'request.aborted') {
        console.log('Request was aborted by client');
        res.status(400).json({ message: 'Request aborted' });
    } else {
        console.error('Error in API Gateway:', err);
        res.status(500).json({ message: 'Internal server error' });
    }
});

// Khởi động server
const PORT = process.env.PORT || 3000;
const server = app.listen(PORT, () => {
    console.log(`API Gateway running on port ${PORT}`);
});