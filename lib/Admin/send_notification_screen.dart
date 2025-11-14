import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SendNotificationScreen extends StatefulWidget {
  @override
  _SendNotificationScreenState createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _notificationTitle;
  String? _notificationMessage;

  void showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Send Notification',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Send Notification to Users",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 16),

                // Title Input
                _buildInputField(
                  label: 'Notification Title',
                  hint: 'Enter the title of the notification',
                  onSaved: (value) {
                    _notificationTitle = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a notification title';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Message Input
                _buildInputField(
                  label: 'Notification Message',
                  hint: 'Enter the message for the notification',
                  maxLines: 4,
                  onSaved: (value) {
                    _notificationMessage = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a notification message';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 32),

                // Send Button
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        _formKey.currentState?.save();
                        _sendNotification();
                      }
                    },
                    child: Text(
                      'Send Notification',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Custom method to build the input fields
  Widget _buildInputField({
    required String label,
    required String hint,
    int? maxLines,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blueAccent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
        ),
      ),
      maxLines: maxLines ?? 1,
      onSaved: onSaved,
      validator: validator,
      style: TextStyle(fontSize: 16),
    );
  }

  // Method to send notification to all users
  void _sendNotification() async {
    final url = "https://your-cloud-function-url/sendNotificationToAll"; // Replace with your deployed Cloud Function URL

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "title": _notificationTitle,
        "message": _notificationMessage,
      }),
    );

    if (response.statusCode == 200) {
      showMessage('Notification sent Successfully!', success: true);
      _formKey.currentState?.reset();
    } else {
      showMessage("Failed to send notification", success: false);
    }
  }
}
