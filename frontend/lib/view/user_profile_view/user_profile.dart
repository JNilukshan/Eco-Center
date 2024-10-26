import 'dart:convert';
import 'package:center/view/user_profile_view/notifications_view.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:center/view/user_profile_view/edit_profile_view.dart';
import 'package:center/view/user_profile_view/track_order_view.dart';
import 'package:center/common/color_extrnsion.dart';
import 'package:center/view/login/loginView.dart';

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
  String? base64Photo;
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
          base64Photo = data['user']['photo'];
        });
      } else {
        showSnackBar('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      showSnackBar('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _pickImageAndUpload(String userId) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      try {
        var response = await http.put(
          Uri.parse('http://localhost:5000/api/auth/profile/photo/$userId'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'photo': base64Image}),
        );

        if (response.statusCode == 200) {
          showSnackBar('Profile photo updated successfully');
          await fetchUserProfile();
        } else {
          showSnackBar('Failed to upload photo: ${response.statusCode}');
        }
      } catch (e) {
        showSnackBar('Error uploading photo: $e');
      }
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    
    try {
      // Attempt server logout
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/auth/logout'),
      );

      if (response.statusCode == 200) {
        // Clear all stored user data
        await prefs.clear();
        
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const LoginView(userId: ''),
          ),
          (Route<dynamic> route) => false,
        );
      } else {
        if (!mounted) return;
        showSnackBar('Server logout failed. Please try again.');
      }
    } catch (e) {
      // Even if server logout fails, clear local data and redirect to login
      await prefs.clear();
      
      if (!mounted) return;
      showSnackBar('Error during logout: $e');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginView(userId: ''),
        ),
        (Route<dynamic> route) => false,
      );
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
            builder: (context) => const LoginView(userId: ''),
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
          onPressed: () => Navigator.pop(context),
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
                              backgroundImage: _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : (base64Photo != null && base64Photo!.isNotEmpty
                                      ? MemoryImage(base64Decode(base64Photo!))
                                      : const AssetImage('assets/img/pro-2.jpeg'))
                                  as ImageProvider,
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
                                builder: (context) => const NotificationsView(),
                              ),
                            );
                          },
                        ),
                        ProfileOption(
                          icon: Icons.local_shipping,
                          title: "Track Order",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TrackOrderView(),
                              ),
                            );
                          },
                        ),
                        ProfileOption(
                          icon: Icons.logout,
                          title: "Logout",
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Logout"),
                                content: const Text(
                                    "Are you sure you want to log out?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      logout();
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    child: const Text("Logout"),
                                  ),
                                ],
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
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}