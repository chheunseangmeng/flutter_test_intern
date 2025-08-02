import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';

class EditProductScreen extends StatefulWidget {
  final int productId;
  const EditProductScreen({super.key, required this.productId});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  bool _isLoadingProduct = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _priceController = TextEditingController();
    _stockController = TextEditingController();
    _loadProductData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _loadProductData() {
    Provider.of<ProductProvider>(context, listen: false)
        .fetchProducts(id: widget.productId)
        .then((_) {
      setState(() {
        _isLoadingProduct = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Edit Product',
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
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _submitForm,
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (_isLoadingProduct || provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.teal));
          }

          final product = provider.singleProduct ??
              Product(
                productId: widget.productId,
                productName: '',
                price: 0,
                stock: 0,
              );

          if (_nameController.text.isEmpty && product.productName.isNotEmpty) {
            _nameController.text = product.productName;
            _priceController.text = product.price.toStringAsFixed(2);
            _stockController.text = product.stock.toString();
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (provider.error.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Text(
                          provider.error,
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),
                    _buildTextField(
                      controller: _nameController,
                      label: 'Product Name',
                      icon: Icons.shopping_bag,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter product name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _priceController,
                      label: 'Price',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Price must be greater than 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _stockController,
                      label: 'Stock Quantity',
                      icon: Icons.inventory,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter stock quantity';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (int.parse(value) <= 0) {
                          return 'Stock must be greater than 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal[600],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        onPressed: provider.isLoading ? null : _submitForm,
                        child: provider.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Update Product',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.teal[700]),
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
        prefixIcon: Icon(icon, color: Colors.teal[600]),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: validator,
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final updatedProduct = Product(
        productId: widget.productId,
        productName: _nameController.text,
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
      );
      Provider.of<ProductProvider>(context, listen: false)
          .updateProduct(widget.productId, updatedProduct)
          .then((_) {
        final provider = Provider.of<ProductProvider>(context, listen: false);
        if (provider.error.isEmpty) {
          Navigator.pop(context); // Ensure navigation back
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product updated successfully'),
              backgroundColor: Colors.teal,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }
}