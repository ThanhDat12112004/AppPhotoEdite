const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const { healthCheck } = require('../controllers/gatewayController');
const authMiddleware = require('../middleware/authMiddleware');
const logger = require('../middleware/logger');
const proxyConfig = require('../config/proxy');

const router = express.Router();

// Áp dụng middleware logger cho tất cả route
router.use(logger);

// Route kiểm tra API Gateway
router.get('/', healthCheck);

// Áp dụng proxy cho từng dịch vụ
Object.keys(proxyConfig.proxy).forEach((path) => {
    const config = proxyConfig.proxy[path];
    if (!config.target) {
        throw new Error(`Missing target for proxy path: ${path}`);
    }
    const proxyOptions = {
        ...config,
        logLevel: 'debug',
        onError: (err, req, res) => {
            console.error(`Proxy error for ${path}:`, err);
            if (err.code === 'ERR_STREAM_WRITE_AFTER_END') {
                res.status(502).json({ message: 'Stream closed unexpectedly' });
            } else {
                res.status(500).json({ message: `Proxy error: ${err.message}` });
            }
        },
        onProxyReq: (proxyReq, req, res) => {
            console.log(`Proxying request to ${path}:`, req.url);

            if (req.headers['content-type']?.includes('multipart/form-data')) {
            } else if (req.body) {
                const bodyData = JSON.stringify(req.body);
                proxyReq.setHeader('Content-Type', 'application/json');
                proxyReq.setHeader('Content-Length', Buffer.byteLength(bodyData));
                proxyReq.write(bodyData);
                proxyReq.end();
            }
        },
        onProxyRes: (proxyRes, req, res) => {
            console.log(`Received response from ${path}:`, proxyRes.statusCode);
        }
    };

    // if (path !== '/auth') {
        // router.use(path, authMiddleware, createProxyMiddleware(proxyOptions));
    // } else {
        router.use(path, createProxyMiddleware(proxyOptions));
    // }
});

module.exports = router;