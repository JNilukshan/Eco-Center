import 'dart:convert';
import 'package:http/http.dart' as http;

class VegetableService {
  final String baseUrl = 'http://localhost:5000/api/vegetables';

  // Fetch vegetables from database
  Future<List<Map<String, dynamic>>> fetchVegetables() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception(
            'Failed to load vegetables. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchVegetables: $e');
      throw Exception('Error: $e');
    }
  }

  // Update stock of a specific vegetable item in the database
  Future<void> updateStock(String itemId, int newQuantity) async {
    try {
      final response = await http.put(
        Uri.parse(
            '$baseUrl/update-stock/$itemId'), // Ensure the URL matches your API route
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'quantity': newQuantity}),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to update stock. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in updateStock: $e');
      throw Exception('Error updating stock: $e');
    }
  }
}
