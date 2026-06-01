import 'package:flutter/foundation.dart';
import '../services/favorites_storage.dart';

class FavoritesNotifier extends ChangeNotifier {
  final FavoritesStorage _storage;

  FavoritesNotifier(this._storage);

  Set<int> _ids = {};

  Set<int> get ids => _ids;

  bool isFavorite(int id) => _ids.contains(id);

  Future<void> init() async {
    _ids = await _storage.load();
    notifyListeners();
  }

  Future<void> toggle(int id) async {
    if (_ids.contains(id)) {
      _ids.remove(id);
    } else {
      _ids.add(id);
    }
    notifyListeners();
    await _storage.save(_ids);
  }

  Future<void> remove(int id) async {
    _ids.remove(id);
    notifyListeners();
    await _storage.save(_ids);
  }
}
