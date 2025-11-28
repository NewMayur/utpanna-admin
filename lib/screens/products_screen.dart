import 'package:flutter/material.dart';
import '../models/farming_models.dart';
import '../services/farming_data_service.dart';
import '../api/firestore_client.dart';
import '../api/firebase_storage.dart';
import '../widgets/add_edit_product_dialog.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late final FarmingDataService _farmingDataService;
  List<FarmingProduct> _products = [];
  bool _loading = true;
  String _searchQuery = '';
  String _selectedCategoryFilter = 'All';

  @override
  void initState() {
    super.initState();
    _farmingDataService = FarmingDataService(FirestoreClient());
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _loading = true);
    try {
      final products = await _farmingDataService.getAllProducts();
      setState(() {
        _products = products;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading products: $e')),
        );
      }
    }
  }

  List<FarmingProduct> get _filteredProducts {
    return _products.where((product) {
      final matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.category.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategoryFilter == 'All' ||
          product.category == _selectedCategoryFilter;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header with search and filters
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).cardColor,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: 'Search by name, category...',
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                setState(() => _searchQuery = value);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          DropdownButton<String>(
                            value: _selectedCategoryFilter,
                            items: [
                              const DropdownMenuItem(
                                value: 'All',
                                child: Text('All Categories'),
                              ),
                              // Add dynamic categories here
                              ..._products
                                  .map((p) => p.category)
                                  .toSet()
                                  .map((category) => DropdownMenuItem(
                                        value: category,
                                        child: Text(category),
                                      )),
                            ],
                            onChanged: (value) {
                              setState(() =>
                                  _selectedCategoryFilter = value ?? 'All');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Products list
                Expanded(
                  child: _filteredProducts.isEmpty
                      ? const Center(
                          child: Text('No products found'),
                        )
                      : MediaQuery.of(context).size.width > 768
                          ? _buildDesktopTable()
                          : _buildMobileCards(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        child: const Icon(Icons.add),
        tooltip: 'Add Product',
      ),
    );
  }

  Widget _buildDesktopTable() {
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Image')),
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Category')),
          DataColumn(label: Text('Price')),
          DataColumn(label: Text('MRP')),
          DataColumn(label: Text('Deal Active')),
          DataColumn(label: Text('Alternatives')),
          DataColumn(label: Text('Actions')),
        ],
        rows: _filteredProducts.map((product) {
          return DataRow(cells: [
            DataCell(
              product.imageUrls?.isNotEmpty == true
                  ? Image.network(
                      product.imageUrls!.first,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.image, size: 40),
            ),
            DataCell(Text(product.name)),
            DataCell(Text(product.category)),
            DataCell(Text('₹${product.price}')),
            DataCell(Text('₹${product.mrp}')),
            DataCell(
              product.activeDealId != null
                  ? const Chip(
                      label: Text('🔥 Deal'),
                      backgroundColor: Colors.green,
                    )
                  : const Text('-'),
            ),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '0 Alts', // TODO: Implement alternatives count
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
            ),
            DataCell(Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditProductDialog(product),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteProduct(product),
                ),
              ],
            )),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildMobileCards() {
    return ListView.builder(
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade200,
                  ),
                  child: product.imageUrls?.isNotEmpty == true
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            product.imageUrls!.first,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.image, size: 30),
                ),

                const SizedBox(width: 16),

                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (product.activeDealId != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '🔥 Deal',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        product.category,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${product.price} - MRP ₹${product.mrp}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                        ),
                      ),
                      // Alternatives count
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '0 Alts', // TODO: Implement alternatives count
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions Menu
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditProductDialog(product);
                        break;
                      case 'delete':
                        _deleteProduct(product);
                        break;
                      case 'alternatives':
                        _showAlternativesDialog(product);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Edit'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'alternatives',
                      child: ListTile(
                        leading: Icon(Icons.list),
                        title: Text('Alternatives'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Delete'),
                      ),
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

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddEditProductDialog(),
    ).then((_) => _loadProducts()); // Reload products after adding
  }

  void _showEditProductDialog(FarmingProduct product) {
    showDialog(
      context: context,
      builder: (context) => AddEditProductDialog(productToEdit: product),
    ).then((_) => _loadProducts()); // Reload products after editing
  }

  void _deleteProduct(FarmingProduct product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await _farmingDataService.deleteProduct(product.id);
                _loadProducts();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Product deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting product: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAlternativesDialog(FarmingProduct product) {
    // TODO: Implement alternatives management dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Alternatives for ${product.name}'),
        content: const Text('Alternatives management coming soon...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
