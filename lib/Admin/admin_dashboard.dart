import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:digitalrationsystem/Admin/send_notification_screen.dart';
import 'package:digitalrationsystem/Admin/add_stock_screen.dart';
import 'package:digitalrationsystem/Admin/user_complaints_view_screen.dart';
import 'package:digitalrationsystem/Admin/allocated_stock_screen.dart'; // Import AllocatedStockScreen
import '../Firebase/auth_screen.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String adminName = "Government Officer"; // Default name before fetching

  @override
  void initState() {
    super.initState();
    fetchAdminName();
  }

  void fetchAdminName() async {
    User? user = auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
      await firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        setState(() {
          adminName = userDoc['name'] ?? "Government Officer"; // Fetch name or use default
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Government Officer Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    adminName, // Display Admin's Name
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text("LogOut", style: TextStyle(color: Colors.red)),
              onTap: () async {
                await auth.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => AuthScreen()),
                      (route) => false, // Removes all previous routes
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Card(
                child: ListTile(
                  leading: Icon(Icons.account_circle, size: 30, color: Colors.blueAccent),
                  title: Text(
                    "Welcome, $adminName!", // Display Admin's Name Dynamically
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  subtitle: Text(
                    "Manage stock, notifications, and view complaints.",
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Dashboard Action Cards (Row 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionCard(
                  context,
                  Icons.assignment_turned_in,
                  "Distribute Ration",
                  "Allocate stock to village admins.",
                  AddStockScreen(),
                ),
                _buildActionCard(
                  context,
                  Icons.notifications,
                  "Send Notifications",
                  "Notify users about schemes and updates.",
                  SendNotificationScreen(),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Dashboard Action Cards (Row 2)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionCard(
                  context,
                  Icons.error_outline,
                  "User Complaints",
                  "Review complaints from users.",
                  UserComplaintsViewScreen(),
                ),
                _buildActionCard(
                  context,
                  Icons.storage,
                  "Allocated Stock",
                  "View allocated stock details.",
                  AllocatedStockScreen(), // Added Allocated Stock Screen
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Method to build individual action cards
  Widget _buildActionCard(BuildContext context, IconData icon, String title, String subtitle, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: 150,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.blueAccent),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
