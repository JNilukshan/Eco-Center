import 'dart:convert';
import 'dart:io';
import 'package:center/view/user_profile_view/available_drivers_view.dart';
import 'package:center/view/user_profile_view/notifications_view.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:center/view/user_profile_view/edit_profile_view.dart';
import 'package:center/view/main_tabview/main_tabview.dart';
import 'package:center/view/main_tabview/dtru_main_tab.dart';
import 'package:center/view/login/loginView.dart';
import 'package:center/common/color_extrnsion.dart';

class UserProfileView extends StatefulWidget {
  final String userId;
  final String role;

  const UserProfileView({super.key, required this.userId, required this.role});

  @override
  _UserProfileViewState createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  File? _profileImage;
  String? name;
  String? email;
  String? photoUrl;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  void showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> saveUserData(String userId, String name, String email,
      String role, String? photoUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setString('name', name);
    await prefs.setString('email', email);
    await prefs.setString('role', role);
    if (photoUrl != null) {
      await prefs.setString('photoUrl', photoUrl);
    }
  }

  Future<void> fetchUserProfile() async {
    setState(() => isLoading = true);

    String profileUrl = widget.role == 'wholeseller'
        ? 'http://localhost:5000/api/auth/profile/wholeseller/${widget.userId}'
        : 'http://localhost:5000/api/auth/profile/driver/${widget.userId}';

    try {
      final response = await http.get(Uri.parse(profileUrl));
      print("API response status: ${response.statusCode}");
      print("API response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data != null) {
          setState(() {
            name = data['name'] ?? 'Name not available';
            email = data['email'] ?? 'Email not available';
            photoUrl = data['photo'] != null
                ? 'http://localhost:5000/uploads/profile-photos/${data['photo']}' // Construct full URL
                : null;
          });

          await saveUserData(
              widget.userId, name!, email!, widget.role, photoUrl);
        } else {
          showSnackBar('User data is not available');
          await loadUserDataFromPrefs();
        }
      } else {
        showSnackBar('Failed to load profile: ${response.statusCode}');
        await loadUserDataFromPrefs();
      }
    } catch (e) {
      showSnackBar('Error: $e');
      await loadUserDataFromPrefs();
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> loadUserDataFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? 'Name not available';
      email = prefs.getString('email') ?? 'Email not available';
      photoUrl = prefs.getString('photoUrl');
    });
  }

  ImageProvider<Object> _getProfileImage() {
    if (_profileImage != null) {
      return FileImage(_profileImage!);
    } else if (photoUrl != null && photoUrl!.isNotEmpty) {
      return NetworkImage(photoUrl!);
    } else {
      return const AssetImage('assets/img/default_avatar.png');
    }
  }

  Future<void> _pickImageAndUpload(String userId) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 800,
        maxWidth: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        showSnackBar('No image selected');
        return;
      }

      setState(() => _profileImage = File(pickedFile.path));

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('http://localhost:5000/api/auth/profile/photo/$userId'),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          pickedFile.path,
        ),
      );

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        final newPhotoUrl =
            'http://localhost:5000/uploads/profile-photos/${data['photo']}';
        await saveUserData(
            widget.userId, name ?? "", email ?? "", widget.role, newPhotoUrl);
        setState(() {
          photoUrl = newPhotoUrl;
        });
        showSnackBar('Profile photo updated successfully');
      } else {
        showSnackBar('Failed to upload photo: ${response.statusCode}');
      }
    } catch (e) {
      showSnackBar('Error uploading photo: $e');
    }
  }

  Future<void> deleteAccount() async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:5000/api/auth/delete-account'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': widget.userId,
          'role': widget.role,
        }),
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        if (!mounted) return;
        showSnackBar('Account deleted successfully');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => LoginView(
              userId: widget.userId,
            ),
          ),
          (Route<dynamic> route) => false,
        );
      } else {
        showSnackBar('Failed to delete account: ${response.statusCode}');
      }
    } catch (e) {
      showSnackBar('Error deleting account: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: TColor.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.role == 'wholeseller') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MainTabView(
                    userId: widget.userId,
                    role: widget.role,
                  ),
                ),
              );
            } else if (widget.role == 'driver') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => DTruMainTabView(
                    userId: widget.userId,
                    role: widget.role,
                  ),
                ),
              );
            }
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: _getProfileImage(),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  padding: const EdgeInsets.all(0),
                                  icon: Icon(Icons.edit,
                                      color: TColor.primary, size: 20),
                                  onPressed: () =>
                                      _pickImageAndUpload(widget.userId),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          name ?? 'Loading...',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          email ?? 'Loading...',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView(
                      children: [
                        ProfileOption(
                          icon: Icons.edit,
                          title: "Edit Profile",
                          onTap: () async {
                            final updatedData = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfileView(
                                  userId: widget.userId,
                                  role: widget.role,
                                ),
                              ),
                            );

                            if (updatedData != null) {
                              setState(() {
                                name = updatedData['name'];
                                email = updatedData['email'];
                              });
                            }
                          },
                        ),
                        if (widget.role != 'driver')
                          ProfileOption(
                            icon: Icons.notifications,
                            title: "Notifications",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NotificationsView(
                                    userId: widget.userId,
                                    role: widget.role,
                                  ),
                                ),
                              );
                            },
                          ),
                        if (widget.role != 'driver')
                          ProfileOption(
                            icon: Icons.local_shipping,
                            title: "Available Drivers",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AvailableDriversView(),
                                ),
                              );
                            },
                          ),
                        ProfileOption(
                          icon: Icons.delete_forever,
                          title: "Delete Account",
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Delete Account"),
                                content: const Text(
                                    "Are you sure you want to delete your account? This action cannot be undone."),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      deleteAccount();
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: TColor.primary,
                                    ),
                                    child: const Text("Delete Account"),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ProfileOption({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: TColor.primary),
      title: Text(title),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}
