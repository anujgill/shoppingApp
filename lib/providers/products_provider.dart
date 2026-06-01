import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/product_api_service.dart';

enum LoadStatus { idle, loading, success, error }

enum SortOption { none, priceLow, priceHigh, ratingHigh, ratingLow }

class ProductsNotifier extends ChangeNotifier {
  final ProductApiService _api;

  ProductsNotifier(this._api);

  List<Product> _all = [];
  LoadStatus _status = LoadStatus.idle;
  String _error = '';
  String _query = '';
  final Set<String> _categories = {};
  SortOption _sort = SortOption.none;

  LoadStatus get status => _status;
  String get error => _error;
  String get query => _query;
  Set<String> get selectedCategories => Set.unmodifiable(_categories);
  SortOption get sortOption => _sort;

  List<String> get categories {
    final cats = _all.map((p) => p.category).toSet().toList();
    cats.sort();
    return cats;
  }

  List<Product> get products {
    var list = _all.where((p) {
      final matchesQuery = _query.isEmpty ||
          p.title.toLowerCase().contains(_query.toLowerCase());
      final matchesCategory =
          _categories.isEmpty || _categories.contains(p.category);
      return matchesQuery && matchesCategory;
    }).toList();

    switch (_sort) {
      case SortOption.priceLow:
        list.sort((a, b) => a.price.compareTo(b.price));
      case SortOption.priceHigh:
        list.sort((a, b) => b.price.compareTo(a.price));
      case SortOption.ratingHigh:
        list.sort((a, b) => b.rating.rate.compareTo(a.rating.rate));
      case SortOption.ratingLow:
        list.sort((a, b) => a.rating.rate.compareTo(b.rating.rate));
      case SortOption.none:
        break;
    }

    return list;
  }

  List<Product> get allProducts => _all;

  Future<void> loadProducts() async {
    _status = LoadStatus.loading;
    _error = '';
    notifyListeners();

    try {
      _all = await _api.getProducts();
      _status = LoadStatus.success;
    } catch (e) {
      _error = 'Something went wrong. Check your connection.';
      _status = LoadStatus.error;
    }

    notifyListeners();
  }

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  void toggleCategory(String cat) {
    if (_categories.contains(cat)) {
      _categories.remove(cat);
    } else {
      _categories.add(cat);
    }
    notifyListeners();
  }

  void clearCategories() {
    _categories.clear();
    notifyListeners();
  }

  void setSort(SortOption opt) {
    _sort = opt;
    notifyListeners();
  }
}
