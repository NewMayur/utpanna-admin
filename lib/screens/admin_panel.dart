import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utpanna_admin/services/auth_service.dart';
import 'package:utpanna_admin/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'package:utpanna_admin/screens/deal_detail_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:utpanna_admin/api/firestore_client.dart';
import 'package:utpanna_admin/api/firebase_storage.dart';
import 'package:utpanna_admin/services/farming_data_service.dart';

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
  const AdminPanel({Key? key}) : super(key: key);

  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class Deal {
  final String id; // Auto-generated: deal_[number]
  final String title;
  final String description;
  final double mrp;
  final double dealPrice;
  final int minParticipants;
  final int currentParticipants;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String>? imageUrls; // Firebase Storage URLs

  Deal({
    required this.id,
    required this.title,
    required this.description,
    required this.mrp,
    required this.dealPrice,
    required this.minParticipants,
    this.currentParticipants = 0,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
    this.imageUrls,
  });

  /// Firestore serialization
  factory Deal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Helper function to handle both Timestamp and String date formats
    DateTime _parseDate(dynamic dateValue) {
      if (dateValue is Timestamp) {
        return dateValue.toDate();
      } else if (dateValue is String) {
        return DateTime.tryParse(dateValue) ?? DateTime.now();
      } else {
        return DateTime.now();
      }
    }

    return Deal(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      mrp: (data['mrp'] ?? 0.0).toDouble(),
      dealPrice: (data['dealPrice'] ?? 0.0).toDouble(),
      minParticipants: data['minParticipants'] ?? 0,
      currentParticipants: data['currentParticipants'] ?? 0,
      status: data['status'] ?? 'active',
      createdAt: _parseDate(data['createdAt']),
      updatedAt: _parseDate(data['updatedAt']),
      imageUrls: data['imageUrls'] != null
          ? List<String>.from(data['imageUrls'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'mrp': mrp,
      'dealPrice': dealPrice,
      'minParticipants': minParticipants,
      'currentParticipants': currentParticipants,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'imageUrls': imageUrls,
    };
  }

  /// Generate auto ID
  static String generateId() {
    final counter = DateTime.now().millisecondsSinceEpoch;
    return 'deal_$counter';
  }

  /// Legacy JSON methods for backward compatibility during migration
  factory Deal.fromJson(Map<String, dynamic> json) {
    return Deal(
      id: 'deal_${json['id']?.toString() ?? '0'}',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      mrp: (json['mrp'] ?? 0.0).toDouble(),
      dealPrice: (json['deal_price'] ?? 0.0).toDouble(),
      minParticipants: json['min_participants'] ?? 0,
      currentParticipants: json['current_participants'] ?? 0,
      status: json['status'] ?? 'active',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      imageUrls: json['images'] != null
          ? (json['images'] as List).map((e) => e.toString()).toList()
          : null,
    );
  }

  // Backward compatibility getters for existing code
  double get deal_price => dealPrice;
  int get min_participants => minParticipants;
  int get current_participants => currentParticipants;
  String get created_at => createdAt.toIso8601String();
  String get updated_at => updatedAt.toIso8601String();
  List<dynamic>? get images =>
      imageUrls?.map((url) => {'image_url': url}).toList();
  double? get progress_percentage =>
      minParticipants > 0 ? (currentParticipants / minParticipants) * 100 : 0.0;
  List<Participant>?
      participants; // For backward compatibility - loaded from REST API

  Map<String, dynamic> toJson() {
    return {
      'id': int.parse(id.split('_')[1]),
      'title': title,
      'description': description,
      'mrp': mrp,
      'deal_price': dealPrice,
      'min_participants': minParticipants,
      'current_participants': currentParticipants,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'images': imageUrls,
    };
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
  final _mrpController = TextEditingController();
  final _dealPriceController = TextEditingController();
  final _minParticipantsController = TextEditingController();
  final _statusController = TextEditingController();
  final _authService = AuthService();

  // Initialize services
  late final FirestoreClient _firestoreClient;
  late final FarmingDataService _farmingDataService;

  @override
  void initState() {
    super.initState();

    // Initialize Firestore client and farming data service
    _firestoreClient = FirestoreClient();
    _farmingDataService = FarmingDataService(_firestoreClient);

    fetchDeals();
  }

  Future<void> fetchDeals() async {
    try {
      final dealsData = await _farmingDataService.getAllDeals();
      setState(() {
        deals = dealsData;
      });
    } catch (e) {
      print('Error fetching deals: $e');
      if (mounted) {
        showToast(context, 'Error fetching deals: $e');
      }
    }
  }

  Future<void> _createDeal({List<String>? imageUrls}) async {
    if (_dealFormKey.currentState!.validate()) {
      try {
        final deal = Deal(
          id: Deal.generateId(), // Auto-generate ID
          title: _titleController.text,
          description: _descriptionController.text,
          mrp: double.parse(_mrpController.text),
          dealPrice: double.parse(_dealPriceController.text),
          minParticipants: int.parse(_minParticipantsController.text),
          currentParticipants: 0,
          status: _statusController.text,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          imageUrls: imageUrls, // Use provided image URLs
        );

        await _farmingDataService.createDeal(deal);

        fetchDeals();
        _dealFormKey.currentState?.reset();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Deal created successfully')),
          );
        }
      } catch (e) {
        print('Error creating deal: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating deal: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteDeal(String dealId) async {
    try {
      await _farmingDataService.deleteDeal(dealId);
      fetchDeals();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deal deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting deal: $e')),
        );
      }
    }
  }

  void _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logged out successfully')),
      );
    }
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
                height: 600, // Increased height to accommodate all fields
                width: 300,
                child: SingleChildScrollView(
                  child: DealForm(
                    formKey: _dealFormKey,
                    titleController: _titleController,
                    descriptionController: _descriptionController,
                    mrpController: _mrpController,
                    dealPriceController: _dealPriceController,
                    minParticipantsController: _minParticipantsController,
                    statusController: _statusController,
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
                DataColumn(label: Text('MRP')),
                DataColumn(label: Text('Deal Price')),
                DataColumn(label: Text('Participants')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows: deals
                  .map((deal) => DataRow(
                        cells: [
                          DataCell(Text(deal.title)),
                          DataCell(Text('₹${deal.mrp}')),
                          DataCell(
                              Text('₹${deal.dealPrice}')), // Fixed field name
                          DataCell(Text(
                              '${deal.currentParticipants}/${deal.minParticipants}')), // Fixed field names
                          DataCell(Text(deal.status)),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () =>
                                    onDelete(deal.id), // ID is now String
                              ),
                              IconButton(
                                icon: const Icon(Icons.info),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DealDetailScreen(
                                      dealId:
                                          deal.id, // Pass Firestore document ID
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )),
                        ],
                      ))
                  .toList(),
            ),
          );
  }
}

class DealForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController mrpController;
  final TextEditingController dealPriceController;
  final TextEditingController minParticipantsController;
  final TextEditingController statusController;
  final VoidCallback onSave;

  const DealForm({
    Key? key,
    required this.formKey,
    required this.titleController,
    required this.descriptionController,
    required this.mrpController,
    required this.dealPriceController,
    required this.minParticipantsController,
    required this.statusController,
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
        _selectedImages.addAll(images.take(3));
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
            decoration: const InputDecoration(
              labelText: 'Description',
              alignLabelWithHint: true,
            ),
            maxLines: 5,
            textInputAction: TextInputAction.newline,
            keyboardType: TextInputType.multiline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
          ),
          TextFormField(
            controller: widget.mrpController,
            decoration: const InputDecoration(labelText: 'MRP'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter MRP';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          TextFormField(
            controller: widget.dealPriceController,
            decoration: const InputDecoration(labelText: 'Deal Price'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter deal price';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              final dealPrice = double.parse(value);
              final mrp = double.tryParse(widget.mrpController.text) ?? 0;
              if (dealPrice >= mrp) {
                return 'Deal price must be less than MRP';
              }
              return null;
            },
          ),
          TextFormField(
            controller: widget.statusController,
            decoration: const InputDecoration(labelText: 'Status'),
            maxLength: 20,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter status';
              }
              return null;
            },
          ),
          TextFormField(
            controller: widget.minParticipantsController,
            decoration:
                const InputDecoration(labelText: 'Minimum Participants'),
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
                await _createDealWithUploadedImages();
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
      MapEntry('mrp', widget.mrpController.text),
      MapEntry('deal_price', widget.dealPriceController.text),
      MapEntry('min_participants', widget.minParticipantsController.text),
      MapEntry('status', widget.statusController.text),
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

  Future<void> _createDealWithUploadedImages() async {
    try {
      List<String>? imageUrls;
      String progressMessage = 'Creating deal...';

      if (_selectedImages.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uploading images...')),
        );

        // Upload images one by one with better error handling
        imageUrls = [];
        for (int i = 0; i < _selectedImages.length; i++) {
          try {
            final imageUrl = await FirebaseStorageService.uploadImage(
              path: 'deals',
              fileName:
                  'deal_${DateTime.now().millisecondsSinceEpoch}_$i.${_selectedImages[i].path.split('.').last}',
              imageFile: _selectedImages[i],
            );

            if (imageUrl != null) {
              imageUrls.add(imageUrl);
              print('Successfully uploaded image $i: $imageUrl');
            } else {
              print('Failed to upload image $i: returned null');
            }
          } catch (e) {
            print('Error uploading image $i: $e');
          }
        }

        if (imageUrls.isNotEmpty) {
          progressMessage = 'Deal created with ${imageUrls.length} images';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Uploaded ${imageUrls.length}/${_selectedImages.length} images successfully')),
          );
        } else {
          progressMessage = 'Deal created (image uploads failed)';
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Deal created but image uploads failed')),
          );
        }
      }

      print('Creating deal with image URLs: $imageUrls');

      // Create deal with uploaded image URLs
      await _createDealInFirestore(imageUrls);

      Navigator.of(context).pop(); // Close dialog

      // Show final success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(progressMessage)),
      );

      // Clear selected images
      setState(() {
        _selectedImages.clear();
      });
    } catch (e) {
      print('Error in _createDealWithUploadedImages: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating deal: $e')),
        );
      }
    }
  }

  Future<void> _createDealInFirestore(List<String>? imageUrls) async {
    try {
      // Update deal creation to use Firestore with image URLs
      final deal = Deal(
        id: Deal.generateId(),
        title: widget.titleController.text,
        description: widget.descriptionController.text,
        mrp: double.parse(widget.mrpController.text),
        dealPrice: double.parse(widget.dealPriceController.text),
        minParticipants: int.parse(widget.minParticipantsController.text),
        currentParticipants: 0,
        status: widget.statusController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        imageUrls: imageUrls,
      );

      // Create deal in Firestore
      final adminPanelState =
          context.findAncestorStateOfType<_AdminPanelState>();
      if (adminPanelState != null) {
        // Call the parent's create deal method which uses Firestore
        await adminPanelState._createDeal(imageUrls: imageUrls);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Deal created successfully with images')),
        );
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
