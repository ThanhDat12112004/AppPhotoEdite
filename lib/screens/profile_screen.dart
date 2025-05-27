import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/services/userprofileServices/user_service.dart';
import '../models/user.dart';
import '../services/authServices/auth_service.dart';
import '../utils/error_handler.dart';
import '../widgets/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const ProfileScreen({super.key, required this.onLogout});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;
  bool isEditing = false;
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  DateTime? selectedDate;
  String? selectedGender;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    try {
      user = await UserService.fetchUserProfile();
      fullNameController.text = user?.fullName ?? '';
      phoneController.text = user?.phoneNumber ?? '';
      addressController.text = user?.address ?? '';
      bioController.text = user?.bio ?? '';
      selectedDate = user?.dateOfBirth;
      selectedGender = user?.gender;
      setState(() {});
    } catch (e) {
      ErrorHandler.handleError(context, e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      await UserService.updateUserProfile({
        'fullName': fullNameController.text,
        'phoneNumber': phoneController.text,
        'address': addressController.text,
        'bio': bioController.text,
        'dateOfBirth': selectedDate?.toIso8601String(),
        'gender': selectedGender,
      });
      setState(() => isEditing = false);
      await _fetchProfile();
    } catch (e) {
      ErrorHandler.handleError(context, e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _logout() async {
    setState(() => _isLoading = true);
    try {
      await AuthService.logout();
      widget.onLogout();
    } catch (e) {
      ErrorHandler.handleError(context, e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin cá nhân',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  if (user != null && !isEditing) ...[
                    ListTile(
                      title: const Text('Tên người dùng'),
                      subtitle: Text(user!.username),
                    ),
                    ListTile(
                      title: const Text('Email'),
                      subtitle: Text(user!.email),
                    ),
                    ListTile(
                      title: const Text('Họ và tên'),
                      subtitle: Text(user!.fullName ?? 'Chưa cập nhật'),
                    ),
                    ListTile(
                      title: const Text('Ngày sinh'),
                      subtitle: Text(selectedDate != null
                          ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                          : 'Chưa cập nhật'),
                    ),
                    ListTile(
                      title: const Text('Giới tính'),
                      subtitle: Text(user!.gender ?? 'Chưa cập nhật'),
                    ),
                    ListTile(
                      title: const Text('Số điện thoại'),
                      subtitle: Text(user!.phoneNumber ?? 'Chưa cập nhật'),
                    ),
                    ListTile(
                      title: const Text('Địa chỉ'),
                      subtitle: Text(user!.address ?? 'Chưa cập nhật'),
                    ),
                    ListTile(
                      title: const Text('Giới thiệu'),
                      subtitle: Text(user!.bio ?? 'Chưa cập nhật'),
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      label: 'Chỉnh sửa',
                      icon: Icons.edit,
                      onPressed: () => setState(() => isEditing = true),
                    ),
                  ],
                  if (isEditing) ...[
                    TextField(
                      controller: fullNameController,
                      decoration: InputDecoration(
                        labelText: 'Họ và tên',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Ngày sinh',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          selectedDate != null
                              ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                              : 'Chọn ngày sinh',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedGender,
                      decoration: InputDecoration(
                        labelText: 'Giới tính',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      items: ['Nam', 'Nữ', 'Khác']
                          .map((gender) => DropdownMenuItem(
                              value: gender, child: Text(gender)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedGender = value),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: 'Số điện thoại',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: addressController,
                      decoration: InputDecoration(
                        labelText: 'Địa chỉ',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: bioController,
                      decoration: InputDecoration(
                        labelText: 'Giới thiệu',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: 'Viết vài dòng về bản thân...',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomButton(
                          label: 'Lưu',
                          icon: Icons.save,
                          onPressed: _updateProfile,
                        ),
                        CustomButton(
                          label: 'Hủy',
                          icon: Icons.cancel,
                          onPressed: () => setState(() => isEditing = false),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  CustomButton(
                    label: 'Đăng xuất',
                    icon: Icons.logout,
                    onPressed: _logout,
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    bioController.dispose();
    super.dispose();
  }
}
