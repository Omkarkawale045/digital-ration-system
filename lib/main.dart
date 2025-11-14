import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Firebase/auth_screen.dart'; // Authentication screen
import 'home_screen.dart'; // Home screen
import 'Admin/admin_dashboard.dart';
import 'Allocated_Admin/allocated_admin_dashboard.dart';
import 'User/user_dashboard.dart';
import 'Firebase/Firestore/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Role-Based Authentication',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthWrapper(), // Start with the authentication screen
      routes: {
        '/home': (context) => HomeScreen(user: FirebaseAuth.instance.currentUser ),
        '/admin': (context) => AdminDashboard(),
        '/allocated_admin': (context) => AllocatedAdminDashboard(),
        '/user': (context) => UserDashboard(),
      },
    );
  }
}