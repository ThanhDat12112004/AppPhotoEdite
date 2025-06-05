const dotenv = require('dotenv');
dotenv.config();

module.exports = {
    proxy: {
        '/auth': {
            target: process.env.AUTH_SERVICE_URL,
            changeOrigin: true,
            pathRewrite: { '^/auth': '' },
        },
        '/characters': {
            target: process.env.CHARACTER_SERVICE_URL,
            changeOrigin: true,
            pathRewrite: { '^/characters': '' },
        },
        '/photos': {
            target: process.env.PHOTO_SERVICE_URL,
            changeOrigin: true,
            pathRewrite: { '^/photos': '' },
        },
        '/display-photo': {
        target: process.env.CDN_SERVICE_URL,
        changeOrigin: true,
        pathRewrite: { '/display-photo': '' }, 
        },
        '/user-profile': {
            target: process.env.USER_PROFILE_SERVICE_URL,
            changeOrigin: true,
            pathRewrite: { '^/user-profile': '' },
        },
    },
};