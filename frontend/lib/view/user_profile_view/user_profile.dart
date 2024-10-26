import 'dart:convert';
import 'dart:io';
import 'package:center/view/user_profile_view/available_drivers_view.dart';
import 'package:center/view/user_profile_view/track_order_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:center/view/user_profile_view/edit_profile_view.dart';
import 'package:center/view/user_profile_view/notifications_view.dart';
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

  Future<void> fetchUserProfile() async {
    setState(() => isLoading = true);

    String profileUrl = widget.role == 'wholeseller'
        ? 'http://localhost:5000/api/auth/profile/wholeseller/${widget.userId}'
        : 'http://localhost:5000/api/auth/profile/driver/${widget.userId}';

    try {
      final response = await http.get(Uri.parse(profileUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          name = data['user']['name'] ?? 'Name not available';
          email = data['user']['email'] ?? 'Email not available';
          photoUrl = data['user']['photoUrl'];
        });
      } else {
        showSnackBar('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      showSnackBar('Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
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

  void showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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

      if (pickedFile == null) return;

      setState(() => _profileImage = File(pickedFile.path));

      if (kIsWeb) {
        showSnackBar("Photo upload is currently not supported on the web.");
      } else {
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
        if (response.statusCode == 200) {
          showSnackBar('Profile photo updated successfully');
          await fetchUserProfile();
        } else {
          showSnackBar('Failed to upload photo: ${response.statusCode}');
        }
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
                        ProfileOption(
                          icon: Icons.local_shipping,
                          title: widget.role == 'wholeseller'
                              ? "Available Drivers"
                              : "Track Order",
                          onTap: () {
                            if (widget.role == 'wholeseller') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AvailableDriversView(),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TrackOrderView(
                                    userId: widget.userId,
                                    role: widget.role,
                                  ),
                                ),
                              );
                            }
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
                                      foregroundColor: Colors.red,
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
