const mongoose = require('mongoose');

// Schema UserProfile - chứa thông tin profile của user và tham chiếu đến Auth ID
const userProfileSchema = new mongoose.Schema({
    authId: { type: mongoose.Schema.Types.ObjectId, required: true, unique: true }, // Tham chiếu đến Auth ID
    fullName: { type: String, default: 'Chưa cập nhật' },
    dateOfBirth: { type: Date, default: null },
    gender: { type: String, enum: ['Nam', 'Nữ', 'Khác'], default: 'Khác' },
    phoneNumber: { type: String, default: 'Chưa cập nhật' },
    address: { type: String, default: 'Chưa cập nhật' },
    avatar: { type: String, default: 'Chưa cập nhật' },
    bio: { type: String, default: 'Chưa cập nhật' }, // Thêm bio
    isPublic: { type: Boolean, default: true }, // Quyền riêng tư profile
}, { timestamps: true });

module.exports = mongoose.model('UserProfile', userProfileSchema);