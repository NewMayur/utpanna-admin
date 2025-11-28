import '../api/firestore_client.dart';
import '../api/collections.dart';
import '../screens/admin_panel.dart'; // For Deal model

class DealRepository {
  final FirestoreClient _client;

  DealRepository(this._client);

  /// Get all deals
  Future<List<Deal>> getAllDeals() async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.dealsRef
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Deal.fromFirestore(doc)).toList();
    });
  }

  /// Get deal by ID
  Future<Deal?> getDealById(String dealId) async {
    return await FirestoreClient.executeOperation(() async {
      final doc = await FirestoreCollections.dealsRef.doc(dealId).get();

      return doc.exists ? Deal.fromFirestore(doc) : null;
    });
  }

  /// Create new deal
  Future<String> createDeal(Deal deal) async {
    return await FirestoreClient.executeOperation(() async {
      final dealId = Deal.generateId();
      final dealWithId = Deal(
        id: dealId,
        title: deal.title,
        description: deal.description,
        mrp: deal.mrp,
        dealPrice: deal.dealPrice,
        minParticipants: deal.minParticipants,
        currentParticipants: deal.currentParticipants,
        status: deal.status,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        imageUrls: deal.imageUrls,
      );

      await FirestoreCollections.dealsRef
          .doc(dealId)
          .set(dealWithId.toFirestore());

      return dealId;
    });
  }

  /// Update deal
  Future<void> updateDeal(String dealId, Map<String, dynamic> updates) async {
    return await FirestoreClient.executeOperation(() async {
      updates['updatedAt'] = DateTime.now().toIso8601String();
      await FirestoreCollections.dealsRef.doc(dealId).update(updates);
    });
  }

  /// Delete deal
  Future<void> deleteDeal(String dealId) async {
    return await FirestoreClient.executeOperation(() async {
      await FirestoreCollections.dealsRef.doc(dealId).delete();
    });
  }

  /// Search deals by title
  Future<List<Deal>> searchDeals(String searchTerm) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.dealsRef
          .where('title', isGreaterThanOrEqualTo: searchTerm)
          .where('title', isLessThan: searchTerm + '\uf8ff')
          .orderBy('title')
          .get();

      return snapshot.docs.map((doc) => Deal.fromFirestore(doc)).toList();
    });
  }

  /// Get deals by status
  Future<List<Deal>> getDealsByStatus(String status) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.dealsRef
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Deal.fromFirestore(doc)).toList();
    });
  }

  /// Update deal participant count
  Future<void> incrementParticipant(String dealId) async {
    return await FirestoreClient.executeOperation(() async {
      final docRef = FirestoreCollections.dealsRef.doc(dealId);
      final doc = await docRef.get();

      if (doc.exists) {
        final currentCount = (doc.data()?['currentParticipants'] ?? 0) as int;
        await docRef.update({
          'currentParticipants': currentCount + 1,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    });
  }

  /// Update deal status
  Future<void> updateDealStatus(String dealId, String status) async {
    return updateDeal(dealId, {'status': status});
  }

  /// Get deals with low participation (less than 50% filled)
  Future<List<Deal>> getLowParticipationDeals() async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.dealsRef
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Deal.fromFirestore(doc))
          .where((deal) =>
              deal.progress_percentage != null &&
              deal.progress_percentage! < 50.0)
          .toList();
    });
  }

  /// Get deal statistics
  Future<Map<String, dynamic>> getDealStats() async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.dealsRef.get();

      int totalDeals = 0;
      int activeDeals = 0;
      int completedDeals = 0;
      double totalValue = 0.0;
      double totalSavings = 0.0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final deal = Deal.fromFirestore(doc);

        totalDeals++;
        totalValue += deal.mrp * deal.minParticipants;
        totalSavings += (deal.mrp - deal.dealPrice) * deal.currentParticipants;

        final status = data['status'] as String? ?? 'active';
        if (status == 'active') activeDeals++;
        if (status == 'completed') completedDeals++;
      }

      return {
        'totalDeals': totalDeals,
        'activeDeals': activeDeals,
        'completedDeals': completedDeals,
        'totalProjectedValue': totalValue,
        'totalActualSavings': totalSavings,
        'averageDiscountPercent': totalDeals > 0
            ? (totalSavings / (totalValue + totalSavings)) * 100
            : 0.0,
      };
    });
  }

  /// Batch create deals (for migration from REST API)
  Future<List<String>> batchCreateDeals(List<Deal> deals) async {
    final createdIds = <String>[];

    await FirestoreClient.executeOperation(() async {
      final batch = FirestoreClient.instance.batch();

      for (final deal in deals) {
        final dealId = deal.id.isNotEmpty ? deal.id : Deal.generateId();
        batch.set(
          FirestoreCollections.dealsRef.doc(dealId),
          deal.toFirestore()
            ..addAll({
              'id': dealId,
              'updatedAt': DateTime.now().toIso8601String(),
            }),
        );
        createdIds.add(dealId);
      }

      await batch.commit();
    });

    return createdIds;
  }
}
