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

//// ************************ EXECUTE_COMMAND ************************
// flutter analyze showed that the Alternative and User classes are missing
// I need to add these classes to make the code compile

/// Farming Product model - represents agricultural products (Main Product)
class FarmingProduct {
  final String id; // Auto-generated: p_[number]
  final String name; // Product name (e.g., "19:19:19", "Emoctan")
  final String title; // Display title (may be same as name)
  final String activeIngredient; // Active ingredient
  final String chemicalComposition; // Chemical composition
  final String modeOfAction; // How the product works
  final String usedFor; // What it's used for
  final String usageDirection; // Usage instructions
  final String
      category; // Product category (e.g., "खते", "कीटकनाशके", "बुरशीनाशके", "टॉनिक")
  final double price; // Selling price in rupees
  final double mrp; // Maximum retail price in rupees
  final int savings; // Savings amount
  final String unit; // Unit of measurement (e.g., "1 L", "250 Gms", "1 Kg")
  final List<String>? imageUrls; // URLs to product images
  final String?
      activeDealId; // Auto-generated unique identifier of active deal for this product

  const FarmingProduct({
    required this.id,
    required this.name,
    required this.title,
    required this.activeIngredient,
    required this.chemicalComposition,
    required this.modeOfAction,
    required this.usedFor,
    required this.usageDirection,
    required this.category,
    required this.price,
    required this.mrp,
    required this.savings,
    required this.unit,
    this.imageUrls,
    this.activeDealId,
  });

  /// Factory constructor for Firestore document
  factory FarmingProduct.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FarmingProduct(
      id: doc.id,
      name: data['name'] ?? '',
      title: data['title'] ?? data['name'] ?? '',
      activeIngredient: data['activeIngredient'] ?? '',
      chemicalComposition: data['chemicalComposition'] ?? '',
      modeOfAction: data['modeOfAction'] ?? '',
      usedFor: data['usedFor'] ?? '',
      usageDirection: data['usageDirection'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      mrp: (data['mrp'] ?? data['price'] ?? 0.0).toDouble(),
      savings: data['savings'] ?? 0,
      unit: data['unit'] ?? '',
      imageUrls: data['imageUrls'] != null
          ? List<String>.from(data['imageUrls'])
          : null,
      activeDealId: data['activeDealId'],
    );
  }

