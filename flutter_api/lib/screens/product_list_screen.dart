import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../widgets/product_item.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';
import '../utils/export_utils.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _sortOption = 'id_desc'; // Default to show newest products first
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  bool _isLoadingPage = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    Provider.of<ProductProvider>(context, listen: false).fetchProducts(
      page: _currentPage,
      itemsPerPage: _itemsPerPage,
      sortOption: _sortOption,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      Provider.of<ProductProvider>(context, listen: false).setSearchQuery(
        _searchController.text,
        sortOption: _sortOption,
        page: 1,
        itemsPerPage: _itemsPerPage,
      );
      setState(() {
        _currentPage = 1;
      });
    });
  }

  void _loadPage(int page) {
    if (_isLoadingPage || page == _currentPage) return;
    setState(() {
      _isLoadingPage = true;
      _currentPage = page;
    });
    Provider.of<ProductProvider>(context, listen: false)
        .fetchProducts(
      page: _currentPage,
      itemsPerPage: _itemsPerPage,
      searchQuery: _searchController.text,
      sortOption: _sortOption,
    )
        .then((_) {
      setState(() {
        _isLoadingPage = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Product Manager',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                _currentPage = 1;
              });
              Provider.of<ProductProvider>(context, listen: false).fetchProducts(
                page: 1,
                itemsPerPage: _itemsPerPage,
                searchQuery: _searchController.text,
                sortOption: _sortOption,
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.download, color: Colors.white),
            onSelected: (value) {
              final products =
                  Provider.of<ProductProvider>(context, listen: false).products;
              if (value == 'pdf') {
                ExportUtils.exportToPDF(products, context);
              } else if (value == 'csv') {
                ExportUtils.exportToCSV(products, context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf, color: Colors.teal),
                    SizedBox(width: 8),
                    Text('Export to PDF'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'csv',
                child: Row(
                  children: [
                    Icon(Icons.table_chart, color: Colors.teal),
                    SizedBox(width: 8),
                    Text('Export to CSV'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search by Name',
                      prefixIcon: Icon(Icons.search, color: Colors.teal[600]),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.teal[600]),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.teal[200]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.teal[200]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.teal[600]!, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                DropdownButton<String>(
                  value: _sortOption,
                  icon: Icon(Icons.sort, color: Colors.teal[600]),
                  style: TextStyle(color: Colors.teal[700], fontSize: 20),
                  dropdownColor: Colors.white,
                  items: const [
                    DropdownMenuItem(value: 'id_desc', child: Text('Newest First')),
                    DropdownMenuItem(value: 'name_asc', child: Text('Name ↑')),
                    DropdownMenuItem(value: 'name_desc', child: Text('Name ↓')),
                    DropdownMenuItem(value: 'price_asc', child: Text('Price ↑')),
                    DropdownMenuItem(value: 'price_desc', child: Text('Price ↓')),
                    DropdownMenuItem(value: 'stock_asc', child: Text('Stock ↑')),
                    DropdownMenuItem(value: 'stock_desc', child: Text('Stock ↓')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _sortOption = value;
                        _currentPage = 1;
                      });
                      Provider.of<ProductProvider>(context, listen: false)
                          .setSearchQuery(
                        _searchController.text,
                        sortOption: value,
                        page: 1,
                        itemsPerPage: _itemsPerPage,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Consumer<ProductProvider>(
              builder: (context, provider, child) {
                final totalPages = (provider.totalItems / _itemsPerPage).ceil();
                return Text(
                  'Page $_currentPage of $totalPages',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.teal[700],
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.products.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: Colors.teal));
                }
                if (provider.error.isNotEmpty) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            provider.error,
                            style: const TextStyle(color: Colors.red, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal[600],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            ),
                            onPressed: () => provider.fetchProducts(
                              page: _currentPage,
                              itemsPerPage: _itemsPerPage,
                              searchQuery: _searchController.text,
                              sortOption: _sortOption,
                            ),
                            child: const Text(
                              'Retry',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (provider.products.isEmpty) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      child: const Text(
                        'No products found\nTap Add Product to create a new product',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }
                return RefreshIndicator(
                  color: Colors.teal[600],
                  onRefresh: () => provider.fetchProducts(
                    page: 1,
                    itemsPerPage: _itemsPerPage,
                    searchQuery: _searchController.text,
                    sortOption: _sortOption,
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80, top: 8, left: 16, right: 16),
                    itemCount: provider.products.length,
                    itemBuilder: (context, index) {
                      final product = provider.products[index];
                      return ProductItem(
                        product: product,
                        onEdit: () => _editProduct(context, product.productId),
                        onDelete: () => _confirmDelete(context, product.productId),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<ProductProvider>(
              builder: (context, provider, child) {
                final totalPages = (provider.totalItems / _itemsPerPage).ceil();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.chevron_left,
                        color: _currentPage > 1 ? Colors.teal[600] : Colors.grey[400],
                        size: 32,
                      ),
                      onPressed: _currentPage > 1 && !_isLoadingPage
                          ? () => _loadPage(_currentPage - 1)
                          : null,
                    ),
                    if (_isLoadingPage)
                      const CircularProgressIndicator(color: Colors.teal),
                    IconButton(
                      icon: Icon(
                        Icons.chevron_right,
                        color: provider.hasMoreItems && _currentPage < totalPages
                            ? Colors.teal[600]
                            : Colors.grey[400],
                        size: 32,
                      ),
                      onPressed: provider.hasMoreItems &&
                              _currentPage < totalPages &&
                              !_isLoadingPage
                          ? () => _loadPage(_currentPage + 1)
                          : null,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal[600],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          );
          setState(() {
            _currentPage = 1;
            _searchController.clear();
            _sortOption = 'id_desc';
          });
          Provider.of<ProductProvider>(context, listen: false).fetchProducts(
            page: 1,
            itemsPerPage: _itemsPerPage,
            searchQuery: '',
            sortOption: 'id_desc',
          );
        },
        label: const Text(
          'Add Product',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _editProduct(BuildContext context, int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(productId: id),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Product',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        content: const Text(
          'Are you sure you want to delete this product? This action cannot be undone.',
          style: TextStyle(color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<ProductProvider>(context, listen: false).deleteProduct(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 2,
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 8,
      ),
    );
  }
}