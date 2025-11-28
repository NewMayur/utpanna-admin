import '../models/farming_models.dart';
import '../repositories/crop_repository.dart';
import '../repositories/objective_repository.dart';
import '../repositories/product_repository.dart';
import '../repositories/recommendation_repository.dart';
import '../repositories/deal_repository.dart';
import '../api/firestore_client.dart';
import '../screens/admin_panel.dart'; // For Deal model

class FarmingDataService {
  final CropRepository _cropRepo;
  final ObjectiveRepository _objectiveRepo;
  final ProductRepository _productRepo;
  final RecommendationRepository _recommendationRepo;
  final DealRepository _dealRepo;

  FarmingDataService(FirestoreClient client)
      : _cropRepo = CropRepository(client),
        _objectiveRepo = ObjectiveRepository(client),
        _productRepo = ProductRepository(client),
        _recommendationRepo = RecommendationRepository(client),
        _dealRepo = DealRepository(client);

  // ==================== CROP OPERATIONS ====================

  /// Get all crops
  Future<List<Crop>> getAllCrops() => _cropRepo.getAllCrops();

  /// Get crop by ID
  Future<Crop?> getCropById(String cropId) => _cropRepo.getCropById(cropId);

  /// Create new crop
  Future<String> createCrop(Crop crop) async {
    // Validate crop name uniqueness
    final nameExists = await _cropRepo.cropNameExists(crop.name);
    if (nameExists) {
      throw Exception('Crop with this name already exists');
    }

    return await _cropRepo.createCrop(crop);
  }

  /// Update crop
  Future<void> updateCrop(String cropId, Map<String, dynamic> updates) async {
    // If updating name, check for uniqueness
    if (updates.containsKey('name')) {
      final nameExists =
          await _cropRepo.cropNameExists(updates['name'], excludeId: cropId);
      if (nameExists) {
        throw Exception('Crop with this name already exists');
      }
    }

    await _cropRepo.updateCrop(cropId, updates);
  }

  /// Delete crop with validation
  Future<void> deleteCrop(String cropId) async {
    final crop = await _cropRepo.getCropById(cropId);
    if (crop == null) {
      throw Exception('Crop not found');
    }

    // Repository already checks for references
    await _cropRepo.deleteCrop(cropId);
  }

  /// Search crops
  Future<List<Crop>> searchCrops(String searchTerm) =>
      _cropRepo.searchCrops(searchTerm);

  // ==================== OBJECTIVE OPERATIONS ====================

  /// Get all objectives
  Future<List<Objective>> getAllObjectives() =>
      _objectiveRepo.getAllObjectives();

  /// Get objective by ID
  Future<Objective?> getObjectiveById(String objectiveId) =>
      _objectiveRepo.getObjectiveById(objectiveId);

  /// Create new objective
  Future<String> createObjective(Objective objective) async {
    // Validate objective name uniqueness
    final nameExists = await _objectiveRepo.objectiveNameExists(objective.name);
    if (nameExists) {
      throw Exception('Objective with this name already exists');
    }

    return await _objectiveRepo.createObjective(objective);
  }

  /// Update objective
  Future<void> updateObjective(
      String objectiveId, Map<String, dynamic> updates) async {
    // If updating name, check for uniqueness
    if (updates.containsKey('name')) {
      final nameExists = await _objectiveRepo
          .objectiveNameExists(updates['name'], excludeId: objectiveId);
      if (nameExists) {
        throw Exception('Objective with this name already exists');
      }
    }

    await _objectiveRepo.updateObjective(objectiveId, updates);
  }

  /// Delete objective with validation
  Future<void> deleteObjective(String objectiveId) async {
    final objective = await _objectiveRepo.getObjectiveById(objectiveId);
    if (objective == null) {
      throw Exception('Objective not found');
    }

    // Repository already checks for references
    await _objectiveRepo.deleteObjective(objectiveId);
  }

  /// Get objectives ordered by usage
  Future<List<Objective>> getObjectivesOrderedByUsage() =>
      _objectiveRepo.getObjectivesByUsage();

  // ==================== PRODUCT OPERATIONS ====================

  /// Get all products
  Future<List<FarmingProduct>> getAllProducts() =>
      _productRepo.getAllProducts();

  /// Get products by category
  Future<List<FarmingProduct>> getProductsByCategory(String category) =>
      _productRepo.getProductsByCategory(category);

  /// Get product by ID
  Future<FarmingProduct?> getProductById(String productId) =>
      _productRepo.getProductById(productId);

  /// Create new product
  Future<String> createProduct(FarmingProduct product) async {
    // Validate product name uniqueness
    final nameExists = await _productRepo.productNameExists(product.name);
    if (nameExists) {
      throw Exception('Product with this name already exists');
    }

    // Validate price < mrp
    if (product.price >= product.mrp) {
      throw Exception('Product price must be less than MRP');
    }

    return await _productRepo.createProduct(product);
  }

