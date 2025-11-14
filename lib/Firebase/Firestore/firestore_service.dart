import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save user to Firestore
  static Future<void> createUser(String uid, String email, String role, String name) async {
    if (FirebaseAuth.instance.currentUser == null) {
      throw Exception("User not authenticated.");
    }

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'id': uid,  // Set ID same as Firebase Auth UID
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'createdAt': Timestamp.now(),
    });
  }



  // Get user role from Firestore
  static Future<String> getUserRole(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        return userDoc['role'];
      } else {
        throw Exception("Role not found for user.");

      }
    } catch (e) {
      throw Exception("Error fetching user role: $e");
    }
  }

}
