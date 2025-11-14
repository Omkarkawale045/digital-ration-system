import 'package:digitalrationsystem/Allocated_Admin/available_stock_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digitalrationsystem/Allocated_Admin/ration_distribution_details_screen.dart';
import 'package:digitalrationsystem/Allocated_Admin/send_time_slot_screen.dart';
import 'package:digitalrationsystem/Allocated_Admin/ditribute_ration_screen.dart';
import 'package:digitalrationsystem/Firebase/auth_screen.dart';

class AllocatedAdminDashboard extends StatefulWidget {
  @override
  _AllocatedAdminDashboardState createState() => _AllocatedAdminDashboardState();
}

class _AllocatedAdminDashboardState extends State<AllocatedAdminDashboard> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String adminName = "Allocated Admin"; // Default name before fetching

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
          adminName = userDoc['name'] ?? "Allocated Admin"; // Fetch name or use default
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Allocated Admin Dashboard",
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
                    adminName, // Display allocated admin's name
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
              title: Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () async {
                await auth.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => AuthScreen()),
                      (route) => false,
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
                    "Welcome, $adminName!", // Display admin's name dynamically
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  subtitle: Text(
                    "Manage ration distribution, time slots, and details",
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Dashboard Action Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionCard(
                  context,
                  Icons.delivery_dining,
                  "Distribute Ration",
                  "Allocate ration to users.",
                  DistributeRationScreen(),
                ),
                _buildActionCard(
                  context,
                  Icons.list_alt,
                  "Distribution Details",
                  "View allocation history and records.",
                  RationDistributionDetailsScreen(),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionCard(
                  context,
                  Icons.access_time,
                  "Send Time Slots",
                  "Notify users about ration collection time slots.",
                  SendTimeSlotsScreen(),
                ),
                _buildActionCard(
                  context,
                  Icons.list_alt_sharp,
                  "View Stock",
                  "View Your Allocated Stock Details.",
                  AvailableStockScreen(),
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
