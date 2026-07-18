import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // TODO: Replace with your Railway deployment URL
  static const String baseUrl = 'https://your-app.railway.app';
  
  // For local testing:
  // static const String baseUrl = 'http://localhost:8000';
  
  Future<Map<String, dynamic>> categorizeNote({
    required String text,
    bool isDeveloped = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/categorize'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': text,
          'is_developed': isDeveloped,
        }),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to categorize note: ${response.statusCode}');
      }
    } catch (e) {
      // If API fails, return a default category
      // This ensures capture never blocks
      return {
        'category': 'Uncategorized',
        'confidence': 0.0,
        'suggested_tags': null,
      };
    }
  }
  
  Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
