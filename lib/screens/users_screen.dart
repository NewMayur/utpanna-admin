import 'package:flutter/material.dart';
import '../models/farming_models.dart';
import '../services/farming_data_service.dart';
import '../api/firestore_client.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  late final FarmingDataService _farmingDataService;
  List<User> _users = [];
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _farmingDataService = FarmingDataService(FirestoreClient());
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    try {
      final users = await _farmingDataService.getAllUsers();
      setState(() {
        _users = users;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: $e')),
        );
      }
    }
  }

  List<User> get _filteredUsers {
    return _users.where((user) {
      final matchesSearch = _searchQuery.isEmpty ||
          user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.phone.contains(_searchQuery);
      return matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header with search
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).cardColor,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search by phone number or name',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),

                // Users list
                Expanded(
                  child: _filteredUsers.isEmpty
                      ? const Center(child: Text('No users found'))
                      : MediaQuery.of(context).size.width > 600
                          ? _buildDesktopTable()
                          : _buildMobileList(),
                ),
              ],
            ),
    );
  }

  Widget _buildDesktopTable() {
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Phone')),
          DataColumn(label: Text('Village')),
          DataColumn(label: Text('Registered Date')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: _filteredUsers.map((user) {
          return DataRow(cells: [
            DataCell(Text(user.name)),
            DataCell(Text(user.phone)),
            DataCell(Text(user.village ?? '-')),
            DataCell(Text(_formatDate(user.registeredAt))),
            DataCell(
              Chip(
                label: Text(user.active ? 'Active' : 'Inactive'),
                backgroundColor:
                    user.active ? Colors.green : Colors.grey.shade300,
              ),
            ),
            DataCell(IconButton(
              icon: Icon(
                user.active ? Icons.block : Icons.check_circle,
                color: user.active ? Colors.red : Colors.green,
              ),
              onPressed: () => _toggleUserStatus(user),
            )),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildMobileList() {
    return ListView.builder(
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  user.active ? Colors.green : Colors.grey.shade400,
              child: Text(
                user.name[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(user.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.phone),
                if (user.village != null) Text(user.village!),
                Text('Registered: ${_formatDate(user.registeredAt)}'),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                user.active ? Icons.block : Icons.check_circle,
                color: user.active ? Colors.red : Colors.green,
              ),
              onPressed: () => _toggleUserStatus(user),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _toggleUserStatus(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Toggle User Status'),
        content: Text(
          'Are you sure you want to ${user.active ? 'deactivate' : 'activate'} ${user.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // TODO: Implement status toggle
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Status toggle coming soon')),
                );
              }
            },
            child: Text(user.active ? 'Deactivate' : 'Activate'),
          ),
        ],
      ),
    );
  }
}
