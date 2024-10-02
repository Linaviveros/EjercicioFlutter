import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'product.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Store Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: false,
      ),
      home: const ProductListScreen(),
    );
  }
}

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _dbHelper = DatabaseHelper.instance;
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await _dbHelper.getProducts();
    setState(() {
      _products = products.map((map) => Product.fromMap(map)).toList();
    });
  }

  Future<void> _addProduct(String name, double price, int quantity) async {
    final product = Product(name: name, price: price, quantity: quantity);
    await _dbHelper.insertProduct(product.toMap());
    _loadProducts();
  }

  Future<void> _updateProduct(Product product) async {
    await _dbHelper.updateProduct(product.toMap());
    _loadProducts();
  }

  Future<void> _deleteProduct(int id) async {
    await _dbHelper.deleteProduct(id);
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Productos'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: 'Nombre del producto'),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(hintText: 'Precio'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(hintText: 'cantidad'),
                  keyboardType: TextInputType.number,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        priceController.text.isNotEmpty &&
                        quantityController.text.isNotEmpty) {
                      _addProduct(
                        nameController.text,
                        double.parse(priceController.text),
                        int.parse(quantityController.text),
                      );
                      nameController.clear();
                      priceController.clear();
                      quantityController.clear();
                    }
                  },
                  child: const Text('Nuevo Producto'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text('Precio: \$${product.price}, Cantidad: ${product.quantity}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _deleteProduct(product.id!);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
