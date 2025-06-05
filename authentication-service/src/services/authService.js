// src/services/authService.js
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const axios = require('axios');
const Auth = require('../models/authModel');

const registerUser = async(username, email, password) => {
    // Kiểm tra username
    const usernameCriteria = {
        minLength: 6,
        maxLength: 20,
        validChars: /^[a-zA-Z0-9_.]+$/,
        noStartEndSpecial: /^[a-zA-Z0-9][a-zA-Z0-9_.]*[a-zA-Z0-9]$/,
        noWhitespace: /^\S+$/,
    };

    const usernameErrors = [];
    if (username.length < usernameCriteria.minLength) {
        usernameErrors.push(`Tên người dùng phải có ít nhất ${usernameCriteria.minLength} ký tự`);
    }
    if (username.length > usernameCriteria.maxLength) {
        usernameErrors.push(`Tên người dùng không được dài quá ${usernameCriteria.maxLength} ký tự`);
    }
    if (!usernameCriteria.validChars.test(username)) {
        usernameErrors.push('Tên người dùng chỉ được chứa chữ cái, số, dấu gạch dưới (_) và dấu chấm (.)');
    }
    if (!usernameCriteria.noStartEndSpecial.test(username) && username.length >= usernameCriteria.minLength) {
        usernameErrors.push('Tên người dùng không được bắt đầu hoặc kết thúc bằng dấu gạch dưới hoặc dấu chấm');
    }
    if (!usernameCriteria.noWhitespace.test(username)) {
        usernameErrors.push('Tên người dùng không được chứa khoảng trắng');
    }

    // Kiểm tra email
    const emailCriteria = {
        maxLength: 50,
        validFormat: /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/,
        noWhitespace: /^\S+$/,
    };

    const emailErrors = [];
    email = email.toLowerCase();
    if (email.length > emailCriteria.maxLength) {
        emailErrors.push(`Email không được dài quá ${emailCriteria.maxLength} ký tự`);
    }
    if (!emailCriteria.validFormat.test(email)) {
        emailErrors.push('Email không hợp lệ (ví dụ: user@domain.com)');
    }
    if (!emailCriteria.noWhitespace.test(email)) {
        emailErrors.push('Email không được chứa khoảng trắng');
    }

    // Kiểm tra mật khẩu
    const passwordCriteria = {
        minLength: 8,
        hasUpperCase: /[A-Z]/,
        hasLowerCase: /[a-z]/,
        hasNumber: /[0-9]/,
        hasSpecialChar: /[!@#$%^&*(),.?":{}|<>]/,
    };

    const passwordErrors = [];
    if (password.length < passwordCriteria.minLength) {
        passwordErrors.push(`Mật khẩu phải có ít nhất ${passwordCriteria.minLength} ký tự`);
    }
    if (!passwordCriteria.hasUpperCase.test(password)) {
        passwordErrors.push('Mật khẩu phải chứa ít nhất một chữ cái in hoa');
    }
    if (!passwordCriteria.hasLowerCase.test(password)) {
        passwordErrors.push('Mật khẩu phải chứa ít nhất một chữ cái thường');
    }
    if (!passwordCriteria.hasNumber.test(password)) {
        passwordErrors.push('Mật khẩu phải chứa ít nhất một số');
    }
    if (!passwordCriteria.hasSpecialChar.test(password)) {
        passwordErrors.push('Mật khẩu phải chứa ít nhất một ký tự đặc biệt (ví dụ: !@#$%^&*)');
    }

    // Gộp tất cả lỗi
    const allErrors = [];
    if (usernameErrors.length > 0) {
        allErrors.push(`Tên người dùng: ${usernameErrors.join(', ')}`);
    }
    if (emailErrors.length > 0) {
        allErrors.push(`Email: ${emailErrors.join(', ')}`);
    }
    if (passwordErrors.length > 0) {
        allErrors.push(`Mật khẩu: ${passwordErrors.join(', ')}`);
    }

    if (allErrors.length > 0) {
        throw new Error(allErrors.join('; '));
    }    // Kiểm tra người dùng đã tồn tại chưa
    const existingEmail = await Auth.findOne({ email });
    if (existingEmail) {
        throw new Error('Email đã tồn tại!');
    }
    const existingUsername = await Auth.findOne({ username });
    if (existingUsername) {
        throw new Error('Username đã tồn tại!');
    }

    // Tạo Auth
    const newAuth = new Auth({ username, email, password });
    await newAuth.save();    // Tạo UserProfile tương ứng trong UserProfile service
    try {
        const profileResponse = await axios.post(`${process.env.USER_PROFILE_SERVICE_URL}/create-profile`, {
            authId: newAuth._id.toString()
        });

        // Lấy userId từ profile được tạo
        const userId = profileResponse.data.profile._id;
        
        // Tạo token sau khi đăng ký thành công
        const token = jwt.sign({ 
            id: newAuth._id, 
            userId: userId,
            username: newAuth.username, 
            email: newAuth.email 
        }, process.env.JWT_SECRET, { expiresIn: '24h' });
        
        return { 
            message: 'Đăng ký tài khoản thành công!', 
            authId: newAuth._id,
            userId: userId,
            token: token
        };
    } catch (error) {
        console.error('Lỗi khi tạo profile:', error.message);
        // Rollback nếu tạo profile thất bại
        await Auth.findByIdAndDelete(newAuth._id);
        throw new Error('Lỗi khi tạo profile người dùng');
    }
};

const loginUser = async(email, username, password) => {
    
    if (!email && !username) {
        throw new Error('Email hoặc username là bắt buộc');
    }

    let auth;
    if (email) {
        email = email.toLowerCase();
        auth = await Auth.findOne({ email });
    }

    if (!auth && username) {
        username = username.toLowerCase();
        auth = await Auth.findOne({ username });
    }
    if (!auth) {
        throw new Error('Không tìm thấy tài khoản!');
    }    const isMatch = await bcrypt.compare(password, auth.password);
    if (!isMatch) {
        throw new Error('Mật khẩu không chính xác');
    }
    
    // Get userId from user-profile service
    try {
        const response = await axios.get(`${process.env.USER_PROFILE_SERVICE_URL}/${auth._id}`);
        const userId = response.data._id; // UserProfile _id chính là userId
        auth.userId = userId; // Add userId to auth object
    } catch (error) {
        console.error('Error fetching userId:', error.message);
        throw new Error('Không thể lấy thông tin người dùng');
    }    const token = jwt.sign({ 
        id: auth._id, 
        userId: auth.userId, // Thêm userId vào token
        username: auth.username, 
        email: auth.email 
    }, process.env.JWT_SECRET, { expiresIn: '24h' });
    return { message: 'Đăng nhập thành công!', token, auth };
};

const getAuthInfo = async(authId) => {
    const auth = await Auth.findById(authId).select('-password');
    if (!auth) {
        throw new Error('Không tìm thấy thông tin xác thực!');
    }
    return auth;
};

module.exports = { registerUser, loginUser, getAuthInfo };