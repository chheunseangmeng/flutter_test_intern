import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  Product? _singleProduct;
  bool _isLoading = false;
  String _error = '';
  int _totalItems = 0;
  bool _hasMoreItems = true;

  List<Product> get products => _products;
  Product? get singleProduct => _singleProduct;
  bool get isLoading => _isLoading;
  String get error => _error;
  int get totalItems => _totalItems;
  bool get hasMoreItems => _hasMoreItems;

  Future<void> fetchProducts({
    int page = 1,
    int itemsPerPage = 10,
    String searchQuery = '',
    String sortOption = 'id_desc',
    int? id,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      if (id != null) {
        final product = await ApiService.getProducts(id: id);
        _singleProduct = product as Product;
        _products = [product];
        _hasMoreItems = false;
      } else {
        final response = await ApiService.getProducts(
          page: page,
          itemsPerPage: itemsPerPage,
          searchQuery: searchQuery,
          sortOption: sortOption,
        );
        final List<Product> fetchedProducts = response['products'] as List<Product>;
        _totalItems = response['totalItems'] as int;

        // Replace products with the new page's data instead of appending
        _products = fetchedProducts;

        _hasMoreItems = fetchedProducts.length == itemsPerPage &&
            _products.length < _totalItems;
      }
      _error = '';
    } catch (e) {
      _error = 'Failed to fetch products: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(
    String query, {
    String sortOption = 'id_desc',
    int page = 1,
    int itemsPerPage = 10,
  }) {
    fetchProducts(
      page: page,
      itemsPerPage: itemsPerPage,
      searchQuery: query,
      sortOption: sortOption,
    );
  }

  Future<void> addProduct(Product product) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newProduct = await ApiService.createProduct(product);
      // Insert new product at the beginning of the list
      _products.insert(0, newProduct);
      _totalItems++;
      _error = '';
    } catch (e) {
      _error = 'Failed to add product: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProduct(int id, Product product) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedProduct = await ApiService.updateProduct(id, product);
      final index = _products.indexWhere((p) => p.productId == id);
      if (index != -1) {
        _products[index] = updatedProduct;
      }
      _singleProduct = updatedProduct;
      _error = '';
    } catch (e) {
      _error = 'Failed to update product: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.deleteProduct(id);
      _products.removeWhere((p) => p.productId == id);
      _totalItems--;
      _error = '';
    } catch (e) {
      _error = 'Failed to delete product: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}