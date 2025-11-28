import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../api/firestore_client.dart';
import '../models/farming_models.dart'; // for Deal model
import '../utils/constants.dart';

class DealDetailScreen extends StatefulWidget {
  final String dealId; // Firestore document ID

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
    return await FirestoreClient.executeOperation(() async {
      final doc = await FirebaseFirestore.instance
          .collection('deals')
          .doc(widget.dealId)
          .get();

      if (!doc.exists) {
        throw Exception('Deal not found');
      }

      final deal = Deal.fromFirestore(doc);

      // Fetch participants: deal has participants array with user IDs
      try {
        final dealData = doc.data();
        final participantIds = dealData?['participants'] as List<dynamic>?;

        if (participantIds != null && participantIds.isNotEmpty) {
          // Fetch participant details from users collection
          final userDocs = await Future.wait(participantIds.map((userId) =>
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId.toString())
                  .get()));

          // Convert user documents to participants
          deal.participants = userDocs
              .where((doc) => doc.exists) // Only include existing users
              .map((doc) => _userDocToParticipant(doc))
              .toList();
        } else {
          // No participants in Firestore, try REST API as fallback
          await _fetchParticipantsFromRest(deal);
        }
      } catch (e) {
        // If Firestore participants fail, try REST API
        await _fetchParticipantsFromRest(deal);
      }

      return deal;
    });
  }

  // Convert Firestore user document to Participant object
  Participant _userDocToParticipant(DocumentSnapshot userDoc) {
    final data = userDoc.data() as Map<String, dynamic>;
    final timestamp = data['createdAt'] as Timestamp?;

    // Generate a synthetic ID from the Firebase document ID hash
    // This satisfies the Participant's required id field
    final generatedId = userDoc.id.hashCode.abs();

    return Participant(
      id: generatedId, // Generated synthetic ID for compatibility
      name: data['name'] ?? 'Unknown',
      address: data['address'] ?? 'N/A',
      phone_number: data['phoneNumber'] ?? 'N/A',
      joined_at: timestamp?.toDate().toString() ?? 'Unknown',
    );
  }

  Future<void> _fetchParticipantsFromRest(Deal deal) async {
    try {
      // For REST API compatibility, extract the numeric ID (remove 'deal_' prefix)
      final numericId = deal.id.startsWith('deal_')
          ? int.parse(deal.id.split('_')[1])
          : int.tryParse(deal.id) ?? 0;

      final httpResponse = await http.get(
        Uri.parse('${Constants.apiUrl}/deal-participants/$numericId'),
        headers: {
          'Authorization': 'Bearer ${Constants.jwtToken}',
        },
      );

      if (httpResponse.statusCode == 200) {
        final List<dynamic> participantsJson = json.decode(httpResponse.body);
        deal.participants =
            participantsJson.map((json) => Participant.fromJson(json)).toList();
      }
      // If REST API fails, participants will remain null
    } catch (e) {
      // Participants will remain null if fetching fails
      print('Failed to fetch participants: $e');
    }
  }

  Widget _buildImageGallery(List<dynamic>? images) {
    if (images == null || images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Deal Images:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            itemBuilder: (context, index) {
              final imageUrl = images[index]['image_url'];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 200,
                        height: 200,
                        color: Colors.grey[300],
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, color: Colors.red),
                            SizedBox(height: 4),
                            Text(
                              'Failed to load image',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 200,
                        height: 200,
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
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
                Text('Title: ${deal.title}',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                _buildImageGallery(deal.images),
                const SizedBox(height: 16),
                Text('Description:',
                    style: Theme.of(context).textTheme.titleMedium),
                Text(deal.description),
                const SizedBox(height: 16),
                Text('MRP: ₹${deal.mrp}'),
                Text('Deal Price: ₹${deal.deal_price}'),
                Text('Minimum Participants: ${deal.min_participants}'),
                Text('Current Participants: ${deal.current_participants}'),
                Text(
                    'Progress: ${deal.progress_percentage?.toStringAsFixed(2)}%'),
                Text('Status: ${deal.status}'),
                Text('Created At: ${deal.created_at}'),
                Text('Updated At: ${deal.updated_at}'),
                const SizedBox(height: 20),
                const Text('Participants:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
