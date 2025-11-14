import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserComplaintsViewScreen extends StatefulWidget {
  @override
  _UserComplaintsViewScreenState createState() =>
      _UserComplaintsViewScreenState();
}

class _UserComplaintsViewScreenState extends State<UserComplaintsViewScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Complaints',style: TextStyle(color: Colors.white,fontWeight:FontWeight.bold),),
        backgroundColor: Colors.blueAccent,
        elevation: 4.0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('complaints')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: Text("No complaints"));
          }

          final complaints = snapshot.data!.docs;

          if (complaints.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No complaints submitted yet.',
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final complaint = complaints[index];
              final title = complaint['title'];
              final description = complaint['description'];
              final timestamp = complaint['timestamp']?.toDate();
              final userId = complaint['userId'];

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  title: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  subtitle: Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.black54),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.check,
                      color: Colors.green,
                    ),
                    onPressed: () {
                      _markComplaintAsResolved(complaint.id);
                    },
                  ),
                  onTap: () {
                    _showComplaintDetails(complaint);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Method to mark the complaint as resolved
  Future<void> _markComplaintAsResolved(String complaintId) async {
    await _firestore.collection('complaints').doc(complaintId).update({
      'status': 'resolved',
    });

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Complaint marked as resolved'),
      duration: Duration(seconds: 2),
    ));
  }

  // Method to show detailed complaint info
  void _showComplaintDetails(DocumentSnapshot complaint) {
    final title = complaint['title'];
    final description = complaint['description'];
    final timestamp = complaint['timestamp']?.toDate();
    final userId = complaint['userId'];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        title: Text(
          'Complaint Details',
          style: TextStyle(color: Colors.blueAccent),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Title: $title',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Description: $description'),
            SizedBox(height: 8),
            Text('Submitted by User ID: $userId'),
            SizedBox(height: 8),
            Text(
              'Submitted on: ${timestamp?.toLocal()}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
