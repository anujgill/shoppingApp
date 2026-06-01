# Shopping App

A Flutter take-home assignment using [Fake Store API](https://fakestoreapi.com/products).

## Running the app

```bash
flutter pub get
flutter run
```

Tested on Android and iOS. Requires Flutter 3.x+.

## Features

- Browse all products with image, title, price, and rating
- Search by title, filter by category, sort by price or rating
- Pull-to-refresh the product list
- View full product details
- Add/remove favorites — persisted across app restarts

## Assumptions & trade-offs

- **State management:** Provider (chosen per requirement).
- **Navigation:** Bottom nav bar for Products/Favorites tabs; not specified in the brief so chose the simplest option.
- **Favorites storage:** Stores product IDs in `shared_preferences`. Product data is pulled from the in-memory list (no separate favorites cache).
- **Detail fetch:** Calls `GET /products/{id}` independently so the detail screen works even if the list hasn't loaded yet.
- **Search:** Client-side — the API has no search endpoint.
- **No routing library:** `Navigator.push` is sufficient for two screens deep.
