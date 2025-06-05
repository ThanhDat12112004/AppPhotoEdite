const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

// Schema Auth - chỉ chứa thông tin xác thực
const authSchema = new mongoose.Schema({
    username: { type: String, required: true, unique: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    isActive: { type: Boolean, default: true },
}, { timestamps: true });

// Middleware để mã hóa mật khẩu trước khi lưu
authSchema.pre('save', function(next) {
    if (this.isModified('password')) {
        let salt = bcrypt.genSaltSync(10);
        let encrypted = bcrypt.hashSync(this.password, salt);
        this.password = encrypted;
    }
    next();
});

module.exports = mongoose.model('Auth', authSchema);