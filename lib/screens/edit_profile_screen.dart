import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'dart:io'; // Import dart:io for File
import 'package:path_provider/path_provider.dart'; // Import path_provider
import 'package:path/path.dart' as p; // Import path package for join

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  User? _currentUser;
  late Box<User> _userBox;
  File? _imageFile; // Variable to store the selected image file

  @override
  void initState() {
    super.initState();
    _userBox = Hive.box<User>('userBox');
    _loadUserData();
  }

  void _loadUserData() {
    if (_userBox.isNotEmpty) {
      _currentUser = _userBox.getAt(0);
      if (_currentUser!.profilePicturePath.isNotEmpty &&
          _currentUser!.profilePicturePath != 'assets/images/default_profile.png') {
        _imageFile = File(_currentUser!.profilePicturePath);
      }
    } else {
      // Create a default user if none exists
      _currentUser = User(
        fullName: 'Nama User',
        username: 'user_name',
        email: 'email@example.com',
        phoneNumber: '081234567890',
      );
      _userBox.add(_currentUser!);
    }

    _fullNameController.text = _currentUser!.fullName;
    _usernameController.text = _currentUser!.username;
    _emailController.text = _currentUser!.email;
    _phoneController.text = _currentUser!.phoneNumber;
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Get the application's documents directory
      final appDocDir = await getApplicationDocumentsDirectory();
      final appDocPath = appDocDir.path;

      // Create a unique file name
      final fileName = p.basename(pickedFile.path);
      final localImage = await File(pickedFile.path).copy('$appDocPath/$fileName');

      setState(() {
        _imageFile = localImage;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_currentUser != null) {
      _currentUser!.fullName = _fullNameController.text;
      _currentUser!.username = _usernameController.text;
      _currentUser!.email = _emailController.text;
      _currentUser!.phoneNumber = _phoneController.text;
      
      if (_imageFile != null) {
        _currentUser!.profilePicturePath = _imageFile!.path;
      }

      await _currentUser!.save(); // Save changes to Hive
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!')),
      );
      Navigator.pop(context, _currentUser); // Pass updated user back
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!) as ImageProvider<Object>
                        : AssetImage(_currentUser?.profilePicturePath ?? 'assets/images/default_profile.png'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickImage, // Call _pickImage when camera icon is tapped
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password change not implemented yet.')),
                );
              },
              child: const Text('Change Password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
