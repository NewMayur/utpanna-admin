import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/farming_models.dart';
import '../services/farming_data_service.dart';
import '../api/firestore_client.dart';
import '../api/firebase_storage.dart';

class AddEditProductDialog extends StatefulWidget {
  final FarmingProduct? productToEdit;

  const AddEditProductDialog({Key? key, this.productToEdit}) : super(key: key);

  @override
  State<AddEditProductDialog> createState() => _AddEditProductDialogState();
}

class _AddEditProductDialogState extends State<AddEditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late final FarmingDataService _farmingDataService;

  // Basic Info Controllers
  final _nameController = TextEditingController();
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();

  // Technical Info Controllers
  final _activeIngredientController = TextEditingController();
  final _chemicalCompositionController = TextEditingController();
  final _modeOfActionController = TextEditingController();
  final _usedForController = TextEditingController();
  final _usageDirectionController = TextEditingController();

  // Pricing Controllers
  final _priceController = TextEditingController();
  final _mrpController = TextEditingController();
  final _unitController = TextEditingController();

  // Alternatives
  List<Alternative> _alternatives = [];
  List<XFile> _selectedImages = [];
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _farmingDataService = FarmingDataService(FirestoreClient());

    if (widget.productToEdit != null) {
      _loadExistingProduct();
    }
  }

  void _loadExistingProduct() {
    final product = widget.productToEdit!;
    _nameController.text = product.name;
    _titleController.text = product.title;
    _categoryController.text = product.category;
    _activeIngredientController.text = product.activeIngredient;
    _chemicalCompositionController.text = product.chemicalComposition;
    _modeOfActionController.text = product.modeOfAction;
    _usedForController.text = product.usedFor;
    _usageDirectionController.text = product.usageDirection;
    _priceController.text = product.price.toString();
    _mrpController.text = product.mrp.toString();
    _unitController.text = product.unit;
    // TODO: Load alternatives for editing product
  }

  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.take(5 - _selectedImages.length));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _addAlternative() {
    // TODO: Implement add alternative dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add alternative coming soon')),
    );
  }

  void _removeAlternative(int index) {
    setState(() {
      _alternatives.removeAt(index);
    });
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Upload images first
      List<String>? imageUrls;
      if (_selectedImages.isNotEmpty) {
        imageUrls = [];
        for (var image in _selectedImages) {
          final url = await FirebaseStorageService.uploadImage(
            path: 'products',
            fileName:
                'product_${DateTime.now().millisecondsSinceEpoch}_${image.name}',
            imageFile: image,
          );
          if (url != null) {
            imageUrls.add(url);
          }
        }
      }

      final product = FarmingProduct(
        id: widget.productToEdit?.id ?? '',
        name: _nameController.text,
        title: _titleController.text,
        activeIngredient: _activeIngredientController.text,
        chemicalComposition: _chemicalCompositionController.text,
        modeOfAction: _modeOfActionController.text,
        usedFor: _usedForController.text,
        usageDirection: _usageDirectionController.text,
        category: _categoryController.text,
        price: double.parse(_priceController.text),
        mrp: double.parse(_mrpController.text),
        savings:
            int.parse(_mrpController.text) - int.parse(_priceController.text),
        unit: _unitController.text,
        imageUrls: imageUrls,
      );

      if (widget.productToEdit != null) {
        // Update existing product
        await _farmingDataService.updateProduct(
          widget.productToEdit!.id,
          {
            'name': product.name,
            'title': product.title,
            'activeIngredient': product.activeIngredient,
            'chemicalComposition': product.chemicalComposition,
            'modeOfAction': product.modeOfAction,
            'usedFor': product.usedFor,
            'usageDirection': product.usageDirection,
            'category': product.category,
            'price': product.price,
            'mrp': product.mrp,
            'savings': product.savings,
            'unit': product.unit,
            'imageUrls': product.imageUrls,
          },
        );
      } else {
        // Create new product
        await _farmingDataService.createProduct(product);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Product ${widget.productToEdit != null ? 'updated' : 'created'} successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.productToEdit != null
                      ? 'Edit Product'
                      : 'Add New Product',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Upload Section
                      _buildImageUploadSection(),

                      const SizedBox(height: 24),

                      // Basic Info Section
                      _buildSectionHeader('Basic Info'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Product Name',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                labelText: 'Display Title',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _categoryController,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _unitController,
                              decoration: const InputDecoration(
                                labelText: 'Unit (e.g., 1L, 250g)',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Technical Info Section
                      _buildSectionHeader('Technical Information'),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _activeIngredientController,
                        decoration: const InputDecoration(
                          labelText: 'Active Ingredient',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),

                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _chemicalCompositionController,
                        decoration: const InputDecoration(
                          labelText: 'Chemical Composition',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),

                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _modeOfActionController,
                        decoration: const InputDecoration(
                          labelText: 'Mode of Action',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),

                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _usedForController,
                        decoration: const InputDecoration(
                          labelText: 'Used For',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),

                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _usageDirectionController,
                        decoration: const InputDecoration(
                          labelText: 'Usage Direction',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),

                      const SizedBox(height: 24),

                      // Pricing Section
                      _buildSectionHeader('Pricing'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              decoration: const InputDecoration(
                                labelText: 'Selling Price (₹)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty ?? true) return 'Required';
                                final price = double.tryParse(value!);
                                if (price == null) return 'Invalid price';
                                final mrp =
                                    double.tryParse(_mrpController.text);
                                if (mrp != null && price >= mrp) {
                                  return 'Price must be less than MRP';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _mrpController,
                              decoration: const InputDecoration(
                                labelText: 'MRP (₹)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty ?? true) return 'Required';
                                final mrp = double.tryParse(value!);
                                if (mrp == null) return 'Invalid MRP';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Alternatives Section
                      _buildSectionHeader('Cheaper Alternatives'),
                      const SizedBox(height: 16),
                      ..._alternatives.map((alternative) => Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text(alternative.title),
                              subtitle: Text(
                                  '₹${alternative.price} - ${alternative.activeIngredient}'),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeAlternative(
                                    _alternatives.indexOf(alternative)),
                              ),
                            ),
                          )),

                      ElevatedButton.icon(
                        onPressed: _addAlternative,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Alternative'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      _isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Product'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Product Images'),
        const SizedBox(height: 12),

        // Selected Images Preview
        if (_selectedImages.isNotEmpty)
          Container(
            height: 80,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(File(_selectedImages[index].path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: -4,
                      right: 4,
                      child: IconButton(
                        icon: const Icon(Icons.remove_circle,
                            color: Colors.red, size: 20),
                        onPressed: () => _removeImage(index),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

        // Upload Button
        ElevatedButton.icon(
          onPressed: _selectedImages.length < 5 ? _pickImages : null,
          icon: const Icon(Icons.photo_camera),
          label: Text('Select Images (${_selectedImages.length}/5)'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),

        if (_selectedImages.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'No images selected. Click to add product images.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _categoryController.dispose();
    _activeIngredientController.dispose();
    _chemicalCompositionController.dispose();
    _modeOfActionController.dispose();
    _usedForController.dispose();
    _usageDirectionController.dispose();
    _priceController.dispose();
    _mrpController.dispose();
    _unitController.dispose();
    super.dispose();
  }
}
