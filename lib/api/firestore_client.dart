import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreClient {
  static FirebaseFirestore get instance => FirebaseFirestore.instance;

  /// Execute a Firestore operation with error handling
  static Future<T> executeOperation<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (e) {
      print('Firestore operation error: $e');
      throw Exception('Firestore operation failed: $e');
    }
  }

  /// Execute a Firestore operation that returns a stream
  static Stream<T> executeStreamOperation<T>(Stream<T> Function() operation) {
    try {
      return operation();
    } catch (e) {
      print('Firestore stream operation error: $e');
      throw Exception('Firestore stream operation failed: $e');
    }
  }

  /// Batch operations helper
  static Future<void> executeBatch(
      Future<void> Function(WriteBatch batch) batchOperation) async {
    final batch = instance.batch();

    await FirestoreClient.executeOperation(() async {
      await batchOperation(batch);
      await batch.commit();
    });
  }
}
