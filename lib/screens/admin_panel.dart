import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:poshinda_admin/services/auth_service.dart';
import 'package:poshinda_admin/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminPanel extends StatefulWidget {
  final String token;

  const AdminPanel({required this.token, Key? key}) : super(key: key);

  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class Deal {
  final int id;
  final String title;
  final String description;
  final double price;
  final int min_participants;
  final int current_participants;
  final String status;

  Deal({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.min_participants,
    this.current_participants = 0,
    this.status = 'open',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'min_participants': min_participants,
      'current_participants': current_participants,
      'status': status,
    };
  }

  factory Deal.fromJson(Map<String, dynamic> json) {
    return Deal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'].toDouble(),
      min_participants: json['min_participants'],
      current_participants: json['current_participants'] ?? 0,
      status: json['status'] ?? 'open',
    );
  }
}

class _AdminPanelState extends State<AdminPanel> {
  List<Deal> deals = [];
  final _dealFormKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _minParticipantsController = TextEditingController();
  final _authService = AuthService();
  late String _accessToken;

  @override
  void initState() {
    super.initState();
    fetchDeals();
    _parseToken();
  }

  void _parseToken() {
    try {
      final tokenData = json.decode(widget.token);
      _accessToken = tokenData['access_token'];
    } catch (e) {
      // If parsing fails, assume the token is already in the correct format
      _accessToken = widget.token;
    }
  }

  Future<void> fetchDeals() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/deals'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> dealsJson = json.decode(response.body);
        setState(() {
          deals = dealsJson.map((json) => Deal.fromJson(json)).toList();
        });
      } else {
        showToast(context, 'Failed to fetch deals: ${response.statusCode}');
      }
    } catch (e) {
      showToast(context, 'Error fetching deals: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poshinda Admin Panel'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: DealList(
              deals: deals,
              onSelect: (deal) {
                setState(() {
                  _titleController.text = deal.title;
                  _descriptionController.text = deal.description;
                  _priceController.text = deal.price.toString();
                  _minParticipantsController.text = deal.min_participants.toString();
                });
              },
              onDelete: _deleteDeal,
            ), 
          ),
          Expanded(
            flex: 2,
            child: DealForm(
              formKey: _dealFormKey,
              titleController: _titleController,
              descriptionController: _descriptionController,
              priceController: _priceController,
              minParticipantsController: _minParticipantsController,
              onSave: _createDeal,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _dealFormKey.currentState?.reset();
            _titleController.clear();
            _descriptionController.clear();
            _priceController.clear();
            _minParticipantsController.clear();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _createDeal() async {
    if (_dealFormKey.currentState!.validate()) {
      final deal = Deal(
        id: 0, // The server will assign the actual ID
        title: _titleController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        min_participants: int.parse(_minParticipantsController.text),
      );

      try {
        final response = await http.post(
          Uri.parse('http://localhost:5000/deals'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_accessToken',
          },
          body: json.encode(deal.toJson()),
        );

        if (response.statusCode == 201) {
          fetchDeals(); // Refresh the list of deals
          _dealFormKey.currentState?.reset();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Deal created successfully')),
          );
        } else {
          throw Exception('Failed to create deal: ${response.statusCode}');
        }
      } catch (e) {
        print('Error creating deal: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating deal: $e')),
        );
      }
    }
  }

  Future<void> _deleteDeal(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:5000/deals/$id'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );
      if (response.statusCode == 200) {
        fetchDeals();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deal deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete deal: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting deal: $e')),
      );
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged out successfully')),
    );
  }
}

class DealList extends StatelessWidget {
  final List<Deal> deals;
  final Function(Deal) onSelect;
  final Function(String) onDelete;

  const DealList({Key? key, required this.deals, required this.onSelect, required this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: deals.length,
      itemBuilder: (context, index) {
        final deal = deals[index];
        return ListTile(
          title: Text(deal.title),
          subtitle: Text('₹${deal.price.toStringAsFixed(2)}'),
          onTap: () => onSelect(deal),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => onDelete(deal.id.toString()),
          ),
        );
      },
    );
  }
}

class DealForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final TextEditingController minParticipantsController;
  final VoidCallback onSave;

  const DealForm({
    Key? key,
    required this.formKey,
    required this.titleController,
    required this.descriptionController,
    required this.priceController,
    required this.minParticipantsController,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: titleController,
            decoration: InputDecoration(labelText: 'Title'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ),
          TextFormField(
            controller: descriptionController,
            decoration: InputDecoration(labelText: 'Description'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
          ),
          TextFormField(
            controller: priceController,
            decoration: InputDecoration(labelText: 'Price'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a price';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          TextFormField(
            controller: minParticipantsController,
            decoration: InputDecoration(labelText: 'Minimum Participants'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter minimum participants';
              }
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: onSave,
            child: Text('Save Deal'),
          ),
        ],
      ),
    );
  }
}

void showToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    ),
  );
}