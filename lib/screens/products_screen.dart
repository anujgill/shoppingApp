import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/format.dart';
import '../providers/products_provider.dart';
import '../widgets/product_tile.dart';
import '../widgets/shimmer_loading.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ProductsNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: notifier.setQuery,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          notifier.setQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: switch (notifier.status) {
        LoadStatus.loading => const ProductListShimmer(),
        LoadStatus.error => Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(notifier.error, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: notifier.loadProducts,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        _ => _buildList(notifier),
      },
    );
  }

  Widget _buildList(ProductsNotifier notifier) {
    final items = notifier.products;

    return RefreshIndicator(
      onRefresh: notifier.loadProducts,
      child: Column(
        children: [
          if (notifier.status == LoadStatus.success) _FilterSortBar(notifier: notifier),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('No products found'))
                : ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, indent: 16),
                    itemBuilder: (context, i) => ProductTile(
                      product: items[i],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(productId: items[i].id),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterSortBar extends StatelessWidget {
  final ProductsNotifier notifier;

  const _FilterSortBar({required this.notifier});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _CategoryChip(notifier: notifier),
          const SizedBox(width: 8),
          _SortChip(notifier: notifier),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final ProductsNotifier notifier;

  const _CategoryChip({required this.notifier});

  void _openFilter(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return ListenableBuilder(
          listenable: notifier,
          builder: (context, _) {
            final categories = notifier.categories;
            final selected = notifier.selectedCategories;

            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.clear_all),
                    title: const Text('Clear filter'),
                    enabled: selected.isNotEmpty,
                    onTap: selected.isEmpty ? null : notifier.clearCategories,
                  ),
                  const Divider(height: 1),
                  ...categories.map(
                    (c) => CheckboxListTile(
                      value: selected.contains(c),
                      title: Text(capitalizeFirst(c)),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (_) => notifier.toggleCategory(c),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _chipLabel(Set<String> selected) {
    if (selected.isEmpty) return 'Category';
    if (selected.length == 1) return capitalizeFirst(selected.first);
    return 'Category (${selected.length})';
  }

  @override
  Widget build(BuildContext context) {
    final selected = notifier.selectedCategories;

    return ActionChip(
      label: Text(_chipLabel(selected)),
      avatar: const Icon(Icons.filter_list, size: 16),
      backgroundColor: selected.isNotEmpty
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      onPressed: () => _openFilter(context),
    );
  }
}

class _SortChip extends StatelessWidget {
  final ProductsNotifier notifier;

  const _SortChip({required this.notifier});

  String get _label {
    switch (notifier.sortOption) {
      case SortOption.priceLow:
        return 'Price: Low → High';
      case SortOption.priceHigh:
        return 'Price: High → Low';
      case SortOption.ratingHigh:
        return 'Rating: High → Low';
      case SortOption.ratingLow:
        return 'Rating: Low → High';
      case SortOption.none:
        return 'Sort';
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = notifier.sortOption != SortOption.none;

    return PopupMenuButton<SortOption>(
      onSelected: notifier.setSort,
      itemBuilder: (_) => const [
        PopupMenuItem(value: SortOption.none, child: Text('Default')),
        PopupMenuItem(value: SortOption.priceLow, child: Text('Price: Low → High')),
        PopupMenuItem(value: SortOption.priceHigh, child: Text('Price: High → Low')),
        PopupMenuItem(value: SortOption.ratingHigh, child: Text('Rating: High → Low')),
        PopupMenuItem(value: SortOption.ratingLow, child: Text('Rating: Low → High')),
      ],
      child: Chip(
        label: Text(_label),
        avatar: const Icon(Icons.sort, size: 16),
        backgroundColor: active
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
      ),
    );
  }
}
