import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/products_provider.dart';
import '../widgets/product_tile.dart';
import '../widgets/shimmer_loading.dart';
import 'product_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritesNotifier>();
    final productsNotifier = context.watch<ProductsNotifier>();

    if (productsNotifier.status == LoadStatus.loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Favorites')),
        body: const ProductListShimmer(),
      );
    }

    final favorited = productsNotifier.allProducts
        .where((p) => favs.isFavorite(p.id))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favorited.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No favorites yet', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.separated(
              itemCount: favorited.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 16),
              itemBuilder: (context, i) => ProductTile(
                product: favorited[i],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(productId: favorited[i].id),
                  ),
                ),
              ),
            ),
    );
  }
}
