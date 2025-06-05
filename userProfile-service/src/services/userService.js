const UserProfile = require('../models/userProfileModel');
const axios = require('axios');

const getUserById = async(authId) => {
    try {
        const userProfile = await UserProfile.findOne({ authId: authId });
        if (!userProfile) {
            throw new Error('Không tìm thấy thông tin người dùng');
        }

        // Lấy thông tin auth từ authentication service
        try {
            const authResponse = await axios.get(`${process.env.AUTH_SERVICE_URL}/internal/auth/${authId}`);
            const authInfo = authResponse.data;
            
            return {
                ...userProfile.toObject(),
                _id: userProfile._id.toString(), // Đảm bảo _id được trả về dưới dạng string
                username: authInfo.username,
                email: authInfo.email
            };
        } catch (authError) {
            // Nếu không lấy được thông tin auth, chỉ trả về profile với _id
            return {
                ...userProfile.toObject(),
                _id: userProfile._id.toString()
            };
        }
    } catch (error) {
        throw error;
    }
};

const updateUser = async(authId, updateData) => {
    try {
        // Loại bỏ các trường không được phép cập nhật
        const allowedFields = ['fullName', 'dateOfBirth', 'gender', 'phoneNumber', 'address', 'avatar', 'bio', 'isPublic'];
        const filteredData = {};
        
        allowedFields.forEach(field => {
            if (updateData[field] !== undefined) {
                filteredData[field] = updateData[field];
            }
        });

        const userProfile = await UserProfile.findOneAndUpdate(
            { authId: authId },
            filteredData, 
            { new: true, runValidators: true }
        );
        
        if (!userProfile) {
            throw new Error('Không tìm thấy thông tin người dùng');
        }
        return userProfile;
    } catch (error) {
        throw error;
    }
};

const deleteUser = async(authId) => {
    try {
        const userProfile = await UserProfile.findOneAndDelete({ authId: authId });
        if (!userProfile) {
            throw new Error('Không tìm thấy thông tin người dùng');
        }
        return { message: 'Đã xóa thông tin người dùng' };
    } catch (error) {
        throw error;
    }
};

const createUserProfile = async(authId) => {
    try {
        const existingProfile = await UserProfile.findOne({ authId: authId});
        if (existingProfile) {
            throw new Error('Profile đã tồn tại cho user này');
        }
        const newProfile = new UserProfile({ authId });
        await newProfile.save();
        console.log('Profile created:', newProfile);
        return newProfile;
    } catch (error) {
        console.error('Error creating user profile:', error);
        throw error;
    }
};

module.exports = {
    getUserById,
    updateUser,
    deleteUser,
    createUserProfile
};