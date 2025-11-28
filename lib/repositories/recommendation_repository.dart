import 'package:cloud_firestore/cloud_firestore.dart';
import '../api/firestore_client.dart';
import '../api/collections.dart';
import '../models/farming_models.dart';

class RecommendationRepository {
  final FirestoreClient _client;

  RecommendationRepository(this._client);

  /// Get all recommendations
  Future<List<Recommendation>> getAllRecommendations() async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.recommendationsRef.get();

      return snapshot.docs
          .map((doc) => Recommendation.fromFirestore(doc))
          .toList();
    });
  }

  /// Get recommendation by ID (cropId_objectiveId)
  Future<Recommendation?> getRecommendationById(
      String cropId, String objectiveId) async {
    return await FirestoreClient.executeOperation(() async {
      final docId = '${cropId}_${objectiveId}';
      final doc =
          await FirestoreCollections.recommendationsRef.doc(docId).get();

      return doc.exists ? Recommendation.fromFirestore(doc) : null;
    });
  }

  /// Get recommendations for a specific crop
  Future<List<Recommendation>> getRecommendationsForCrop(String cropId) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.recommendationsRef
          .where('cropId', isEqualTo: cropId)
          .get();

      return snapshot.docs
          .map((doc) => Recommendation.fromFirestore(doc))
          .toList();
    });
  }

  /// Get recommendations for a specific objective
  Future<List<Recommendation>> getRecommendationsForObjective(
      String objectiveId) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.recommendationsRef
          .where('objectiveId', isEqualTo: objectiveId)
          .get();

      return snapshot.docs
          .map((doc) => Recommendation.fromFirestore(doc))
          .toList();
    });
  }

  /// Get recommendations linked to a specific deal
  Future<List<Recommendation>> getRecommendationsForDeal(String dealId) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.recommendationsRef
          .where('dealId', isEqualTo: dealId)
          .get();

      return snapshot.docs
          .map((doc) => Recommendation.fromFirestore(doc))
          .toList();
    });
  }

  /// Create new recommendation
  Future<String> createRecommendation(Recommendation recommendation) async {
    return await FirestoreClient.executeOperation(() async {
      final docId = recommendation.documentId;
      final recommendationWithId = Recommendation(
        cropId: recommendation.cropId,
        objectiveId: recommendation.objectiveId,
        dealId: recommendation.dealId,
        comboTitle: recommendation.comboTitle,
        items: recommendation.items,
      );

      await FirestoreCollections.recommendationsRef
          .doc(docId)
          .set(recommendationWithId.toFirestore());

      return docId;
    });
  }

  /// Update recommendation
  Future<void> updateRecommendation(
      String cropId, String objectiveId, Map<String, dynamic> updates) async {
    return await FirestoreClient.executeOperation(() async {
      final docId = '${cropId}_${objectiveId}';
      await FirestoreCollections.recommendationsRef.doc(docId).update(updates);
    });
  }

  /// Delete recommendation
  Future<void> deleteRecommendation(String cropId, String objectiveId) async {
    return await FirestoreClient.executeOperation(() async {
      final docId = '${cropId}_${objectiveId}';
      await FirestoreCollections.recommendationsRef.doc(docId).delete();
    });
  }

  /// Get recommendations containing specific product
  Future<List<Recommendation>> getRecommendationsWithProduct(
      String productId) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.recommendationsRef
          .where('items', arrayContainsAny: [
        {'productId': productId}
      ]).get();

      return snapshot.docs
          .map((doc) => Recommendation.fromFirestore(doc))
          .toList();
    });
  }

  /// Update deal ID for a recommendation
  Future<void> updateDealId(
      String cropId, String objectiveId, String dealId) async {
    return await FirestoreClient.executeOperation(() async {
      final docId = '${cropId}_${objectiveId}';
      await FirestoreCollections.recommendationsRef.doc(docId).update({
        'dealId': dealId,
      });
    });
  }

  /// Validate crop-objective combination (no duplicate recommendations)
  Future<bool> recommendationExists(String cropId, String objectiveId,
      {String? excludeDocId}) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.recommendationsRef
          .where('cropId', isEqualTo: cropId)
          .where('objectiveId', isEqualTo: objectiveId)
          .get();

      final docs = excludeDocId != null
          ? snapshot.docs.where((doc) => doc.id != excludeDocId)
          : snapshot.docs;

      return docs.isNotEmpty;
    });
  }

  /// Get recommendations sorted by combination name
  Future<List<Recommendation>> getRecommendationsSorted() async {
    final recommendations = await getAllRecommendations();

    // Sort by a display name (you might want to join with crop/objective names)
    recommendations.sort((a, b) {
      final aName = '${a.cropId}_${a.objectiveId}';
      final bName = '${b.cropId}_${b.objectiveId}';
      return aName.compareTo(bName);
    });

    return recommendations;
  }

  /// Batch create recommendations (for migration)
  Future<List<String>> batchCreateRecommendations(
      List<Recommendation> recommendations) async {
    final createdIds = <String>[];

    await FirestoreClient.executeOperation(() async {
      final batch = FirestoreClient.instance.batch();

      for (final recommendation in recommendations) {
        final docId = recommendation.documentId;
        batch.set(
          FirestoreCollections.recommendationsRef.doc(docId),
          recommendation.toFirestore(),
        );
        createdIds.add(docId);
      }

      await batch.commit();
    });

    return createdIds;
  }

  /// Get summary of all recommendations with deal linkages
  Future<List<Map<String, dynamic>>> getRecommendationsSummary() async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.recommendationsRef.get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'cropId': data['cropId'],
          'objectiveId': data['objectiveId'],
          'dealId': data['dealId'],
          'comboTitle': data['comboTitle'],
          'itemCount': (data['items'] as List<dynamic>?)?.length ?? 0,
        };
      }).toList();
    });
  }
}
