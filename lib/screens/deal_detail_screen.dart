import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';
import '../screens/admin_panel.dart';  // for Deal model

class DealDetailScreen extends StatelessWidget {
  final Deal deal;

  const DealDetailScreen({Key? key, required this.deal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(deal.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${deal.description}'),
            Text('Price: ₹${deal.price}'),
            Text('Minimum Participants: ${deal.min_participants}'),
            Text('Current Participants: ${deal.current_participants}'),
            Text('Status: ${deal.status}'),
          ],
        ),
      ),
    );
  }
}