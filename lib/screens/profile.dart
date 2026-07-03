import 'package:flutter/material.dart';
import 'package:thala_buddy/screens/onboarding.dart'; 
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  static const Color primaryRed = Color.fromARGB(255, 183, 38, 38); 
  
  late Future<Map<String, String?>> _profileDataFuture;

  @override
  void initState() {
    super.initState();
    _profileDataFuture = _loadProfileData(); 
  }

  Future<Map<String, String?>> _loadProfileData() async {
    final sp = await SharedPreferences.getInstance();
    return {
      'name': sp.getString('name'),
      'surname': sp.getString('surname'),
      'gender': sp.getString('gender'),
      'dob': sp.getString('dob'),
      'height': sp.getString('height'), 
      'weight': sp.getString('weight'), 
    };
  }

  // Pop up logout 
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          backgroundColor: Colors.white,
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.logout_rounded, color: primaryRed, size: 36),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Log Out?',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Are you sure you want to log out? You will need to sign in again to access your data.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.4),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey.shade300, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Cancel', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final sp = await SharedPreferences.getInstance();
                          await sp.remove('username');
                          await sp.remove('password');
                          
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop(); 
                            Navigator.pushReplacementNamed(context, '/login/');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryRed,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Logout', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Pop up delete account 
  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          backgroundColor: Colors.white,
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person_remove_rounded, color: Colors.red.shade700, size: 36),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Delete Account?',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Are you sure you want to delete your profile? All your data will be permanently removed. This action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.black54, height: 1.4),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey.shade300, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Cancel', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final sp = await SharedPreferences.getInstance();
                          await sp.clear();
                          
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop(); 
                            Navigator.pushReplacementNamed(context, '/login/');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Delete', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile', 
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w400, color: primaryRed),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 10, bottom: 20),
          child: FutureBuilder<Map<String, String?>>(
            future: _profileDataFuture, 
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator(color: primaryRed));
              }
              final data = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Info about yourself", 
                    style: TextStyle(fontSize: 20, color: Colors.black54, fontWeight: FontWeight.w300),
                  ),
                  const SizedBox(height: 20),
                  
                  _buildProfileData('Name', data['name']),
                  _buildProfileData('Surname', data['surname']),
                  _buildProfileData('Gender', data['gender']),
                  _buildProfileData('Date of Birth', data['dob']),
                  _buildProfileData('Height', data['height'] != null ? "${data['height']} cm" : null),
                  _buildProfileData('Weight', data['weight'] != null ? "${data['weight']} kg" : null),
                  
                  const Spacer(),
                  
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Onboarding()),
                        );
                        
                        if (result == true) {
                          setState(() {
                            _profileDataFuture = _loadProfileData();
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(200, 50),
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      child: const Text('Edit Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  Center(
                    child: TextButton(
                      onPressed: () => _showLogoutDialog(context),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  
                  Center(
                    child: TextButton(
                      onPressed: () => _showDeleteAccountDialog(context),
                      child: const Text(
                        'Delete Account',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileData(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F6F6), 
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black54, fontSize: 16)),
            const Spacer(),
            Text(
              value ?? 'Not set',
              style: TextStyle(
                color: value == null ? Colors.red : Colors.black87,
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}