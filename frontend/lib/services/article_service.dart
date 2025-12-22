import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';
import '../models/category.dart';
import 'api_service.dart';

class ArticleService {
  // Fetch all articles
  static Future<List<Article>> getArticles({int? categoryId}) async {
    try {
      String url = '${ApiService.baseUrl}/articles';
      if (categoryId != null) {
        url += '?category_id=$categoryId';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: ApiService.getHeaders(),
      );

      print('📤 Get articles response status: ${response.statusCode}');
      print('📤 Get articles response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Article.fromJson(json)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to fetch articles');
      }
    } catch (e) {
      print('❌ Get articles error: $e');
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Fetch single article by ID
  static Future<Article> getArticleById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/articles/$id'),
        headers: ApiService.getHeaders(),
      );

      print('📤 Get article by ID response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Article.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to fetch article');
      }
    } catch (e) {
      print('❌ Get article by ID error: $e');
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Fetch featured articles
  static Future<List<Article>> getFeaturedArticles() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/articles/featured'),
        headers: ApiService.getHeaders(),
      );

      print('📤 Get featured articles response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Article.fromJson(json)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to fetch featured articles');
      }
    } catch (e) {
      print('❌ Get featured articles error: $e');
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Search articles
  static Future<List<Article>> searchArticles(String query, {int? categoryId}) async {
    try {
      String url = '${ApiService.baseUrl}/articles/search?q=$query';
      if (categoryId != null) {
        url += '&category_id=$categoryId';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: ApiService.getHeaders(),
      );

      print('📤 Search articles response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Article.fromJson(json)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to search articles');
      }
    } catch (e) {
      print('❌ Search articles error: $e');
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Fetch all categories
  static Future<List<Category>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/categories'),
        headers: ApiService.getHeaders(),
      );

      print('📤 Get categories response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Category.fromJson(json)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to fetch categories');
      }
    } catch (e) {
      print('❌ Get categories error: $e');
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Fetch articles on sale (with discounts)
  static Future<List<Article>> getArticlesOnSale() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/articles/on-sale'),
        headers: ApiService.getHeaders(),
      );

      print('📤 Get sale articles response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Article.fromJson(json)).toList();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to fetch sale articles');
      }
    } catch (e) {
      print('❌ Get sale articles error: $e');
      throw Exception('Network error: ${e.toString()}');
    }
  }
}