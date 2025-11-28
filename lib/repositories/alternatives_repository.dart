import 'package:cloud_firestore/cloud_firestore.dart';
import '../api/firestore_client.dart';
import '../api/collections.dart';
import '../models/farming_models.dart';

class AlternativesRepository {
  final FirestoreClient _client;

  AlternativesRepository(this._client);

  /// Get all alternatives for a parent product
  Future<List<Alternative>> getAlternativesForProduct(
      String parentProductId) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.alternativesRef
          .where('parentProductId', isEqualTo: parentProductId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Alternative.fromFirestore(doc))
          .toList();
    });
  }

  /// Get alternative by ID
  Future<Alternative?> getAlternativeById(String alternativeId) async {
    return await FirestoreClient.executeOperation(() async {
      final doc =
          await FirestoreCollections.alternativesRef.doc(alternativeId).get();

      return doc.exists ? Alternative.fromFirestore(doc) : null;
    });
  }

  /// Create new alternative
  Future<String> createAlternative(Alternative alternative) async {
    return await FirestoreClient.executeOperation(() async {
      final alternativeId =
          alternative.id.isNotEmpty ? alternative.id : Alternative.generateId();
      final alternativeWithId = Alternative(
        id: alternativeId,
        parentProductId: alternative.parentProductId,
        title: alternative.title,
        activeIngredient: alternative.activeIngredient,
        chemicalComposition: alternative.chemicalComposition,
        modeOfAction: alternative.modeOfAction,
        usedFor: alternative.usedFor,
        usageDirection: alternative.usageDirection,
        price: alternative.price,
        savings: alternative.savings,
        createdAt: alternative.createdAt,
        imageUrls: alternative.imageUrls,
      );

      await FirestoreCollections.alternativesRef
          .doc(alternativeId)
          .set(alternativeWithId.toFirestore());

      return alternativeId;
    });
  }

  /// Update alternative
  Future<void> updateAlternative(
      String alternativeId, Map<String, dynamic> updates) async {
    return await FirestoreClient.executeOperation(() async {
      await FirestoreCollections.alternativesRef
          .doc(alternativeId)
          .update(updates);
    });
  }

  /// Delete alternative
  Future<void> deleteAlternative(String alternativeId) async {
    return await FirestoreClient.executeOperation(() async {
      await FirestoreCollections.alternativesRef.doc(alternativeId).delete();
    });
  }

  /// Get alternatives for multiple parent products
  Future<Map<String, List<Alternative>>> getAlternativesForProducts(
      List<String> parentProductIds) async {
    return await FirestoreClient.executeOperation(() async {
      final alternativesMap = <String, List<Alternative>>{};

      // Firestore doesn't support 'in' queries for arrays directly,
      // so we need to query each parent separately or use multiple queries
      for (final parentId in parentProductIds) {
        final alternatives = await getAlternativesForProduct(parentId);
        alternativesMap[parentId] = alternatives;
      }

      return alternativesMap;
    });
  }

  /// Copy details from main product to create alternative data
  Map<String, dynamic> copyProductDetailsToAlternative(FarmingProduct product) {
    return {
      'activeIngredient': product.activeIngredient,
      'chemicalComposition': product.chemicalComposition,
      'modeOfAction': product.modeOfAction,
      'usedFor': product.usedFor,
      'usageDirection': product.usageDirection,
    };
  }

  /// Create alternative from product (useful for "Copy from Main Product" feature)
  Alternative createAlternativeFromProduct({
    required String parentProductId,
    required FarmingProduct product,
    required String title,
    required double price,
    required int savings,
    List<String>? imageUrls,
  }) {
    return Alternative(
      id: Alternative.generateId(),
      parentProductId: parentProductId,
      title: title,
      activeIngredient: product.activeIngredient,
      chemicalComposition: product.chemicalComposition,
      modeOfAction: product.modeOfAction,
      usedFor: product.usedFor,
      usageDirection: product.usageDirection,
      price: price,
      savings: savings,
      createdAt: DateTime.now(),
      imageUrls: imageUrls,
    );
  }

  /// Get all alternatives count for a product (for badges)
  Future<int> getAlternativesCount(String parentProductId) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.alternativesRef
          .where('parentProductId', isEqualTo: parentProductId)
          .count()
          .get();

      return snapshot.count ?? 0;
    });
  }

  /// Get alternatives by price range (for filtering)
  Future<List<Alternative>> getAlternativesByPriceRange(
      double minPrice, double maxPrice) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.alternativesRef
          .where('price', isGreaterThanOrEqualTo: minPrice)
          .where('price', isLessThanOrEqualTo: maxPrice)
          .orderBy('price')
          .get();

      return snapshot.docs
          .map((doc) => Alternative.fromFirestore(doc))
          .toList();
    });
  }
}
