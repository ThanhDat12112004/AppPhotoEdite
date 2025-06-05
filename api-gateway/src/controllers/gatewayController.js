const healthCheck = (req, res) => {
    res.json({ message: 'API Gateway is running' });
};

module.exports = { healthCheck };