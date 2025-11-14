import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Firebase/auth_screen.dart';
import 'Admin/admin_dashboard.dart';
import 'Allocated_Admin/allocated_admin_dashboard.dart';
import 'User/BottomNavigationBar.dart';
import 'User/user_dashboard.dart';

class HomeScreen extends StatelessWidget {
  final User? user;
  HomeScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return AuthScreen();
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user!.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            body: Center(child: Text("User  data not found.")),
          );
        }

        String role = snapshot.data!['role'];
        if (role == 'admin') {
          return AdminDashboard();
        } else if (role == 'allocated_admin') {
          return AllocatedAdminDashboard();
        } else {
          return Bottomnavigationbar();
        }
      },
    );
  }
}