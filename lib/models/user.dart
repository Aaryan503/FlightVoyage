import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String displayName;
  final String email;
  final String? photoURL;
  final DateTime createdAt;
  final double totalMiles;

  User({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoURL,
    required this.createdAt,
    this.totalMiles = 0,
  });

  factory User.fromFirestore(String uid, Map<String, dynamic> data) {
    return User(
      uid: uid,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      photoURL: data['photoURL'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      totalMiles: (data['totalMiles'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
      'createdAt': createdAt,
      'totalMiles': totalMiles,
    };
  }
} 