import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/products_provider.dart';
import 'providers/favorites_provider.dart';
import 'services/product_api_service.dart';
import 'services/favorites_storage.dart';

void main() {
  final api = ProductApiService();
  final storage = FavoritesStorage();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: api),
        ChangeNotifierProvider(create: (_) => ProductsNotifier(api)..loadProducts()),
        ChangeNotifierProvider(create: (_) => FavoritesNotifier(storage)..init()),
      ],
      child: const AppRoot(),
    ),
  );
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5B67CA)),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      ),
      home: const ShoppingApp(),
    );
  }
}