  /// Update product
  Future<void> updateProduct(
      String productId, Map<String, dynamic> updates) async {
    // If updating name, check for uniqueness
    if (updates.containsKey('name')) {
      final nameExists = await _productRepo.productNameExists(updates['name'],
          excludeId: productId);
      if (nameExists) {
        throw Exception('Product with this name already exists');
      }
    }

    // If updating prices, validate logic
    if (updates.containsKey('price') || updates.containsKey('mrp')) {
      final currentProduct = await _productRepo.getProductById(productId);
      if (currentProduct != null) {
        final newPrice = updates['price'] ?? currentProduct.price;
        final newMrp = updates['mrp'] ?? currentProduct.mrp;

        if (newPrice >= newMrp) {
          throw Exception('Product price must be less than MRP');
        }
      }
    }

    await _productRepo.updateProduct(productId, updates);
  }

  /// Delete product with validation
  Future<void> deleteProduct(String productId) async {
    final product = await _productRepo.getProductById(productId);
    if (product == null) {
      throw Exception('Product not found');
    }

    // Repository already checks for references
    await _productRepo.deleteProduct(productId);
  }

  /// Search products
  Future<List<FarmingProduct>> searchProducts(String searchTerm) =>
      _productRepo.searchProducts(searchTerm);

  /// Get products with deals
  Future<List<FarmingProduct>> getProductsWithDeals() =>
      _productRepo.getProductsWithDeals();

  /// Get all categories
  Future<List<String>> getAllCategories() => _productRepo.getAllCategories();

  /// Advanced product filtering
  Future<List<FarmingProduct>> getFilteredProducts({
    String? category,
    double? minPrice,
    double? maxPrice,
    String? searchTerm,
    String? sortBy,
    bool ascending = true,
  }) =>
      _productRepo.getFilteredProducts(
        category: category,
        minPrice: minPrice,
        maxPrice: maxPrice,
        searchTerm: searchTerm,
        sortBy: sortBy,
        ascending: ascending,
      );

  /// Assign deal to product
  Future<void> assignDealToProduct(String productId, String dealId) async {
    await _productRepo.assignDeal(productId, dealId);
  }

  /// Clear deal assignment
  Future<void> clearDealFromProduct(String productId) async {
    await _productRepo.clearDealAssignment(productId);
  }

  // ==================== DEAL OPERATIONS ====================

  /// Get all deals
  Future<List<Deal>> getAllDeals() => _dealRepo.getAllDeals();

  /// Get deal by ID
  Future<Deal?> getDealById(String dealId) => _dealRepo.getDealById(dealId);

  /// Create new deal
  Future<String> createDeal(Deal deal) async {
    // Validate deal price < mrp
    if (deal.dealPrice >= deal.mrp) {
      throw Exception('Deal price must be less than MRP');
    }

    return await _dealRepo.createDeal(deal);
  }

  /// Update deal
  Future<void> updateDeal(String dealId, Map<String, dynamic> updates) async {
    // Validate price logic if prices are being updated
    if (updates.containsKey('dealPrice') || updates.containsKey('mrp')) {
      final currentDeal = await _dealRepo.getDealById(dealId);
      if (currentDeal != null) {
        final newDealPrice = updates['dealPrice'] ?? currentDeal.dealPrice;
        final newMrp = updates['mrp'] ?? currentDeal.mrp;

        if (newDealPrice >= newMrp) {
          throw Exception('Deal price must be less than MRP');
        }
      }
    }

    await _dealRepo.updateDeal(dealId, updates);
  }

  /// Delete deal
  Future<void> deleteDeal(String dealId) async {
    await _dealRepo.deleteDeal(dealId);
  }

  /// Search deals by title
  Future<List<Deal>> searchDeals(String searchTerm) =>
      _dealRepo.searchDeals(searchTerm);

  /// Get deals by status
  Future<List<Deal>> getDealsByStatus(String status) =>
      _dealRepo.getDealsByStatus(status);

  /// Get deal statistics
  Future<Map<String, dynamic>> getDealStats() => _dealRepo.getDealStats();

  /// Increment participant count for a deal
  Future<void> incrementDealParticipant(String dealId) async {
    await _dealRepo.incrementParticipant(dealId);
  }

  /// Update deal status
  Future<void> updateDealStatus(String dealId, String status) async {
    await _dealRepo.updateDealStatus(dealId, status);
  }

  // ==================== RECOMMENDATION OPERATIONS ====================

  /// Get all recommendations
  Future<List<Recommendation>> getAllRecommendations() =>
      _recommendationRepo.getAllRecommendations();

  /// Get recommendation by crop and objective
  Future<Recommendation?> getRecommendationByCropObjective(
          String cropId, String objectiveId) =>
      _recommendationRepo.getRecommendationById(cropId, objectiveId);

  /// Get recommendations for crop
  Future<List<Recommendation>> getRecommendationsForCrop(String cropId) =>
      _recommendationRepo.getRecommendationsForCrop(cropId);

  /// Get recommendations for objective
  Future<List<Recommendation>> getRecommendationsForObjective(
          String objectiveId) =>
      _recommendationRepo.getRecommendationsForObjective(objectiveId);

  /// Get recommendations for deal
  Future<List<Recommendation>> getRecommendationsForDeal(String dealId) =>
      _recommendationRepo.getRecommendationsForDeal(dealId);