  /// Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'title': title,
      'activeIngredient': activeIngredient,
      'chemicalComposition': chemicalComposition,
      'modeOfAction': modeOfAction,
      'usedFor': usedFor,
      'usageDirection': usageDirection,
      'category': category,
      'price': price,
      'mrp': mrp,
      'savings': savings,
      'unit': unit,
      'imageUrls': imageUrls,
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
    String? title,
    String? activeIngredient,
    String? chemicalComposition,
    String? modeOfAction,
    String? usedFor,
    String? usageDirection,
    String? category,
    double? price,
    double? mrp,
    int? savings,
    String? unit,
    List<String>? imageUrls,
    String? activeDealId,
  }) {
    return FarmingProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      activeIngredient: activeIngredient ?? this.activeIngredient,
      chemicalComposition: chemicalComposition ?? this.chemicalComposition,
      modeOfAction: modeOfAction ?? this.modeOfAction,
      usedFor: usedFor ?? this.usedFor,
      usageDirection: usageDirection ?? this.usageDirection,
      category: category ?? this.category,
      price: price ?? this.price,
      mrp: mrp ?? this.mrp,
      savings: savings ?? this.savings,
      unit: unit ?? this.unit,
      imageUrls: imageUrls ?? this.imageUrls,
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
                title: product['title'] ?? product['name'] ?? '',
                activeIngredient: product['activeIngredient'] ?? '',
                chemicalComposition: product['chemicalComposition'] ?? '',
                modeOfAction: product['modeOfAction'] ?? '',
                usedFor: product['usedFor'] ?? '',
                usageDirection: product['usageDirection'] ?? '',
                category: product['category'] ?? '',
                price: (product['price'] ?? 0.0).toDouble(),
                mrp: (product['mrp'] ?? product['price'] ?? 0.0).toDouble(),
                savings: product['savings'] ?? 0,
                unit: product['unit'] ?? '',
                imageUrls: product['imageUrls'] != null
                    ? List<String>.from(product['imageUrls'])
                    : null,
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

/// Alternative Product model - represents cheaper alternatives to main products
class Alternative {
  final String id; // Auto-generated: alt_[number]
  final String parentProductId; // Foreign Key to main product
  final String title; // Alternative product name
  final String activeIngredient; // Active ingredient
  final String chemicalComposition; // Chemical composition
  final String modeOfAction; // How the product works
  final String usedFor; // What it's used for
  final String usageDirection; // Usage instructions
  final double price; // Alternative price (lower than main)
  final int savings; // Savings amount
  final List<String>? imageUrls; // URLs to alternative images
  final DateTime createdAt;

  const Alternative({
    required this.id,
    required this.parentProductId,
    required this.title,
    required this.activeIngredient,
    required this.chemicalComposition,
    required this.modeOfAction,
    required this.usedFor,
    required this.usageDirection,
    required this.price,
    required this.savings,
    this.imageUrls,
    required this.createdAt,
  });

  /// Factory constructor for Firestore document
  factory Alternative.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Alternative(
      id: doc.id,
      parentProductId: data['parentProductId'] ?? '',
      title: data['title'] ?? '',
      activeIngredient: data['activeIngredient'] ?? '',
      chemicalComposition: data['chemicalComposition'] ?? '',
      modeOfAction: data['modeOfAction'] ?? '',
      usedFor: data['usedFor'] ?? '',
      usageDirection: data['usageDirection'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      savings: data['savings'] ?? 0,
      imageUrls: data['imageUrls'] != null
          ? List<String>.from(data['imageUrls'])
          : null,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'parentProductId': parentProductId,
      'title': title,
      'activeIngredient': activeIngredient,
      'chemicalComposition': chemicalComposition,
      'modeOfAction': modeOfAction,
      'usedFor': usedFor,
      'usageDirection': usageDirection,
      'price': price,
      'savings': savings,
      'imageUrls': imageUrls,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Generate auto ID
  static String generateId() {
    final counter = DateTime.now().millisecondsSinceEpoch;
    return 'alt_$counter';
  }

  /// Create copy with new values
  Alternative copyWith({
    String? id,
    String? parentProductId,
    String? title,
    String? activeIngredient,
    String? chemicalComposition,
    String? modeOfAction,
    String? usedFor,
    String? usageDirection,
    double? price,
    int? savings,
    List<String>? imageUrls,
    DateTime? createdAt,
  }) {
    return Alternative(
      id: id ?? this.id,
      parentProductId: parentProductId ?? this.parentProductId,
      title: title ?? this.title,
      activeIngredient: activeIngredient ?? this.activeIngredient,
      chemicalComposition: chemicalComposition ?? this.chemicalComposition,
      modeOfAction: modeOfAction ?? this.modeOfAction,
      usedFor: usedFor ?? this.usedFor,
      usageDirection: usageDirection ?? this.usageDirection,
      price: price ?? this.price,
      savings: savings ?? this.savings,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => '$title (₹$price)';
}

/// Deal model for group buying deals
class Deal {
  final String id; // Auto-generated: deal_[number]
  final String title;
  final String description;
  final double mrp;
  final double dealPrice;
  final int minParticipants;
  final int currentParticipants;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String>? imageUrls; // Firebase Storage URLs

  Deal({
    required this.id,
    required this.title,
    required this.description,
    required this.mrp,
    required this.dealPrice,
    required this.minParticipants,
    this.currentParticipants = 0,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
    this.imageUrls,
  });

  /// Firestore serialization
  factory Deal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Helper function to handle both Timestamp and String date formats
    DateTime _parseDate(dynamic dateValue) {
      if (dateValue is Timestamp) {
        return dateValue.toDate();
      } else if (dateValue is String) {
        return DateTime.tryParse(dateValue) ?? DateTime.now();
      } else {
        return DateTime.now();
      }
    }

    return Deal(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      mrp: (data['mrp'] ?? 0.0).toDouble(),
      dealPrice: (data['dealPrice'] ?? 0.0).toDouble(),
      minParticipants: data['minParticipants'] ?? 0,
      currentParticipants: data['currentParticipants'] ?? 0,
      status: data['status'] ?? 'active',
      createdAt: _parseDate(data['createdAt']),
      updatedAt: _parseDate(data['updatedAt']),
      imageUrls: data['imageUrls'] != null
          ? List<String>.from(data['imageUrls'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'mrp': mrp,
      'dealPrice': dealPrice,
      'minParticipants': minParticipants,
      'currentParticipants': currentParticipants,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'imageUrls': imageUrls,
    };
  }

  /// Generate auto ID
  static String generateId() {
    final counter = DateTime.now().millisecondsSinceEpoch;
    return 'deal_$counter';
  }

  /// Legacy JSON methods for backward compatibility during migration
  factory Deal.fromJson(Map<String, dynamic> json) {
    return Deal(
      id: 'deal_${json['id']?.toString() ?? '0'}',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      mrp: (json['mrp'] ?? 0.0).toDouble(),
      dealPrice: (json['deal_price'] ?? 0.0).toDouble(),
      minParticipants: json['min_participants'] ?? 0,
      currentParticipants: json['current_participants'] ?? 0,
      status: json['status'] ?? 'active',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      imageUrls: json['images'] != null
          ? (json['images'] as List).map((e) => e.toString()).toList()
          : null,
    );
  }

  // Backward compatibility getters for existing code
  double get deal_price => dealPrice;
  int get min_participants => minParticipants;
  int get current_participants => currentParticipants;
  String get created_at => createdAt.toIso8601String();
  String get updated_at => updatedAt.toIso8601String();
  List<dynamic>? get images =>
      imageUrls?.map((url) => {'image_url': url}).toList();
  double? get progress_percentage =>
      minParticipants > 0 ? (currentParticipants / minParticipants) * 100 : 0.0;
  List<Participant>?
      participants; // For backward compatibility - loaded from REST API

  Map<String, dynamic> toJson() {
    return {
      'id': int.parse(id.split('_')[1]),
      'title': title,
      'description': description,
      'mrp': mrp,
      'deal_price': dealPrice,
      'min_participants': minParticipants,
      'current_participants': currentParticipants,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'images': imageUrls,
    };
  }

  @override
  String toString() => '$title (₹$dealPrice)';
}

/// Participant model for deal participants
class Participant {
  final int id;
  final String name;
  final String phone_number;
  final String address;
  final String joined_at;

  Participant({
    required this.id,
    required this.name,
    required this.phone_number,
    required this.address,
    required this.joined_at,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'],
      name: json['name'],
      phone_number: json['phone_number'],
      address: json['address'],
      joined_at: json['joined_at'],
    );
  }
}

/// User model for farmers
class User {
  final String uid;
  final String name;
  final String phone;
  final String? village;
  final DateTime registeredAt;
  final bool active;

  const User({
    required this.uid,
    required this.name,
    required this.phone,
    this.village,
    required this.registeredAt,
    this.active = true,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      uid: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      village: data['village'],
      registeredAt: data['registeredAt'] != null
          ? (data['registeredAt'] as Timestamp).toDate()
          : DateTime.now(),
      active: data['active'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'village': village,
      'registeredAt': Timestamp.fromDate(registeredAt),
      'active': active,
    };
  }

  @override
  String toString() => '$name ($phone)';
}
