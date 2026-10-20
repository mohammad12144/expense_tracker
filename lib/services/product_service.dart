import 'package:expense_tracker/models/product.dart';
import 'package:expense_tracker/services/api_client.dart';

class ProductService {
  final ApiClient _api;

  ProductService({ApiClient? api}) : _api = api ?? ApiClient();

  Future<List<Product>> fetchProducts({int limit = 20}) async {
    final data = await _api.get('https://dummyjson.com/products?limit=$limit');
    final list = (data as Map<String, dynamic>)['products'] as List<dynamic>;
    return list
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}