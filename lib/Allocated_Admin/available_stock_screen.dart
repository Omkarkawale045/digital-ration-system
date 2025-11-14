// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// class AvailableStockScreen extends StatefulWidget {
//   const AvailableStockScreen({super.key});
//
//   @override
//   State<AvailableStockScreen> createState() => _AvailableStockScreenState();
// }
//
// class _AvailableStockScreenState extends State<AvailableStockScreen> {
//   FirebaseFirestore firestore = FirebaseFirestore.instance;
//   FirebaseAuth auth = FirebaseAuth.instance;
//   @override
//   Widget build(BuildContext context) {
//     return  Scaffold(
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('stock')
//             .where("id", isEqualTo: auth.currentUser!.uid)
//             .orderBy('timestamp', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//
//           print(snapshot.data);
//           if (snapshot.hasError) {
//             return Center(child: Text("Error fetching data"));
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(child: Text("No allocated stock available"));
//           }
//
//           var stockList = snapshot.data!.docs;
//
//           // Group stock items by admin
//           Map<String, List<Map<String, dynamic>>> groupedStocks = {};
//
//           for (var doc in stockList) {
//             var stock = doc.data() as Map<String, dynamic>;
//             String admin = stock['admin'] ?? 'Unknown';
//
//             if (!groupedStocks.containsKey(admin)) {
//               groupedStocks[admin] = [];
//             }
//             groupedStocks[admin]!.add(stock);
//           }
//
//           return ListView.builder(
//             padding: EdgeInsets.all(12.0),
//             itemCount: groupedStocks.keys.length,
//             itemBuilder: (context, index) {
//               String admin = groupedStocks.keys.elementAt(index);
//               List<Map<String, dynamic>> adminStockList = groupedStocks[admin]!;
//
//               return Card(
//                 elevation: 5,
//                 margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Padding(
//                   padding: EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Village Admin: $admin",
//                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                       ),
//                       Divider(),
//                       ...adminStockList.map((stock) {
//                         // Extract timestamp and format it
//                         Timestamp? timestamp = stock['timestamp'] as Timestamp?;
//                         String formattedDate = timestamp != null
//                             ? DateFormat('yyyy-MM-dd hh:mm a').format(timestamp.toDate())
//                             : "Unknown Date";
//
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 4.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(

//                                 "${stock['stockItem'] ?? 'Unknown'} - ${stock['quantity'] ?? '0'}",
//                                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.green),
//                               ),
//                               Text(
//                                 "Allocated on: $formattedDate",
//                                 style: TextStyle(fontSize: 12, color: Colors.black54),
//                               ),
//                             ],
//                           ),
//                         );
//                       }).toList(),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AvailableStockScreen extends StatefulWidget {
  const AvailableStockScreen({super.key});

  @override
  State<AvailableStockScreen> createState() => _AvailableStockScreenState();
}

class _AvailableStockScreenState extends State<AvailableStockScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Available Stock',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('stock')
            .where("id", isEqualTo: auth.currentUser!.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text(
                  "Error fetching data",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                ));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          var stockList = snapshot.data!.docs;

          // Group stock items by admin
          Map<String, List<Map<String, dynamic>>> groupedStocks = {};

          for (var doc in stockList) {
            var stock = doc.data() as Map<String, dynamic>;
            String admin = stock['admin'] ?? 'Unknown';

            if (!groupedStocks.containsKey(admin)) {
              groupedStocks[admin] = [];
            }
            groupedStocks[admin]!.add(stock);
          }

          return ListView.builder(
            padding: EdgeInsets.all(12.0),
            itemCount: groupedStocks.keys.length,
            itemBuilder: (context, index) {
              String admin = groupedStocks.keys.elementAt(index);
              List<Map<String, dynamic>> adminStockList = groupedStocks[admin]!;

              return _buildStockCard(admin, adminStockList);
            },
          );
        },
      ),
    );
  }

  /// **Widget for Empty State**
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade400),
          SizedBox(height: 16),
          Text(
            "No allocated stock available",
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  /// **Widget for Stock Card**
  Widget _buildStockCard(String admin, List<Map<String, dynamic>> stockList) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.account_circle, color: Colors.white),
              ),
              title: Text(
                "Village Admin: $admin",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
            ),
            Divider(),
            ...stockList.map((stock) {
              Timestamp? timestamp = stock['timestamp'] as Timestamp?;
              String formattedDate = timestamp != null
                  ? DateFormat('yyyy-MM-dd hh:mm a').format(timestamp.toDate())
                  : "Unknown Date";

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stock['stockItem'] ?? 'Unknown Item',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
                        ),
                        Text(
                          "Allocated on: $formattedDate",
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${stock['quantity'] ?? '0'}",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
