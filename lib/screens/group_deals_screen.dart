import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:utpanna_admin/api/firestore_client.dart';
import 'package:utpanna_admin/api/firebase_storage.dart';
import 'package:utpanna_admin/services/farming_data_service.dart';
import 'package:utpanna_admin/screens/deal_detail_screen.dart';
import 'package:utpanna_admin/models/farming_models.dart';

class GroupDealsScreen extends StatefulWidget {
  const GroupDealsScreen({Key? key}) : super(key: key);

  @override
  _GroupDealsScreenState createState() => _GroupDealsScreenState();
}

class _GroupDealsScreenState extends State<GroupDealsScreen> {
  List<Deal> deals = [];
  final _dealFormKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _mrpController = TextEditingController();
  final _dealPriceController = TextEditingController();
  final _minParticipantsController = TextEditingController();
  final _statusController = TextEditingController();

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
        deals = dealsData.cast<Deal>();
      });
    } catch (e) {
      print('Error fetching deals: $e');
      if (mounted) {
        _showToast('Error fetching deals: $e');
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
          _showToast('Deal created successfully');
        }
      } catch (e) {
        print('Error creating deal: $e');
        if (mounted) {
          _showToast('Error creating deal: $e');
        }
      }
    }
  }

  Future<void> _deleteDeal(String dealId) async {
    try {
      await _farmingDataService.deleteDeal(dealId);
      fetchDeals();
      if (mounted) {
        _showToast('Deal deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        _showToast('Error deleting deal: $e');
      }
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: deals.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : DealList(
                deals: deals,
                onDelete: _deleteDeal,
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
                    onSave: () => _createDeal(),
                  ),
                ),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Create New Deal',
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
    if (deals.isEmpty) {
      return const Center(
        child: Text('No deals available'),
      );
    }

    return MediaQuery.of(context).size.width > 768
        ? _buildDesktopTable(context)
        : _buildMobileCards(context);
  }

  Widget _buildDesktopTable(BuildContext context) {
    return SingleChildScrollView(
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
                    DataCell(Text('₹${deal.dealPrice}')),
                    DataCell(Text(
                        '${deal.currentParticipants}/${deal.minParticipants}')),
                    DataCell(Text(deal.status)),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility),
                          tooltip: 'View Details',
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DealDetailScreen(
                                dealId: deal.id,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Delete Deal',
                          onPressed: () => onDelete(deal.id),
                        ),
                      ],
                    )),
                  ],
                ))
            .toList(),
      ),
    );
  }

  Widget _buildMobileCards(BuildContext context) {
    return ListView.builder(
      itemCount: deals.length,
      itemBuilder: (context, index) {
        final deal = deals[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deal.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  deal.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '₹${deal.dealPrice}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '₹${deal.mrp}',
                      style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Participants: ${deal.currentParticipants}/${deal.minParticipants}',
                  style: TextStyle(
                    color: deal.currentParticipants >= deal.minParticipants
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
                Chip(
                  label: Text(deal.status.toUpperCase()),
                  backgroundColor: deal.status == 'active'
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.visibility),
                      label: const Text('View'),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DealDetailScreen(
                            dealId: deal.id,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => onDelete(deal.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
            decoration: const InputDecoration(
                labelText: 'Status (e.g., active, draft)'),
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
          ElevatedButton.icon(
            onPressed: _pickImages,
            icon: const Icon(Icons.photo_camera),
            label: const Text('Select Images (Max 3)'),
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
            child: const Text('Create Deal'),
          ),
        ],
      ),
    );
  }

  Future<void> _createDealWithUploadedImages() async {
    try {
      List<String>? imageUrls;

      if (_selectedImages.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uploading images...')),
        );

        // Upload images
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
            }
          } catch (e) {
            print('Error uploading image $i: $e');
          }
        }

        if (imageUrls.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Uploaded ${imageUrls.length}/${_selectedImages.length} images successfully')),
          );
        }
      }

      // Create deal in Firestore
      await _createDealInFirestore(imageUrls);

      Navigator.of(context).pop(); // Close dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(imageUrls != null && imageUrls.isNotEmpty
                ? 'Deal created successfully with ${imageUrls.length} images'
                : 'Deal created successfully')),
      );

      // Clear selected images
      setState(() {
        _selectedImages.clear();
      });
    } catch (e) {
      print('Error in _createDealWithUploadedImages: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating deal: $e')),
      );
    }
  }

  Future<void> _createDealInFirestore(List<String>? imageUrls) async {
    // Call the onSave callback which will handle the deal creation
    widget.onSave();
  }
}
