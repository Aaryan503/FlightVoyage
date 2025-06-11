import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart' as app_user;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';


//to track and get the total miles of the user
final userDocProvider = StreamProvider<app_user.User?>((ref) {
  final firebaseUser = ref.watch(currentUserProvider);
  if (firebaseUser == null) return Stream.value(null);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(firebaseUser.uid)
      .snapshots()
      .map((doc) => doc.exists ? app_user.User.fromFirestore(doc.id, doc.data()!) : null);
});

/// Function to change the user's profile picture
Future<void> _changeProfilePicture(BuildContext context, String uid) async {
  final picker = ImagePicker();

  // Show a bottom sheet to choose source
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.photo_library),
            title: Text('Choose from Gallery'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Take a Photo'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
        ],
      ),
    ),
  );

  if (source == null) return;

  final pickedFile = await picker.pickImage(source: source);

  if (pickedFile != null) {
    final file = File(pickedFile.path);
    final storageRef = FirebaseStorage.instance.ref().child('profile_pictures/$uid.jpg');
    await storageRef.putFile(file);
    final downloadUrl = await storageRef.getDownloadURL();
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'photoURL': downloadUrl,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile picture updated!')),
    );
  }
}

class LoyaltyWidget extends StatelessWidget {
  final double totalMiles;
  const LoyaltyWidget({Key? key, required this.totalMiles}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String tier = 'Bronze';
    double discount = 0.0;
    Color tierColor = Colors.brown.shade400;
    if (totalMiles >= 100000) {
      tier = 'Gold';
      discount = 0.10;
      tierColor = Colors.amber.shade700;
    } else if (totalMiles >= 50000) {
      tier = 'Silver';
      discount = 0.05;
      tierColor = Colors.grey.shade400;
    }
    return Card(
      margin: EdgeInsets.symmetric(vertical: 24),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.workspace_premium, color: tierColor, size: 32),
                SizedBox(width: 12),
                Text(
                  'Loyalty Program',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Your Miles: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text(totalMiles.toStringAsFixed(0), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: tierColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$tier Tier',
                    style: TextStyle(
                      color: tierColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 18),
            Text('Tiers & Discounts:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            SizedBox(height: 10),
            _buildTierRow('Bronze', '0 - 49,999 miles', '0%', Colors.brown.shade400, tier == 'Bronze'),
            _buildTierRow('Silver', '50,000 - 99,999 miles', '5%', Colors.grey.shade400, tier == 'Silver'),
            _buildTierRow('Gold', '100,000+ miles', '10%', Colors.amber.shade700, tier == 'Gold'),
            SizedBox(height: 8),
            Divider(),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.local_offer, color: Colors.green.shade700, size: 20),
                SizedBox(width: 6),
                Text(
                  'Current Discount: ',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${(discount * 100).toStringAsFixed(0)}%',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierRow(String tier, String range, String discount, Color color, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.circle, color: color, size: isActive ? 16 : 12),
          SizedBox(width: 8),
          Text(
            tier,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: color,
              fontSize: 15,
            ),
          ),
          SizedBox(width: 12),
          Text(range, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
          Spacer(),
          Text(discount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue.shade700)),
        ],
      ),
    );
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDocAsync = ref.watch(userDocProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final isLoading = ref.watch(isLoadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.blue.shade400],
            ),
          ),
        ),
      ),
      body: userDocAsync.when(
        data: (user) {
          if (user == null) {
            return Center(child: Text('No user info available'));
          }
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundImage: user.photoURL != null
                              ? NetworkImage(user.photoURL!)
                              : null,
                          child: user.photoURL == null
                              ? Icon(Icons.person, size: 36)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _changeProfilePicture(context, user.uid),
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.blue,
                              child: Icon(Icons.edit, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.displayName.isNotEmpty ? user.displayName : 'No Name',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.flight, color: Colors.blue.shade400, size: 20),
                              SizedBox(width: 6),
                              Text(
                                'Total Miles: ',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.blue.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                user.totalMiles.toStringAsFixed(0),
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.blue.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
                Divider(),
                SizedBox(height: 20),
                Text(
                  'Account',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue.shade800,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () async {
                          await authNotifier.signOut();
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                  icon: isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(Icons.logout),
                  label: Text(isLoading ? 'Signing out...' : 'Sign Out'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    minimumSize: Size(140, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                LoyaltyWidget(totalMiles: user.totalMiles),
              ],
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading user info')),
      ),
    );
  }
}
