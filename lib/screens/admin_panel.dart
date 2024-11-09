import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:utpanna_admin/services/auth_service.dart';
import 'package:utpanna_admin/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'package:utpanna_admin/screens/deal_detail_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';

class DealImage {
  final int id;
  final String imageUrl;
  final String createdAt;

  DealImage({
    required this.id,
    required this.imageUrl,
    required this.createdAt,
  });

  factory DealImage.fromJson(Map<String, dynamic> json) {
    return DealImage(
      id: json['id'],
      imageUrl: json['image_url'],
      createdAt: json['created_at'],
    );
  }
}

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
  final String created_at;
  final String updated_at;
  final List<Participant>? participants;
  final double? progress_percentage;
  final List<dynamic>? images;

  Deal({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.min_participants,
    this.current_participants = 0,
    this.status = 'open',
    required this.created_at,
    required this.updated_at,
    this.participants,
    this.progress_percentage,
    this.images,
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
      created_at: json['created_at'],
      updated_at: json['updated_at'],
      participants: json['participants'] != null 
          ? (json['participants'] as List)
              .map((p) => Participant.fromJson(p))
              .toList()
          : null,
      progress_percentage: json['progress_percentage']?.toDouble(),
      images: json['images'] as List<dynamic>?,
    );
  }
}

class Participant {
  final int id;
  final String name;
  final String phone_number;
  final String address;
  final String joined_at;

  Participant({
    required this.id,
    required this.name,
    required this.phone_number,
    required this.address,
    required this.joined_at,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'],
      name: json['name'],
      phone_number: json['phone_number'],
      address: json['address'],
      joined_at: json['joined_at'],
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

  @override
  void initState() {
    super.initState();
    // Store token in Constants
    Constants.updateJwtToken(widget.token);
    fetchDeals();
  }

  Future<void> fetchDeals() async {
    try {
      final response = await http.get(
        Uri.parse('${Constants.apiUrl}/deal-list'),
        headers: {
          'Authorization': 'Bearer ${Constants.jwtToken}',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> dealsJson = json.decode(response.body);
        setState(() {
          deals = dealsJson.map((json) => Deal.fromJson(json)).toList();
        });
      } else {
        print('Failed to fetch deals: ${response.statusCode}');
        print('Response body: ${response.body}');
        showToast(context, 'Failed to fetch deals: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching deals: $e');
      if (mounted) {
        showToast(context, 'Error fetching deals: $e');
      }
    }
  }

  Future<void> _createDeal() async {
    if (_dealFormKey.currentState!.validate()) {
      final now = DateTime.now().toIso8601String();
      final deal = Deal(
        id: 0, // The server will assign the actual ID
        title: _titleController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        min_participants: int.parse(_minParticipantsController.text),
        current_participants: 0,
        status: 'open',
        created_at: now,
        updated_at: now,
      );

      try {
        final response = await http.post(
          Uri.parse('${Constants.apiUrl}/deals'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${Constants.jwtToken}',
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
        Uri.parse('${Constants.apiUrl}/deals/$id'),
        headers: {
          'Authorization': 'Bearer ${Constants.jwtToken}',
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
    Constants.updateJwtToken(''); // Clear token from Constants
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged out successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Utpanna Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: DealList(
            deals: deals,
            onDelete: _deleteDeal,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Create New Deal'),
              content: SizedBox(
                height: 400, // Adjust height as needed
                width: 300,  // Adjust width as needed
                child: SingleChildScrollView(
                  child: DealForm(
                    formKey: _dealFormKey,
                    titleController: _titleController,
                    descriptionController: _descriptionController,
                    priceController: _priceController,
                    minParticipantsController: _minParticipantsController,
                    onSave: () {
                      _createDeal();
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class DealList extends StatelessWidget {
  final List<Deal> deals;
  final Function(String) onDelete;

  const DealList({
    Key? key, 
    required this.deals,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return deals.isEmpty 
      ? const Center(child: Text('No deals available'))
      : SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Title')),
              DataColumn(label: Text('Price')),
              DataColumn(label: Text('Participants')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: deals.map((deal) => DataRow(
              cells: [
                DataCell(Text(deal.title)),
                DataCell(Text('₹${deal.price}')),
                DataCell(Text('${deal.current_participants}/${deal.min_participants}')),
                DataCell(Text(deal.status)),
                DataCell(Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => onDelete(deal.id.toString()),
                    ),
                    IconButton(
                      icon: const Icon(Icons.info),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DealDetailScreen(dealId: deal.id),
                        ),
                      ),
                    ),
                  ],
                )),
              ],
            )).toList(),
          ),
        );
  }
}

class DealForm extends StatefulWidget {
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
  State<DealForm> createState() => _DealFormState();
}

class _DealFormState extends State<DealForm> {
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.clear();
        _selectedImages.addAll(images.take(3)); // Limit to 3 images
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: widget.titleController,
            decoration: const InputDecoration(labelText: 'Title'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ),
          TextFormField(
            controller: widget.descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
          ),
          TextFormField(
            controller: widget.priceController,
            decoration: const InputDecoration(labelText: 'Price'),
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
            controller: widget.minParticipantsController,
            decoration: const InputDecoration(labelText: 'Minimum Participants'),
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
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _pickImages,
            child: const Text('Select Images (Max 3)'),
          ),
          if (_selectedImages.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('${_selectedImages.length} images selected'),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: kIsWeb 
                      // For web platform
                      ? Image.network(
                          _selectedImages[index].path,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        )
                      // For mobile platforms
                      : Image.file(
                          File(_selectedImages[index].path),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              if (widget.formKey.currentState!.validate()) {
                await _createDealWithImages();
                widget.onSave();
              }
            },
            child: const Text('Save Deal'),
          ),
        ],
      ),
    );
  }

  Future<FormData> getFormData(List<XFile> images) async {
    FormData formData = FormData();
    
    // Add form fields
    formData.fields.addAll([
      MapEntry('title', widget.titleController.text),
      MapEntry('description', widget.descriptionController.text),
      MapEntry('price', widget.priceController.text),
      MapEntry('min_participants', widget.minParticipantsController.text),
    ]);
    
    // Add images
    for (var i = 0; i < images.length; i++) {
      List<int> imageBytes = await images[i].readAsBytes();
      String fileName = images[i].name;
      formData.files.add(
        MapEntry(
          'images',
          MultipartFile.fromBytes(
            imageBytes,
            filename: fileName,
          ),
        ),
      );
    }
    
    return formData;
  }

  Future<void> _createDealWithImages() async {
    try {
      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer ${Constants.jwtToken}';
      
      FormData formData = await getFormData(_selectedImages);
      
      final response = await dio.post(
        '${Constants.apiUrl}/deals',
        data: formData,
      );
      
      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Deal created successfully')),
          );
        }
      } else {
        throw Exception('Failed to create deal: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating deal: $e')),
        );
      }
    }
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
