import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_client.dart';

class FirestoreCollections {
  /// Collections
  static CollectionReference<Map<String, dynamic>> get dealsRef =>
      FirestoreClient.instance.collection('deals');

  static CollectionReference<Map<String, dynamic>> get cropsRef =>
      FirestoreClient.instance.collection('crops');

  static CollectionReference<Map<String, dynamic>> get objectivesRef =>
      FirestoreClient.instance.collection('objectives');

  static CollectionReference<Map<String, dynamic>> get productsRef =>
      FirestoreClient.instance.collection('products');

  static CollectionReference<Map<String, dynamic>> get recommendationsRef =>
      FirestoreClient.instance.collection('recommendations');

  /// Subcollections
  static CollectionReference<Map<String, dynamic>> dealParticipantsRef(
          String dealId) =>
      dealsRef.doc(dealId).collection('participants');

  static CollectionReference<Map<String, dynamic>> dealImagesRef(
          String dealId) =>
      dealsRef.doc(dealId).collection('images');
}

/// Query helper functions
class FirestoreQueries {
  /// Get active deals (not expired/closed)
  static Query<Map<String, dynamic>> activeDeals() {
    return FirestoreCollections.dealsRef.where('status',
        whereIn: ['active', 'open']).orderBy('createdAt', descending: true);
  }

  /// Get recommendations for a specific crop
  static Query<Map<String, dynamic>> recommendationsForCrop(String cropId) {
    return FirestoreCollections.recommendationsRef
        .where('cropId', isEqualTo: cropId);
  }

  /// Get recommendations containing specific product
  static Query<Map<String, dynamic>> recommendationsWithProduct(
      String productId) {
    return FirestoreCollections.recommendationsRef
        .where('items', arrayContainsAny: [
      {'productId': productId}
    ]);
  }

  /// Get products by category
  static Query<Map<String, dynamic>> productsByCategory(String category) {
    return FirestoreCollections.productsRef
        .where('category', isEqualTo: category)
        .orderBy('name');
  }

  /// Get deals with active deal IDs
  static Query<Map<String, dynamic>> dealsWithIds(List<String> dealIds) {
    return FirestoreCollections.dealsRef
        .where(FieldPath.documentId, whereIn: dealIds);
  }

  /// Get participants for a specific deal
  static Query<Map<String, dynamic>> dealParticipants(String dealId) {
    return FirestoreCollections.dealParticipantsRef(dealId)
        .orderBy('joinedAt', descending: true);
  }

  /// Search products by name (case-insensitive)
  static Query<Map<String, dynamic>> searchProducts(String searchTerm) {
    return FirestoreCollections.productsRef
        .where('name', isGreaterThanOrEqualTo: searchTerm)
        .where('name', isLessThan: searchTerm + '\uf8ff')
        .orderBy('name');
  }
}
