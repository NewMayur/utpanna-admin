import 'package:cloud_firestore/cloud_firestore.dart';

/// Crop model - represents agricultural crops
class Crop {
  final String id; // Auto-generated: c_[number]
  final String
      name; // Display name in local language (e.g., "कापूस", "सोयाबीन")
  final String?
      imageAsset; // Path to asset image (e.g., "assets/crops/cotton.png")

  const Crop({
    required this.id,
    required this.name,
    this.imageAsset,
  });

  /// Factory constructor for Firestore document
  factory Crop.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Crop(
      id: doc.id,
      name: data['name'] ?? '',
      imageAsset: data['imageAsset'],
    );
  }

  /// Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'imageAsset': imageAsset,
    };
  }

  /// Generate auto ID
  static String generateId() {
    final counter = DateTime.now().millisecondsSinceEpoch;
    return 'c_$counter';
  }

  /// Create copy with new values
  Crop copyWith({
    String? id,
    String? name,
    String? imageAsset,
  }) {
    return Crop(
      id: id ?? this.id,
      name: name ?? this.name,
      imageAsset: imageAsset ?? this.imageAsset,
    );
  }

  @override
  String toString() => name;
}

/// Objective model - represents farming objectives for crops
class Objective {
  final String id; // Auto-generated: obj_[number]
  final String
      name; // Display name in local language (e.g., "वाढीसाठी", "दाण्याचं वजन वाढवणे")

  const Objective({
    required this.id,
    required this.name,
  });

  /// Factory constructor for Firestore document
  factory Objective.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Objective(
      id: doc.id,
      name: data['name'] ?? '',
    );
  }

  /// Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
    };
  }

  /// Generate auto ID
  static String generateId() {
    final counter = DateTime.now().millisecondsSinceEpoch;
    return 'obj_$counter';
  }

  /// Create copy with new values
  Objective copyWith({
    String? id,
    String? name,
  }) {
    return Objective(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  String toString() => name;
}

/// Farming Product model - represents agricultural products
class FarmingProduct {
  final String id; // Auto-generated: p_[number]
  final String name; // Product name (e.g., "19:19:19", "Emoctan")
  final String
      category; // Product category (e.g., "खते", "कीटकनाशके", "बुरशीनाशके", "टॉनिक")
  final double price; // Selling price in rupees
  final double mrp; // Maximum retail price in rupees
  final String unit; // Unit of measurement (e.g., "1 L", "250 Gms", "1 Kg")
  final String? imageUrl; // URL to product image
  final String?
      activeDealId; // Auto-generated unique identifier of active deal for this product

  const FarmingProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.mrp,
    required this.unit,
    this.imageUrl,
    this.activeDealId,
  });

  /// Factory constructor for Firestore document
  factory FarmingProduct.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FarmingProduct(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      mrp: (data['mrp'] ?? data['price'] ?? 0.0).toDouble(),
      unit: data['unit'] ?? '',
      imageUrl: data['imageUrl'],
      activeDealId: data['activeDealId'],
    );
  }

  /// Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'mrp': mrp,
      'unit': unit,
      'imageUrl': imageUrl,
      'activeDealId': activeDealId,
    };
  }

  /// Generate auto ID
  static String generateId() {
    final counter = DateTime.now().millisecondsSinceEpoch;
    return 'p_$counter';
  }

  /// Calculate discount percentage
  double get discountPercent {
    if (mrp <= 0) return 0;
    return ((mrp - price) / mrp * 100).roundToDouble();
  }

  /// Create copy with new values
  FarmingProduct copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    double? mrp,
    String? unit,
    String? imageUrl,
    String? activeDealId,
  }) {
    return FarmingProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      mrp: mrp ?? this.mrp,
      unit: unit ?? this.unit,
      imageUrl: imageUrl ?? this.imageUrl,
      activeDealId: activeDealId ?? this.activeDealId,
    );
  }

  @override
  String toString() => '$name ($category)';
}

/// Recommendation Item model - represents a product in a recommendation
class RecommendationItem {
  final String productId; // Reference to product ID
  final double qtyAcre; // Quantity per acre
  final double qtyPump; // Quantity per pump

  const RecommendationItem({
    required this.productId,
    required this.qtyAcre,
    required this.qtyPump,
  });

  /// Factory constructor for Firestore data
  factory RecommendationItem.fromFirestoreData(Map<String, dynamic> data) {
    return RecommendationItem(
      productId: data['productId'] ?? '',
      qtyAcre: (data['qtyAcre'] ?? 0.0).toDouble(),
      qtyPump: (data['qtyPump'] ?? 0.0).toDouble(),
    );
  }

