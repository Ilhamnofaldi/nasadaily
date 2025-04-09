import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:nasa_daily_snapshot/models/apod_model.dart';

class ApiService {
  static const String _baseUrl = 'https://api.nasa.gov/planetary/apod';
  static const String _apiKey = 'DEMO_KEY'; // Replace with your NASA API key

  Future<ApodModel> getApod({String? date}) async {
    final url = Uri.parse('$_baseUrl?api_key=$_apiKey${date != null ? '&date=$date' : ''}');
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApodModel.fromJson(data);
      } else {
        throw Exception('Failed to load APOD: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching APOD: $e');
    }
  }
  
  Future<List<ApodModel>> getApodRange({required String startDate, required String endDate}) async {
    final url = Uri.parse('$_baseUrl?api_key=$_apiKey&start_date=$startDate&end_date=$endDate');
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => ApodModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load APOD range: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching APOD range: $e');
    }
  }
  
  Future<List<ApodModel>> searchApod({required String query}) async {
    // Get the last 50 days of images to search through
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 50));
    
    final formattedEndDate = "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";
    final formattedStartDate = "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
    
    try {
      final apods = await getApodRange(startDate: formattedStartDate, endDate: formattedEndDate);
      
      // Filter results based on query
      final lowercaseQuery = query.toLowerCase();
      return apods.where((apod) {
        return apod.title.toLowerCase().contains(lowercaseQuery) || 
               apod.explanation.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      throw Exception('Error searching APOD: $e');
    }
  }
}
