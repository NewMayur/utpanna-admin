import 'package:dio/dio.dart';

class ItemService {
  final Dio _dio;
  final String baseUrl;

  ItemService(this._dio, this.baseUrl);

  Future<List<dynamic>> getItems() async {
    try {
      final response = await _dio.get('$baseUrl/items');
      return response.data;
    } catch (e) {
      print('Get items error: $e');
      return [];
    }
  }

  Future<bool> createItem(Map<String, dynamic> item) async {
    try {
      final response = await _dio.post('$baseUrl/items', data: item);
      return response.statusCode == 201;
    } catch (e) {
      print('Create item error: $e');
      return false;
    }
  }

  Future<bool> updateItem(String id, Map<String, dynamic> item) async {
    try {
      final response = await _dio.put('$baseUrl/items/$id', data: item);
      return response.statusCode == 200;
    } catch (e) {
      print('Update item error: $e');
      return false;
    }
  }

  Future<bool> deleteItem(String id) async {
    try {
      final response = await _dio.delete('$baseUrl/items/$id');
      return response.statusCode == 200;
    } catch (e) {
      print('Delete item error: $e');
      return false;
    }
  }
}