  /// Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'qtyAcre': qtyAcre,
      'qtyPump': qtyPump,
    };
  }

  /// Create copy with new values
  RecommendationItem copyWith({
    String? productId,
    double? qtyAcre,
    double? qtyPump,
  }) {
    return RecommendationItem(
      productId: productId ?? this.productId,
      qtyAcre: qtyAcre ?? this.qtyAcre,
      qtyPump: qtyPump ?? this.qtyPump,
    );
  }

  @override
  String toString() => 'Product: $productId, Acre: $qtyAcre, Pump: $qtyPump';
}

/// Recommendation model - links crop+objective combinations to products and deals
class Recommendation {
  final String cropId; // Reference to crop ID
  final String objectiveId; // Reference to objective ID
  final String dealId; // Auto-generated unique identifier of combo deal
  final String
      comboTitle; // Display title for the combo (e.g., "Cotton Growth Special")
  final List<RecommendationItem> items; // Products with quantities

  const Recommendation({
    required this.cropId,
    required this.objectiveId,
    required this.dealId,
    required this.comboTitle,
    required this.items,
  });

  /// Factory constructor for Firestore document
  factory Recommendation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Recommendation(
      cropId: doc.id.split('_')[0], // Derived from document ID
      objectiveId: doc.id.split('_')[1], // Derived from document ID
      dealId: data['dealId'] ?? '',
      comboTitle: data['comboTitle'] ?? '',
      items: (data['items'] as List<dynamic>? ?? [])
          .map((item) => RecommendationItem.fromFirestoreData(item))
          .toList(),
    );
  }

  /// Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'dealId': dealId,
      'comboTitle': comboTitle,
      'items': items.map((item) => item.toFirestore()).toList(),
      'cropId': cropId, // Store explicitly for queries
      'objectiveId': objectiveId, // Store explicitly for queries
    };
  }

  /// Generate document ID (cropId_objectiveId)
  String get documentId => '${cropId}_${objectiveId}';

  /// Generate auto deal ID
  static String generateDealId() {
    final counter = DateTime.now().millisecondsSinceEpoch;
    return 'deal_$counter';
  }

  /// Create copy with new values
  Recommendation copyWith({
    String? cropId,
    String? objectiveId,
    String? dealId,
    String? comboTitle,
    List<RecommendationItem>? items,
  }) {
    return Recommendation(
      cropId: cropId ?? this.cropId,
      objectiveId: objectiveId ?? this.objectiveId,
      dealId: dealId ?? this.dealId,
      comboTitle: comboTitle ?? this.comboTitle,
      items: items ?? this.items,
    );
  }

  @override
  String toString() => '$comboTitle (Deal: $dealId)';
}

/// Complete farming data model for JSON migration
class FarmingData {
  final List<Crop> crops;
  final List<Objective> objectives;
  final List<FarmingProduct> products;
  final List<Recommendation> recommendations;

  const FarmingData({
    required this.crops,
    required this.objectives,
    required this.products,
    required this.recommendations,
  });

  /// Factory constructor for JSON data (migration support)
  factory FarmingData.fromJson(Map<String, dynamic> json) {
    return FarmingData(
      crops: (json['crops'] as List<dynamic>? ?? [])
          .map((crop) => Crop(
                id: 'c_${DateTime.now().millisecondsSinceEpoch}_${crop['id'] ?? '0'}',
                name: crop['name'] ?? '',
                imageAsset: crop['image_asset'],
              ))
          .toList(),
      objectives: (json['objectives'] as List<dynamic>? ?? [])
          .map((objective) => Objective(
                id: 'obj_${DateTime.now().millisecondsSinceEpoch}_${objective['id'] ?? '0'}',
                name: objective['name'] ?? '',
              ))
          .toList(),
      products: (json['products'] as List<dynamic>? ?? [])
          .map((product) => FarmingProduct(
                id: 'p_${DateTime.now().millisecondsSinceEpoch}_${product['id'] ?? '0'}',
                name: product['name'] ?? '',
                category: product['category'] ?? '',
                price: (product['price'] ?? 0.0).toDouble(),
                mrp: (product['mrp'] ?? product['price'] ?? 0.0).toDouble(),
                unit: product['unit'] ?? '',
                imageUrl: product['image_url'],
                activeDealId: product['active_deal_uuid'],
              ))
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>? ?? [])
          .map((recommendation) => Recommendation(
                cropId: 'c_${recommendation['crop_id'] ?? 'unknown'}',
                objectiveId:
                    'obj_${recommendation['objective_id'] ?? 'unknown'}',
                dealId:
                    'deal_${DateTime.now().millisecondsSinceEpoch}_${recommendation['deal_uuid'] ?? ''}',
                comboTitle: recommendation['combo_title'] ?? '',
                items: (recommendation['items'] as List<dynamic>? ?? [])
                    .map((item) => RecommendationItem(
                          productId: 'p_${item['product_id'] ?? 'unknown'}',
                          qtyAcre: (item['qty_acre'] ?? 0.0).toDouble(),
                          qtyPump: (item['qty_pump'] ?? 0.0).toDouble(),
                        ))
                    .toList(),
              ))
          .toList(),
    );
  }
}
