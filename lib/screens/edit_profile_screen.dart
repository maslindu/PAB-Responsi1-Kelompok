import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';

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
  // Password is not stored directly, only for change
  // final TextEditingController _passwordController = TextEditingController();

  User? _currentUser;
  late Box<User> _userBox;

  @override
  void initState() {
    super.initState();
    _userBox = Hive.box<User>('userBox');
    _loadUserData();
  }

  void _loadUserData() {
    if (_userBox.isNotEmpty) {
      _currentUser = _userBox.getAt(0);
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

  Future<void> _saveProfile() async {
    if (_currentUser != null) {
      _currentUser!.fullName = _fullNameController.text;
      _currentUser!.username = _usernameController.text;
      _currentUser!.email = _emailController.text;
      _currentUser!.phoneNumber = _phoneController.text;
      // Password change logic would go here, not directly saving the password text

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
    // _passwordController.dispose(); // No longer needed if not storing password
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
                    backgroundImage: AssetImage(_currentUser?.profilePicturePath ?? 'assets/images/default_profile.png'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () {
                        // TODO: Implement photo change
                      },
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
            // For password change, you might want a separate dialog or a more secure input
            // TextField(
            //   controller: _passwordController,
            //   decoration: const InputDecoration(
            //     labelText: 'Change Password',
            //     border: OutlineInputBorder(),
            //   ),
            //   obscureText: true,
            // ),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement password change logic
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
