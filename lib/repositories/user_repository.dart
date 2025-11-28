import 'package:cloud_firestore/cloud_firestore.dart';
import '../api/firestore_client.dart';
import '../api/collections.dart';
import '../models/farming_models.dart';

class UserRepository {
  final FirestoreClient _client;

  UserRepository(this._client);

  /// Get all users (farmers)
  Future<List<User>> getAllUsers() async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.usersRef
          .orderBy('registeredAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
    });
  }

  /// Get user by ID
  Future<User?> getUserById(String userId) async {
    return await FirestoreClient.executeOperation(() async {
      final doc = await FirestoreCollections.usersRef.doc(userId).get();

      return doc.exists ? User.fromFirestore(doc) : null;
    });
  }

  /// Get user by phone number
  Future<User?> getUserByPhone(String phone) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.usersRef
          .where('phone', isEqualTo: phone)
          .get();

      return snapshot.docs.isNotEmpty
          ? User.fromFirestore(snapshot.docs.first)
          : null;
    });
  }

  /// Create new user
  Future<String> createUser(User user) async {
    return await FirestoreClient.executeOperation(() async {
      final userWithId = User(
        uid: user.uid.isNotEmpty ? user.uid : '',
        name: user.name,
        phone: user.phone,
        village: user.village,
        registeredAt: user.registeredAt,
        active: user.active,
      );

      await FirestoreCollections.usersRef
          .doc(user.uid)
          .set(userWithId.toFirestore());

      return user.uid;
    });
  }

  /// Update user
  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    return await FirestoreClient.executeOperation(() async {
      await FirestoreCollections.usersRef.doc(userId).update(updates);
    });
  }

  /// Delete user
  Future<void> deleteUser(String userId) async {
    return await FirestoreClient.executeOperation(() async {
      await FirestoreCollections.usersRef.doc(userId).delete();
    });
  }

  /// Search users by phone number
  Future<List<User>> searchUsersByPhone(String phoneQuery) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.usersRef
          .where('phone', isGreaterThanOrEqualTo: phoneQuery)
          .where('phone', isLessThan: phoneQuery + '\uf8ff')
          .orderBy('phone')
          .get();

      return snapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
    });
  }

  /// Get users by village
  Future<List<User>> getUsersByVillage(String village) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.usersRef
          .where('village', isEqualTo: village)
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
    });
  }

  /// Get active users
  Future<List<User>> getActiveUsers() async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.usersRef
          .where('active', isEqualTo: true)
          .orderBy('registeredAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
    });
  }

  /// Get recent users (registered within last 30 days)
  Future<List<User>> getRecentUsers({int days = 30}) async {
    return await FirestoreClient.executeOperation(() async {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      final snapshot = await FirestoreCollections.usersRef
          .where('registeredAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(cutoffDate))
          .orderBy('registeredAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
    });
  }

  /// Get all unique villages
  Future<List<String>> getAllVillages() async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.usersRef.get();

      final villages = <String>{};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final village = data['village'] as String?;
        if (village != null && village.isNotEmpty) {
          villages.add(village);
        }
      }

      return villages.toList()..sort();
    });
  }

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStats() async {
    return await FirestoreClient.executeOperation(() async {
      final allUsers = await getAllUsers();
      final activeUsers = allUsers.where((user) => user.active).toList();
      final recentUsers = await getRecentUsers(days: 30);

      return {
        'total_users': allUsers.length,
        'active_users': activeUsers.length,
        'inactive_users': allUsers.length - activeUsers.length,
        'recent_users': recentUsers.length,
      };
    });
  }

  /// Toggle user active status
  Future<void> toggleUserActiveStatus(String userId, bool active) async {
    return await FirestoreClient.executeOperation(() async {
      await FirestoreCollections.usersRef.doc(userId).update({
        'active': active,
      });
    });
  }
}
