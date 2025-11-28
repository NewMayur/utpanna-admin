import 'package:flutter/material.dart';
import '../models/farming_models.dart';
import '../services/farming_data_service.dart';
import '../api/firestore_client.dart';

class CropsComboScreen extends StatefulWidget {
  const CropsComboScreen({Key? key}) : super(key: key);

  @override
  State<CropsComboScreen> createState() => _CropsComboScreenState();
}

class _CropsComboScreenState extends State<CropsComboScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final FarmingDataService _farmingDataService;

  // Data
  List<Crop> _crops = [];
  List<Objective> _objectives = [];
  List<Recommendation> _recommendations = [];

  // Loading states
  bool _loadingCrops = true;
  bool _loadingObjectives = true;
  bool _loadingRecommendations = true;

  // Recommendations builder state
  Crop? _selectedCrop;
  Objective? _selectedObjective;
  Recommendation? _currentRecommendation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _farmingDataService = FarmingDataService(FirestoreClient());

    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadCrops(),
      _loadObjectives(),
      _loadRecommendations(),
    ]);
  }

  Future<void> _loadCrops() async {
    setState(() => _loadingCrops = true);
    try {
      final crops = await _farmingDataService.getAllCrops();
      setState(() {
        _crops = crops;
        _loadingCrops = false;
      });
    } catch (e) {
      setState(() => _loadingCrops = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading crops: $e')),
        );
      }
    }
  }

  Future<void> _loadObjectives() async {
    setState(() => _loadingObjectives = true);
    try {
      final objectives = await _farmingDataService.getAllObjectives();
      setState(() {
        _objectives = objectives;
        _loadingObjectives = false;
      });
    } catch (e) {
      setState(() => _loadingObjectives = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading objectives: $e')),
        );
      }
    }
  }

  Future<void> _loadRecommendations() async {
    setState(() => _loadingRecommendations = true);
    try {
      final recommendations = await _farmingDataService.getAllRecommendations();
      setState(() {
        _recommendations = recommendations;
        _loadingRecommendations = false;
      });
    } catch (e) {
      setState(() => _loadingRecommendations = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading recommendations: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Bar
        Container(
          color: Theme.of(context).cardColor,
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                child: Text(
                  'Crops Master',
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
              Tab(
                child: Text(
                  'Objectives Master',
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
              Tab(
                child: Text(
                  'Recommendations',
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            indicatorColor: Theme.of(context).primaryColor,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
          ),
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCropsTab(),
              _buildObjectivesTab(),
              _buildRecommendationsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCropsTab() {
    return Scaffold(
      body: _loadingCrops
          ? const Center(child: CircularProgressIndicator())
          : _crops.isEmpty
              ? const Center(child: Text('No crops found'))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 600 ? 4 : 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: _crops.length,
                  itemBuilder: (context, index) {
                    final crop = _crops[index];
                    return Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.grass,
                                color: Colors.green,
                                size: 30,
                              ), // Placeholder for crop image
                            ),
                            const SizedBox(height: 12),
                            Text(
                              crop.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 18),
                                  onPressed: () => _showEditCropDialog(crop),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      size: 18, color: Colors.red),
                                  onPressed: () => _deleteCrop(crop),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCropDialog,
        child: const Icon(Icons.add),
        tooltip: 'Add Crop',
      ),
    );
  }

  Widget _buildObjectivesTab() {
    return Scaffold(
      body: _loadingObjectives
          ? const Center(child: CircularProgressIndicator())
          : _objectives.isEmpty
              ? const Center(child: Text('No objectives found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _objectives.length,
                  itemBuilder: (context, index) {
                    final objective = _objectives[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(
                          objective.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () =>
                                  _showEditObjectiveDialog(objective),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  size: 20, color: Colors.red),
                              onPressed: () => _deleteObjective(objective),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddObjectiveDialog,
        child: const Icon(Icons.add),
        tooltip: 'Add Objective',
      ),
    );
  }

  Widget _buildRecommendationsTab() {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter dropdowns at top
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: DropdownButtonFormField<Crop>(
                    value: _selectedCrop,
                    decoration: const InputDecoration(
                      labelText: 'Select Crop',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    items: _crops.map((crop) {
                      return DropdownMenuItem(
                        value: crop,
                        child: Text(crop.name),
                      );
                    }).toList(),
                    onChanged: (crop) {
                      setState(() {
                        _selectedCrop = crop;
                        _currentRecommendation = null;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<Objective>(
                    value: _selectedObjective,
                    decoration: const InputDecoration(
                      labelText: 'Select Objective',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    items: _objectives.map((objective) {
                      return DropdownMenuItem(
                        value: objective,
                        child: Text(objective.name),
                      );
                    }).toList(),
                    onChanged: (objective) {
                      setState(() {
                        _selectedObjective = objective;
                        _currentRecommendation = null;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Result area
            Expanded(
              child: _buildRecommendationResult(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationResult() {
    if (_selectedCrop == null || _selectedObjective == null) {
      return const Center(
        child: Text(
          'Please select a crop and objective to view or create recommendations',
          textAlign: TextAlign.center,
        ),
      );
    }

    // Find existing recommendation
    final existingRecommendation = _recommendations.firstWhere(
      (rec) =>
          rec.cropId == _selectedCrop!.id &&
          rec.objectiveId == _selectedObjective!.id,
      orElse: () => Recommendation(
        cropId: '',
        objectiveId: '',
        dealId: '',
        comboTitle: '',
        items: [],
      ),
    );

    final hasRecommendation = existingRecommendation.cropId.isNotEmpty;

    if (!hasRecommendation) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No recommendation exists for this combination',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showCreateRecommendationDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Create Recommendation'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    // Show existing recommendation
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        existingRecommendation.comboTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_selectedCrop!.name} - ${_selectedObjective!.name}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditRecommendationDialog(existingRecommendation);
                        break;
                      case 'delete':
                        _showDeleteRecommendationDialog(existingRecommendation);
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

            const Divider(height: 32),

            // Items list
            const Text(
              'Products & Quantities:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),

            ...existingRecommendation.items.map((item) => Card(
                  color: Colors.grey.shade50,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Product: ${item.productId}', // TODO: Show product name
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text('Acre: ${item.qtyAcre} | Pump: ${item.qtyPump}'),
                      ],
                    ),
                  ),
                )),

            const SizedBox(height: 16),

            if (existingRecommendation.items.isEmpty)
              const Text(
                'No products added yet',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),

            // Deal ID info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Text(
                    'Deal ID: ',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    existingRecommendation.dealId,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CRUD Dialogs - Placeholder implementations
  void _showAddCropDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Crop'),
        content: const Text('Crop creation form coming soon...'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Save')),
        ],
      ),
    );
  }

  void _showEditCropDialog(Crop crop) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${crop.name}'),
        content: const Text('Crop edit form coming soon...'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Save')),
        ],
      ),
    );
  }

  void _deleteCrop(Crop crop) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Crop'),
        content: Text('Are you sure you want to delete "${crop.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(), // TODO: Implement delete
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  void _showAddObjectiveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Objective'),
        content: const Text('Objective creation form coming soon...'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Save')),
        ],
      ),
    );
  }

  void _showEditObjectiveDialog(Objective objective) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${objective.name}'),
        content: const Text('Objective edit form coming soon...'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Save')),
        ],
      ),
    );
  }

  void _deleteObjective(Objective objective) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Objective'),
        content: Text('Are you sure you want to delete "${objective.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(), // TODO: Implement delete
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  void _showCreateRecommendationDialog() {
    if (_selectedCrop == null || _selectedObjective == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Recommendation'),
        content: const Text('Recommendation creation form coming soon...'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Save')),
        ],
      ),
    );
  }

  void _showEditRecommendationDialog(Recommendation recommendation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Recommendation'),
        content: const Text('Recommendation edit form coming soon...'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Save')),
        ],
      ),
    );
  }

  void _showDeleteRecommendationDialog(Recommendation recommendation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recommendation'),
        content: Text('Are you sure you want to delete this recommendation?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(), // TODO: Implement delete
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}
