import 'package:cloud_firestore/cloud_firestore.dart';
import '../api/firestore_client.dart';
import '../api/collections.dart';
import '../models/farming_models.dart';

class ProductRepository {
  final FirestoreClient _client;

  ProductRepository(this._client);

  /// Get all products
  Future<List<FarmingProduct>> getAllProducts() async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.productsRef.get();

      return snapshot.docs
          .map((doc) => FarmingProduct.fromFirestore(doc))
          .toList();
    });
  }

  /// Get products by category
  Future<List<FarmingProduct>> getProductsByCategory(String category) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.productsRef
          .where('category', isEqualTo: category)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => FarmingProduct.fromFirestore(doc))
          .toList();
    });
  }

  /// Get products by price range
  Future<List<FarmingProduct>> getProductsByPriceRange(
      double minPrice, double maxPrice) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.productsRef
          .where('price', isGreaterThanOrEqualTo: minPrice)
          .where('price', isLessThanOrEqualTo: maxPrice)
          .orderBy('price')
          .get();

      return snapshot.docs
          .map((doc) => FarmingProduct.fromFirestore(doc))
          .toList();
    });
  }

  /// Get product by ID
  Future<FarmingProduct?> getProductById(String productId) async {
    return await FirestoreClient.executeOperation(() async {
      final doc = await FirestoreCollections.productsRef.doc(productId).get();

      return doc.exists ? FarmingProduct.fromFirestore(doc) : null;
    });
  }

  /// Create new product
  Future<String> createProduct(FarmingProduct product) async {
    return await FirestoreClient.executeOperation(() async {
      final productId = FarmingProduct.generateId();
      final productWithId = FarmingProduct(
        id: productId,
        name: product.name,
        title: product.title,
        activeIngredient: product.activeIngredient,
        chemicalComposition: product.chemicalComposition,
        modeOfAction: product.modeOfAction,
        usedFor: product.usedFor,
        usageDirection: product.usageDirection,
        category: product.category,
        price: product.price,
        mrp: product.mrp,
        savings: product.savings,
        unit: product.unit,
        imageUrls: product.imageUrls,
        activeDealId: product.activeDealId,
      );

      await FirestoreCollections.productsRef
          .doc(productId)
          .set(productWithId.toFirestore());

      return productId;
    });
  }

  /// Update product
  Future<void> updateProduct(
      String productId, Map<String, dynamic> updates) async {
    return await FirestoreClient.executeOperation(() async {
      await FirestoreCollections.productsRef.doc(productId).update(updates);
    });
  }

  /// Delete product (with validation)
  Future<void> deleteProduct(String productId) async {
    return await FirestoreClient.executeOperation(() async {
      // Check if product is referenced in any recommendations
      final recommendationsQuery = await FirestoreCollections.recommendationsRef
          .where('items', arrayContainsAny: [
            {'productId': productId}
          ])
          .limit(1)
          .get();

      if (recommendationsQuery.docs.isNotEmpty) {
        throw Exception(
            'Cannot delete product that is referenced in recommendations');
      }

      await FirestoreCollections.productsRef.doc(productId).delete();
    });
  }

  /// Search products by name
  Future<List<FarmingProduct>> searchProducts(String searchTerm) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.productsRef
          .where('name', isGreaterThanOrEqualTo: searchTerm)
          .where('name', isLessThan: searchTerm + '\uf8ff')
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => FarmingProduct.fromFirestore(doc))
          .toList();
    });
  }

  /// Get products with active deals
  Future<List<FarmingProduct>> getProductsWithDeals() async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.productsRef
          .where('activeDealId', isNotEqualTo: null)
          .get();

      return snapshot.docs
          .map((doc) => FarmingProduct.fromFirestore(doc))
          .toList();
    });
  }

  /// Get all unique categories
  Future<List<String>> getAllCategories() async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.productsRef.get();

      final categories = <String>{};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final category = data['category'] as String?;
        if (category != null && category.isNotEmpty) {
          categories.add(category);
        }
      }

      return categories.toList()..sort();
    });
  }

  /// Assign deal to product
  Future<void> assignDeal(String productId, String dealId) async {
    return await FirestoreClient.executeOperation(() async {
      await FirestoreCollections.productsRef.doc(productId).update({
        'activeDealId': dealId,
      });
    });
  }

  /// Clear deal assignment from product
  Future<void> clearDealAssignment(String productId) async {
    return await FirestoreClient.executeOperation(() async {
      await FirestoreCollections.productsRef.doc(productId).update({
        'activeDealId': null,
      });
    });
  }

  /// Check if product name exists (for validation)
  Future<bool> productNameExists(String name, {String? excludeId}) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.productsRef
          .where('name', isEqualTo: name)
          .get();

      final docs = excludeId != null
          ? snapshot.docs.where((doc) => doc.id != excludeId)
          : snapshot.docs;

      return docs.isNotEmpty;
    });
  }

  /// Get products referenced in recommendations
  Future<Set<String>> getProductsWithRecommendations() async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.recommendationsRef.get();

      final productIds = <String>{};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final items = data['items'] as List<dynamic>? ?? [];
        for (var item in items) {
          final productId = item['productId'] as String?;
          if (productId != null) {
            productIds.add(productId);
          }
        }
      }

      return productIds;
    });
  }

  /// Advanced filtering with multiple criteria
  Future<List<FarmingProduct>> getFilteredProducts({
    String? category,
    double? minPrice,
    double? maxPrice,
    String? searchTerm,
    String? sortBy, // 'name', 'price', 'mrp'
    bool ascending = true,
  }) async {
    return await FirestoreClient.executeOperation(() async {
      Query query = FirestoreCollections.productsRef;

      // Apply filters
      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      if (minPrice != null) {
        query = query.where('price', isGreaterThanOrEqualTo: minPrice);
      }

      if (maxPrice != null) {
        query = query.where('price', isLessThanOrEqualTo: maxPrice);
      }

      if (searchTerm != null && searchTerm.isNotEmpty) {
        query = query
            .where('name', isGreaterThanOrEqualTo: searchTerm)
            .where('name', isLessThan: searchTerm + '\uf8ff');
      }

      // Apply sorting (Firestore allows only one orderBy)
      if (sortBy != null) {
        query = query.orderBy(sortBy, descending: !ascending);
      } else {
        query = query.orderBy('name');
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => FarmingProduct.fromFirestore(doc))
          .toList();
    });
  }

  /// Batch create products (for migration)
  Future<List<String>> batchCreateProducts(
      List<FarmingProduct> products) async {
    final createdIds = <String>[];

    await FirestoreClient.executeOperation(() async {
      final batch = FirestoreClient.instance.batch();

      for (final product in products) {
        final productId =
            product.id.isNotEmpty ? product.id : FarmingProduct.generateId();
        batch.set(
          FirestoreCollections.productsRef.doc(productId),
          product.copyWith(id: productId).toFirestore(),
        );
        createdIds.add(productId);
      }

      await batch.commit();
    });

    return createdIds;
  }
}
