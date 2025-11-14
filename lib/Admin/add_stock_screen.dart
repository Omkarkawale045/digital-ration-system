import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddStockScreen extends StatefulWidget {
  @override
  _AddStockScreenState createState() => _AddStockScreenState();
}

class _AddStockScreenState extends State<AddStockScreen> {

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  String? _selectedVillageAdmin;
  String? _selectedStockItem;
  String? _adminId;
  int? _quantity;
  bool isLoading = false;

  List<Map<String, dynamic>> villageAdmins = [];
  List<String> stockItems = [];

  void showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    fetchAdmins();
    fetchStock();
  }

  void _addStockToAdmin() async {
    if (_selectedVillageAdmin == null || _selectedStockItem == null || _quantity == null || _adminId == null) {
      showMessage("Please fill all the fields", success: false);
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      await firestore.collection('stock').add({
        'admin': _selectedVillageAdmin,
        'id': _adminId,
        'stockItem': _selectedStockItem,
        'quantity': _quantity,
        'timestamp': FieldValue.serverTimestamp(),
      });

      showMessage('Stock "$_selectedStockItem" has been added to $_selectedVillageAdmin with quantity $_quantity.', success: true);

      setState(() {
        _formKey.currentState?.reset();
        _selectedVillageAdmin = null;
        _selectedStockItem = null;
        _quantity = null;
        isLoading = false;
      });
    } catch (e) {
      showMessage("Error adding stock: $e", success: false);
      setState(() {
        isLoading = false;
      });
    }
  }

  void fetchAdmins() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
          .collection("users")
          .where('role', isEqualTo: 'allocated_admin')
          .get();

      if (snapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> admins = snapshot.docs
            .map((doc) => {
          "id": doc.id.toString(),
          "name": doc.data()['name'].toString()
        })
            .toList();

        setState(() {
          villageAdmins = admins;
        });
      } else {
        print("No village admins found");
      }
    } catch (e) {
      print("Error fetching admins: $e");
    }
  }

  void fetchStock() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
          .collection("stockName").get();

      if (snapshot.docs.isNotEmpty) {
        List<String> stock = snapshot.docs
            .map((doc) => doc.data()['itemName'].toString())
            .toList();

        setState(() {
          stockItems = stock;
        });
      } else {
        print("No stock item found");
      }
    } catch (e) {
      print("Error fetching stock: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Stock to Village Admin',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Assign Stock to Village Admin',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              villageAdmins.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : _buildDropdownField(
                label: 'Select Village Admin',
                value: _selectedVillageAdmin,
                items: villageAdmins.map((admin) => admin['name'].toString()).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedVillageAdmin = value;
                    _adminId = villageAdmins.firstWhere((admin) => admin['name'] == value)['id'];
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a Village Admin';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildDropdownField(
                label: 'Select Stock Item',
                value: _selectedStockItem,
                items: stockItems,
                onChanged: (value) {
                  setState(() {
                    _selectedStockItem = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a Stock Item';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildTextField(
                label: 'Quantity',
                hintText: 'Enter the quantity of the stock item',
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _quantity = int.tryParse(value!);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),
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
                      _addStockToAdmin();
                    }
                  },
                  child: Text(
                    'Add Stock',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required FormFieldValidator<String> validator,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      value: value,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      onSaved: onSaved,
      validator: validator,
    );
  }
}


