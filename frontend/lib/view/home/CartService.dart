import 'dart:convert';
import 'package:http/http.dart' as http;

class CartService {
  final String baseUrl =
      "http://localhost:5000/api/cart"; // Update with actual server address

  // Add an item to the cart
  Future<http.Response> addToCart(String userId, String itemId) async {
    final response = await http.post(
      Uri.parse(
          '$baseUrl/cart/$itemId'), // Matches the backend route for addToCart
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(
          {"userId": userId}), // Pass userId in the request body if required
    );
    return response;
  }

  // Save the entire cart to the database
  Future<void> saveCart(
      String userId, List<Map<String, dynamic>> cartItems) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/save-cart'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'cartItems': cartItems,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to save cart. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in saveCart: $e');
      throw Exception('Error saving cart: $e');
    }
  }

  // Remove an item from the cart
  Future<void> removeFromCart(String userId, String itemId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/remove-item/$userId/$itemId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to remove item. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in removeFromCart: $e');
      throw Exception('Error removing item from cart: $e');
    }
  }

  // Fetch all cart items for a user
  Future<List<Map<String, dynamic>>> fetchCart(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/fetch-cart/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['cartItems']);
      } else {
        throw Exception('Failed to load cart. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchCart: $e');
      throw Exception('Error fetching cart: $e');
    }
  }

  // Update the quantity of an item in the cart
  Future<void> updateCartItemQuantity(
      String userId, String itemId, int quantity) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/update-quantity/$userId/$itemId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'quantity': quantity,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to update quantity. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in updateCartItemQuantity: $e');
      throw Exception('Error updating quantity: $e');
    }
  }
}
