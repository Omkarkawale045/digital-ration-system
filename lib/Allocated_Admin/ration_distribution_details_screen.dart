import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RationDistributionDetailsScreen extends StatefulWidget {
  @override
  _RationDistributionDetailsScreenState createState() => _RationDistributionDetailsScreenState();
}

class _RationDistributionDetailsScreenState extends State<RationDistributionDetailsScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Users Allocated Stock',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('distributions').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error fetching data"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No allocated stock available"));
          }

          var stockList = snapshot.data!.docs;

          // Group stock items by user
          Map<String, List<Map<String, dynamic>>> groupedStocks = {};

          for (var doc in stockList) {
            var stock = doc.data() as Map<String, dynamic>;
            String user = stock['admin'] ?? 'Unknown';

            if (!groupedStocks.containsKey(user)) {
              groupedStocks[user] = [];
            }
            groupedStocks[user]!.add(stock);
          }

          return ListView.builder(
            padding: EdgeInsets.all(12.0),
            itemCount: groupedStocks.keys.length,
            itemBuilder: (context, index) {
              String user = groupedStocks.keys.elementAt(index);
              List<Map<String, dynamic>> userStockList = groupedStocks[user]!;

              return Card(
                elevation: 5,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "User Name: $user",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Divider(),
                      ...userStockList.map((stock) {
                        // Extract timestamp and format it
                        Timestamp? timestamp = stock['timestamp'] as Timestamp?;
                        String formattedDate = timestamp != null
                            ? DateFormat('yyyy-MM-dd hh:mm a').format(timestamp.toDate())
                            : "Unknown Date";

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${stock['stockItem'] ?? 'Unknown'} - ${stock['quantity'] ?? '0'}",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.green),
                              ),
                              Text(
                                "Allocated on: $formattedDate",
                                style: TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
