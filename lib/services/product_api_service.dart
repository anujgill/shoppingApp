import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductApiService {
  static const _base = 'https://fakestoreapi.com';

  Future<List<Product>> getProducts() async {
    final res = await http.get(Uri.parse('$_base/products'));
    if (res.statusCode != 200) throw Exception('Failed to load products');
    final list = jsonDecode(res.body) as List;
    return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Product> getProduct(int id) async {
    final res = await http.get(Uri.parse('$_base/products/$id'));
    if (res.statusCode != 200) throw Exception('Failed to load product');
    return Product.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }
}
