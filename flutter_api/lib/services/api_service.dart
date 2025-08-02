import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String baseUrl = 'http://172.20.10.2:5000/products'; // Update to 'http://localhost:5000/products' for local testing

  static Future<dynamic> getProducts({
    int? id,
    int page = 1,
    int itemsPerPage = 10,
    String searchQuery = '',
    String sortOption = 'name_asc',
  }) async {
    try {
      final queryParameters = id != null
          ? {'id': id.toString()}
          : {
              'page': page.toString(),
              'itemsPerPage': itemsPerPage.toString(),
              'search': searchQuery,
              'sort': sortOption,
            };
      final url = Uri.parse(baseUrl).replace(queryParameters: queryParameters);
      final response = await http.get(url);

      final jsonResponse = _parseResponse(response);

      if (id != null) {
        return Product.fromJson(jsonResponse['data'] as Map<String, dynamic>);
      } else {
        return {
          'products': (jsonResponse['data'] as List)
              .map((item) => Product.fromJson(item as Map<String, dynamic>))
              .toList(),
          'totalItems': jsonResponse['totalItems'] as int,
        };
      }
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  static Future<Product> createProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product.toJson()),
      );
      return Product.fromJson(_parseResponse(response)['data']);
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  static Future<Product> updateProduct(int id, Product product) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl?id=$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product.toJson()),
      );
      return Product.fromJson(_parseResponse(response)['data']);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  static Future<void> deleteProduct(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl?id=$id'));
      _parseResponse(response);
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  static Map<String, dynamic> _parseResponse(http.Response response) {
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (!(json['success'] as bool)) {
      throw Exception(json['message'] as String);
    }
    return json;
  }
}