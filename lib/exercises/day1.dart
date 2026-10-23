// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:convert';
import 'dart:io';

class Product {
  final int id;
  final String name;
  final double? price; // nullable عمدًا

  const Product({required this.id, required this.name, this.price});

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as int,
    name: json['name'] as String,
    price: (json['price'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'price': price};

  @override
  String toString() => 'Product($id, $name, $price)';
}

Product? mostExpensive(List<Product>? products) {
  if (products == null || products.isEmpty) return null;
  Product? best;
  for (final p in products) {
    final price = p.price;
    if (price == null) continue;
    if (best == null || price > best.price!) best = p;
  }
  return best;
}

Future<Map<String, dynamic>?> fetchPost(int id) async {
  final client = HttpClient();
  try {
    final uri = Uri.parse('https://jsonplaceholder.typicode.com/posts/$id');
    final request = await client
        .getUrl(uri)
        .timeout(const Duration(seconds: 5));
    final response = await request.close().timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      print('Server error: ${response.statusCode}');
      return null;
    }
    final body = await response.transform(utf8.decoder).join();
    return jsonDecode(body) as Map<String, dynamic>;
  } on TimeoutException {
    print('Request timed out');
  } on SocketException {
    print('No internet connection');
  } catch (e) {
    print('Unexpected error: $e');
  } finally {
    client.close();
  }
  return null;
}

Future<void> main() async {
  final products = [
    const Product(id: 1, name: 'Phone', price: 500),
    const Product(id: 2, name: 'Laptop', price: 1200),
    const Product(id: 3, name: 'Gift card'), // بدون سعر
  ];
  print('Most expensive: ${mostExpensive(products)}');
  print('Empty list: ${mostExpensive([])}');
  print('Null list: ${mostExpensive(null)}');

  const jsonString = '{"id": 7, "name": "Mouse", "price": 25.5}';
  final product = Product.fromJson(jsonDecode(jsonString));
  print('From JSON: $product');
  print('To JSON: ${jsonEncode(product.toJson())}');

  final post = await fetchPost(1);
  print('Post title: ${post?['title']}');
}
