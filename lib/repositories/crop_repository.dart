import 'package:cloud_firestore/cloud_firestore.dart';
import '../api/firestore_client.dart';
import '../api/collections.dart';
import '../models/farming_models.dart';

class CropRepository {
  final FirestoreClient _client;

  CropRepository(this._client);

  /// Get all crops
  Future<List<Crop>> getAllCrops() async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.cropsRef.get();

      return snapshot.docs.map((doc) => Crop.fromFirestore(doc)).toList();
    });
  }

  /// Get crop by ID
  Future<Crop?> getCropById(String cropId) async {
    return await FirestoreClient.executeOperation(() async {
      final doc = await FirestoreCollections.cropsRef.doc(cropId).get();

      return doc.exists ? Crop.fromFirestore(doc) : null;
    });
  }

  /// Create new crop
  Future<String> createCrop(Crop crop) async {
    return await FirestoreClient.executeOperation(() async {
      final cropId = Crop.generateId();
      final cropWithId = Crop(
        id: cropId,
        name: crop.name,
        imageAsset: crop.imageAsset,
      );

      await FirestoreCollections.cropsRef
          .doc(cropId)
          .set(cropWithId.toFirestore());

      return cropId;
    });
  }

  /// Update crop
  Future<void> updateCrop(String cropId, Map<String, dynamic> updates) async {
    return await FirestoreClient.executeOperation(() async {
      await FirestoreCollections.cropsRef.doc(cropId).update(updates);
    });
  }

  /// Delete crop (with validation)
  Future<void> deleteCrop(String cropId) async {
    return await FirestoreClient.executeOperation(() async {
      // Check if crop is referenced in any recommendations
      final recommendationsQuery = await FirestoreCollections.recommendationsRef
          .where('cropId', isEqualTo: cropId)
          .limit(1)
          .get();

      if (recommendationsQuery.docs.isNotEmpty) {
        throw Exception(
            'Cannot delete crop that is referenced in recommendations');
      }

      await FirestoreCollections.cropsRef.doc(cropId).delete();
    });
  }

  /// Search crops by name
  Future<List<Crop>> searchCrops(String searchTerm) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.cropsRef
          .where('name', isGreaterThanOrEqualTo: searchTerm)
          .where('name', isLessThan: searchTerm + '\uf8ff')
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) => Crop.fromFirestore(doc)).toList();
    });
  }

  /// Check if crop name exists (for validation)
  Future<bool> cropNameExists(String name, {String? excludeId}) async {
    return await FirestoreClient.executeOperation(() async {
      Query query =
          FirestoreCollections.cropsRef.where('name', isEqualTo: name);

      final snapshot = await query.get();

      // If excluding an ID, filter out that document
      final docs = excludeId != null
          ? snapshot.docs.where((doc) => doc.id != excludeId)
          : snapshot.docs;

      return docs.isNotEmpty;
    });
  }

  /// Get crops that are referenced in recommendations
  Future<Set<String>> getCropsWithRecommendations() async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.recommendationsRef.get();

      final cropIds = <String>{};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final cropId = data['cropId'] as String?;
        if (cropId != null) {
          cropIds.add(cropId);
        }
      }

      return cropIds;
    });
  }

  /// Batch create crops (for migration)
  Future<List<String>> batchCreateCrops(List<Crop> crops) async {
    final createdIds = <String>[];

    await FirestoreClient.executeOperation(() async {
      final batch = FirestoreClient.instance.batch();

      for (final crop in crops) {
        final cropId = crop.id.isNotEmpty ? crop.id : Crop.generateId();
        batch.set(
          FirestoreCollections.cropsRef.doc(cropId),
          crop.copyWith(id: cropId).toFirestore(),
        );
        createdIds.add(cropId);
      }

      await batch.commit();
    });

    return createdIds;
  }
}
