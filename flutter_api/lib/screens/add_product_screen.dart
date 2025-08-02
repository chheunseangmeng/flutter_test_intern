import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Add New Product',
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
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
                      return 'Please enter valid number';
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
                      return 'Please enter valid number';
                    }
                    if (int.parse(value) <= 0) {
                      return 'Stock must be greater than 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Consumer<ProductProvider>(
                  builder: (context, provider, child) {
                    return SizedBox(
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
                                'Add Product',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
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
      final newProduct = Product(
        productId: 0, // Will be assigned by the database
        productName: _nameController.text,
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
      );
      Provider.of<ProductProvider>(context, listen: false)
          .addProduct(newProduct)
          .then((_) {
        if (Provider.of<ProductProvider>(context, listen: false).error.isEmpty) {
          Navigator.pop(context);
        }
      });
    }
  }
}