import 'package:flutter/material.dart';
import '../services/farming_data_service.dart';
import '../api/firestore_client.dart';
import '../widgets/app_navigation.dart';

class DashboardScreen extends StatefulWidget {
  final Function(NavigationItem)? onNavigateTo;

  const DashboardScreen({Key? key, this.onNavigateTo}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final FarmingDataService _farmingDataService;
  Map<String, dynamic>? _dashboardStats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _farmingDataService = FarmingDataService(FirestoreClient());
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final stats = await _farmingDataService.getDashboardStats();
      setState(() {
        _dashboardStats = stats;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dashboard: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  GridView.count(
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 600 ? 4 : 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildStatCard(
                        context,
                        'Total Crops',
                        (_dashboardStats?['crops_count'] ?? 0).toString(),
                        Icons.grass,
                        Colors.green,
                      ),
                      _buildStatCard(
                        context,
                        'Total Products',
                        (_dashboardStats?['products_count'] ?? 0).toString(),
                        Icons.inventory,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        context,
                        'Active Deals',
                        (_dashboardStats?['deals_count'] ?? 0).toString(),
                        Icons.local_offer,
                        Colors.orange,
                        isGreen: true,
                      ),
                      _buildStatCard(
                        context,
                        'Registered Farmers',
                        '0', // TODO: Implement users collection
                        Icons.people,
                        Colors.purple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (widget.onNavigateTo != null) {
                              widget.onNavigateTo!(NavigationItem.deals);
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Create New Deal'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (widget.onNavigateTo != null) {
                              widget.onNavigateTo!(NavigationItem.products);
                            }
                          },
                          icon: const Icon(Icons.inventory),
                          label: const Text('Add Product'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color, {
    bool isGreen = false,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isGreen ? Colors.green : color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isGreen ? Colors.green : color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
