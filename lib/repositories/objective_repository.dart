import '../api/firestore_client.dart';
import '../api/collections.dart';
import '../models/farming_models.dart';

class ObjectiveRepository {
  final FirestoreClient _client;

  ObjectiveRepository(this._client);

  /// Get all objectives
  Future<List<Objective>> getAllObjectives() async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.objectivesRef.get();

      return snapshot.docs.map((doc) => Objective.fromFirestore(doc)).toList();
    });
  }

  /// Get objective by ID
  Future<Objective?> getObjectiveById(String objectiveId) async {
    return await FirestoreClient.executeOperation(() async {
      final doc =
          await FirestoreCollections.objectivesRef.doc(objectiveId).get();

      return doc.exists ? Objective.fromFirestore(doc) : null;
    });
  }

  /// Create new objective
  Future<String> createObjective(Objective objective) async {
    return await FirestoreClient.executeOperation(() async {
      final objectiveId = Objective.generateId();
      final objectiveWithId = Objective(
        id: objectiveId,
        name: objective.name,
      );

      await FirestoreCollections.objectivesRef
          .doc(objectiveId)
          .set(objectiveWithId.toFirestore());

      return objectiveId;
    });
  }

  /// Update objective
  Future<void> updateObjective(
      String objectiveId, Map<String, dynamic> updates) async {
    return await FirestoreClient.executeOperation(() async {
      await FirestoreCollections.objectivesRef.doc(objectiveId).update(updates);
    });
  }

  /// Delete objective (with validation)
  Future<void> deleteObjective(String objectiveId) async {
    return await FirestoreClient.executeOperation(() async {
      // Check if objective is referenced in any recommendations
      final recommendationsQuery = await FirestoreCollections.recommendationsRef
          .where('objectiveId', isEqualTo: objectiveId)
          .limit(1)
          .get();

      if (recommendationsQuery.docs.isNotEmpty) {
        throw Exception(
            'Cannot delete objective that is referenced in recommendations');
      }

      await FirestoreCollections.objectivesRef.doc(objectiveId).delete();
    });
  }

  /// Search objectives by name
  Future<List<Objective>> searchObjectives(String searchTerm) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.objectivesRef
          .where('name', isGreaterThanOrEqualTo: searchTerm)
          .where('name', isLessThan: searchTerm + '\uf8ff')
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) => Objective.fromFirestore(doc)).toList();
    });
  }

  /// Check if objective name exists (for validation)
  Future<bool> objectiveNameExists(String name, {String? excludeId}) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.objectivesRef
          .where('name', isEqualTo: name)
          .get();

      final docs = excludeId != null
          ? snapshot.docs.where((doc) => doc.id != excludeId)
          : snapshot.docs;

      return docs.isNotEmpty;
    });
  }

  /// Get objectives that are referenced in recommendations
  Future<Set<String>> getObjectivesWithRecommendations() async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.recommendationsRef.get();

      final objectiveIds = <String>{};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final objectiveId = data['objectiveId'] as String?;
        if (objectiveId != null) {
          objectiveIds.add(objectiveId);
        }
      }

      return objectiveIds;
    });
  }

  /// Get objectives ordered by usage in recommendations
  Future<List<Objective>> getObjectivesByUsage() async {
    final allObjectives = await getAllObjectives();
    final usedObjectiveIds = await getObjectivesWithRecommendations();

    // Sort objectives with used ones first
    allObjectives.sort((a, b) {
      final aUsed = usedObjectiveIds.contains(a.id);
      final bUsed = usedObjectiveIds.contains(b.id);

      if (aUsed && !bUsed) return -1;
      if (!aUsed && bUsed) return 1;
      return a.name.compareTo(b.name);
    });

    return allObjectives;
  }

  /// Batch create objectives (for migration)
  Future<List<String>> batchCreateObjectives(List<Objective> objectives) async {
    final createdIds = <String>[];

    await FirestoreClient.executeOperation(() async {
      final batch = FirestoreClient.instance.batch();

      for (final objective in objectives) {
        final objectiveId =
            objective.id.isNotEmpty ? objective.id : Objective.generateId();
        batch.set(
          FirestoreCollections.objectivesRef.doc(objectiveId),
          objective.copyWith(id: objectiveId).toFirestore(),
        );
        createdIds.add(objectiveId);
      }

      await batch.commit();
    });

    return createdIds;
  }
}
