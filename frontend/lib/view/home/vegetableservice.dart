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
        throw Exception('Failed to load vegetables. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchVegetables: $e');
      throw Exception('Error: $e');
    }
  }
}