  /// Create new recommendation
  Future<String> createRecommendation(Recommendation recommendation) async {
    // Validate that crop and objective exist
    final cropExists =
        await _cropRepo.getCropById(recommendation.cropId) != null;
    if (!cropExists) {
      throw Exception('Referenced crop does not exist');
    }

    final objectiveExists =
        await _objectiveRepo.getObjectiveById(recommendation.objectiveId) !=
            null;
    if (!objectiveExists) {
      throw Exception('Referenced objective does not exist');
    }

    // Validate that recommendation doesn't already exist
    final exists = await _recommendationRepo.recommendationExists(
        recommendation.cropId, recommendation.objectiveId);
    if (exists) {
      throw Exception(
          'Recommendation for this crop-objective combination already exists');
    }

    // Validate all products exist
    for (final item in recommendation.items) {
      final productExists =
          await _productRepo.getProductById(item.productId) != null;
      if (!productExists) {
        throw Exception(
            'Referenced product (${item.productId}) does not exist');
      }
    }

    return await _recommendationRepo.createRecommendation(recommendation);
  }

  /// Update recommendation
  Future<void> updateRecommendation(
      String cropId, String objectiveId, Map<String, dynamic> updates) async {
    // If updating items, validate all products exist
    if (updates.containsKey('items')) {
      final items = updates['items'] as List<dynamic>;
      for (final itemData in items) {
        final item = itemData as Map<String, dynamic>;
        final productId = item['productId'] as String;
        final productExists =
            await _productRepo.getProductById(productId) != null;
        if (!productExists) {
          throw Exception('Referenced product ($productId) does not exist');
        }
      }
    }

    await _recommendationRepo.updateRecommendation(
        cropId, objectiveId, updates);
  }

  /// Delete recommendation
  Future<void> deleteRecommendation(String cropId, String objectiveId) async {
    await _recommendationRepo.deleteRecommendation(cropId, objectiveId);
  }

  /// Update deal ID for recommendation
  Future<void> updateDealIdForRecommendation(
      String cropId, String objectiveId, String dealId) async {
    await _recommendationRepo.updateDealId(cropId, objectiveId, dealId);
  }

  /// Get recommendations with specific product
  Future<List<Recommendation>> getRecommendationsWithProduct(
          String productId) =>
      _recommendationRepo.getRecommendationsWithProduct(productId);

  /// Get recommendations summary
  Future<List<Map<String, dynamic>>> getRecommendationsSummary() =>
      _recommendationRepo.getRecommendationsSummary();

  // ==================== DATA INTEGRITY & VALIDATION ====================

  /// Validate all data consistency
  Future<Map<String, dynamic>> validateDataIntegrity() async {
    final issues = <String, List<String>>{};

    // Check for products referenced in recommendations but don't exist
    final productsInRecommendations = await _recommendationRepo
        .getAllRecommendations()
        .then((recs) =>
            recs.expand((r) => r.items.map((i) => i.productId)).toSet());

    final existingProducts = await _productRepo
        .getAllProducts()
        .then((products) => products.map((p) => p.id).toSet());

    final missingProducts =
        productsInRecommendations.difference(existingProducts);
    if (missingProducts.isNotEmpty) {
      issues['missing_products'] = missingProducts.toList();
    }

    // Check for crops referenced in recommendations but don't exist
    final cropsInRecommendations = await _recommendationRepo
        .getAllRecommendations()
        .then((recs) => recs.map((r) => r.cropId).toSet());

    final existingCrops = await _cropRepo
        .getAllCrops()
        .then((crops) => crops.map((c) => c.id).toSet());

    final missingCrops = cropsInRecommendations.difference(existingCrops);
    if (missingCrops.isNotEmpty) {
      issues['missing_crops'] = missingCrops.toList();
    }

    // Check for objectives referenced in recommendations but don't exist
    final objectivesInRecommendations = await _recommendationRepo
        .getAllRecommendations()
        .then((recs) => recs.map((r) => r.objectiveId).toSet());

    final existingObjectives = await _objectiveRepo
        .getAllObjectives()
        .then((objectives) => objectives.map((o) => o.id).toSet());

    final missingObjectives =
        objectivesInRecommendations.difference(existingObjectives);
    if (missingObjectives.isNotEmpty) {
      issues['missing_objectives'] = missingObjectives.toList();
    }

    return {
      'valid': issues.isEmpty,
      'issues': issues,
    };
  }

  // ==================== DASHBOARD STATISTICS ====================

  /// Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    final crops = await getAllCrops();
    final objectives = await getAllObjectives();
    final products = await getAllProducts();
    final recommendations = await getAllRecommendations();

    // Get products with deals
    final productsWithDeals = await getProductsWithDeals();

    // Get deals count (from products with deals for now)
    final dealIds = productsWithDeals
        .where((p) => p.activeDealId != null)
        .map((p) => p.activeDealId!)
        .toSet();

    return {
      'crops_count': crops.length,
      'objectives_count': objectives.length,
      'products_count': products.length,
      'recommendations_count': recommendations.length,
      'deals_count': dealIds.length,
      'products_with_deals_count': productsWithDeals.length,
    };
  }
}
