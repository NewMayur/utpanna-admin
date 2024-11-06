import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';
import '../screens/admin_panel.dart';  // for Deal model

class DealDetailScreen extends StatefulWidget {
  final int dealId;
  
  const DealDetailScreen({Key? key, required this.dealId}) : super(key: key);

  @override
  _DealDetailScreenState createState() => _DealDetailScreenState();
}

class _DealDetailScreenState extends State<DealDetailScreen> {
  late Future<Deal> dealFuture;

  @override
  void initState() {
    super.initState();
    dealFuture = fetchDealDetails();
  }

  Future<Deal> fetchDealDetails() async {
    final response = await http.get(
      Uri.parse('${Constants.apiUrl}/view-deal/${widget.dealId}'),
      headers: {
        'Authorization': 'Bearer ${Constants.jwtToken}',
      },
    );
    if (response.statusCode == 200) {
      return Deal.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to load deal details');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deal Details'),
      ),
      body: FutureBuilder<Deal>(
        future: dealFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final deal = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Title: ${deal.title}', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Text('Description: ${deal.description}'),
                Text('Price: ₹${deal.price}'),
                Text('Minimum Participants: ${deal.min_participants}'),
                Text('Current Participants: ${deal.current_participants}'),
                Text('Progress: ${deal.progress_percentage?.toStringAsFixed(2)}%'),
                Text('Status: ${deal.status}'),
                Text('Created At: ${deal.created_at}'),
                Text('Updated At: ${deal.updated_at}'),
                
                const SizedBox(height: 20),
                const Text('Participants:', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                ),
                if (deal.participants != null)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: deal.participants!.length,
                    itemBuilder: (context, index) {
                      final participant = deal.participants![index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(participant.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Phone: ${participant.phone_number}'),
                              Text('Address: ${participant.address}'),
                              Text('Joined: ${participant.joined_at}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}