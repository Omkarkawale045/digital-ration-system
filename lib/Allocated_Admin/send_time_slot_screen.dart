import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SendTimeSlotsScreen extends StatefulWidget {
  @override
  _SendTimeSlotsScreenState createState() => _SendTimeSlotsScreenState();
}

class _SendTimeSlotsScreenState extends State<SendTimeSlotsScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  String? selectedTimeSlot;
  bool isLoading = false;

  List<String> timeSlots = [];
  List<String> users = [];
  List<String> selectedUsers = [];

  @override
  void initState() {
    super.initState();
    isLoading = true;
    fetchUsers();
    fetchTimeSlots();
  }

  // Fetch the list of users from Firestore
  void fetchUsers() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
          .collection("users")
          .where('role', isEqualTo: 'user')
          .get();

      if (snapshot.docs.isNotEmpty) {
        List<String> fetchedUsers = snapshot.docs
            .map((doc) => doc.data()['name'].toString())
            .toList();
        setState(() {
          users = fetchedUsers; // Update the users list
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false; // No users found
        });
      }
    } catch (e) {
      print("Error fetching users: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fetch time slots from Firestore
  void fetchTimeSlots() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
          .collection("timeSlots")
          .get();

      if (snapshot.docs.isNotEmpty) {
        List<String> timeSlotFetched = snapshot.docs
            .map((doc) => doc.data()['TimeSlot'].toString())
            .toList();
        setState(() {
          timeSlots = timeSlotFetched; // Update time slots
        });
      }
    } catch (e) {
      print("Error fetching time slots: $e");
    }
  }

  // Show the dialog with a list of checkboxes for selecting multiple users
  void _showUserSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Users'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  children: users.map((user) {
                    return CheckboxListTile(
                      title: Text(user),
                      value: selectedUsers.contains(user),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedUsers.add(user);
                          } else {
                            selectedUsers.remove(user);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {});
              },
              child: Text('Done'),
            ),
          ],
        );
      },
    );
  }

  // Send the selected time slot and users
  void _sendTimeSlot() {
    if (selectedUsers.isEmpty || selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select at least one user and a time slot."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Time Slot"),
        content: Text("Send '$selectedTimeSlot' to ${selectedUsers.join(", ")}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Time Slot Sent to ${selectedUsers.join(", ")}: $selectedTimeSlot"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text("Confirm"),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blueAccent,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Send Time Slots to Users",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            // User Selection Box (TextField that opens the selection dialog)
            Text(
              "Select Users:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: _showUserSelectionDialog,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedUsers.isEmpty
                            ? "Choose Users"
                            : selectedUsers.join(", "),
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Time Slot Selection Box
            Text(
              "Select Time Slot:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: DropdownButton<String>(
                  hint: Text("Choose a Time Slot", style: TextStyle(color: Colors.black54)),
                  value: selectedTimeSlot,
                  isExpanded: true,
                  underline: SizedBox(), // Remove the underline
                  items: timeSlots.map((String slot) {
                    return DropdownMenuItem<String>(
                      value: slot,
                      child: Text(slot, style: TextStyle(color: Colors.black87)),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedTimeSlot = value;
                    });
                  },
                  style: TextStyle(color: Colors.black87, fontSize: 16),
                  icon: Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
                ),
              ),
            ),
            SizedBox(height: 25),

            // Send Button
            Center(
              child: ElevatedButton.icon(
                onPressed: _sendTimeSlot,
                icon: Icon(Icons.send, color: Colors.white),
                label: Text("Send Time Slot", style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
