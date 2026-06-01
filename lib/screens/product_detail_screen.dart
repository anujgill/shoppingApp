import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/product_image.dart';
import '../widgets/shimmer_loading.dart';
import '../common/format.dart';
import '../models/product.dart';
import '../providers/favorites_provider.dart';
import '../services/product_api_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final product = await context.read<ProductApiService>().getProduct(widget.productId);
      if (mounted) setState(() { _product = product; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = 'Failed to load product.'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritesNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        actions: [
          if (_product != null)
            IconButton(
              icon: Icon(
                favs.isFavorite(_product!.id) ? Icons.favorite : Icons.favorite_border,
                color: favs.isFavorite(_product!.id) ? Colors.red : null,
              ),
              onPressed: () => favs.toggle(_product!.id),
            ),
        ],
      ),
      body: _loading
          ? const ProductDetailShimmer()
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(onPressed: _load, child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              : _ProductBody(product: _product!),
    );
  }
}

class _ProductBody extends StatelessWidget {
  final Product product;

  const _ProductBody({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ProductImage(
              url: product.image,
              height: 240,
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 20),
          Chip(
            label: Text(capitalizeFirst(product.category)),
            backgroundColor: theme.colorScheme.secondaryContainer,
            labelStyle: TextStyle(color: theme.colorScheme.onSecondaryContainer, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(product.title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              Text(
                '${product.rating.rate} (${product.rating.count})',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          Text(product.description, style: theme.textTheme.bodyMedium?.copyWith(height: 1.6)),
        ],
      ),
    );
  }
}
