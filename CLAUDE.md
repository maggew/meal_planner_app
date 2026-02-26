# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Code generation (Riverpod, AutoRoute, Drift) — run after changing annotated files
dart run build_runner build --delete-conflicting-outputs

# Watch mode for code generation during development
dart run build_runner watch --delete-conflicting-outputs

# Run the app
flutter run

# Run all tests
flutter test

# Run a single test file
flutter test test/repositories/supabase_recipe_repository_test.dart
```

The app requires a `.env` file at the project root with `SUPABASE_URL` and `SUPABASE_ANON_KEY`.

## Architecture

Clean Architecture with three distinct layers:

- **`lib/domain/`** — entities, repository interfaces, enums, exceptions, use cases. No Flutter dependencies.
- **`lib/data/`** — repository implementations, DTOs (`model/`), Supabase data sources. DTOs map to domain entities.
- **`lib/presentation/`** — pages, widgets, router. Pages are annotated with `@RoutePage()` for AutoRoute.
- **`lib/services/providers/`** — Riverpod providers wiring the layers together. `repository_providers.dart` is the central file.
- **`lib/core/`** — shared infrastructure: Drift database (`core/database/`), theme, constants, utils.

Data flow: `UI → Riverpod provider → Repository interface (domain) → Repository impl (data) → Supabase/Drift`

## State Management (Riverpod v3 + code generation)

All providers use `riverpod_annotation`. Run `build_runner` after adding/modifying providers. Key providers:

- `lib/services/providers/repository_providers.dart` — all repository + infrastructure providers
- `lib/services/providers/auth_providers.dart` — auth state (`authStateProvider` streams current user ID)
- `lib/services/providers/session_provider.dart` — current session (userId, groupId, userName)
- Feature-specific providers live alongside their features (e.g., `meal_plan/meal_plan_provider.dart`)

## Routing (AutoRoute v11)

- Config: `lib/presentation/router/router.dart`
- Generated: `lib/presentation/router/router.gr.dart` (do not edit manually)
- Pages are annotated `@RoutePage()` and must be registered in the router config
- `AuthGuard` protects authenticated routes
- Navigation: `context.router.push(SomeRoute())` / `context.router.pop()`

## Database (Drift — offline-first)

- Database definition: `lib/core/database/app_database.dart` (schemaVersion: 4)
- Tables: `LocalShoppingItems`, `LocalRecipes`, `LocalMealPlanEntries`
- DAOs in `lib/core/database/daos/` — query logic lives here
- Add migrations when incrementing `schemaVersion`
- Offline-first repositories (`offline_first_*.dart`) sync local Drift DB with Supabase

## UI Conventions

Every page uses this structure:
```dart
@RoutePage()
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBackground(
      scaffoldAppBar: CommonAppbar(title: "Title"),
      scaffoldBody: MyPageBody(),
    );
  }
}
```

- **`AppBackground`** (`lib/presentation/common/app_background.dart`) — mandatory page wrapper (background image, scaffold, burger menu drawer)
- **`CommonAppbar`** (`lib/presentation/common/common_appbar.dart`) — 80px height, centered title, transparent background
- **Colors**: always `Theme.of(context).colorScheme.*`, never hardcoded
- **Dimensions**: `AppDimensions.borderRadius` (12), `AppDimensions.screenMargin` (20), `AppDimensions.animationDuration` (200ms)
- **Glass card**: `ClipRRect` + `BackdropFilter(ImageFilter.blur(…))` + semi-transparent container (requires `import 'dart:ui'`)
- **Solid card**: `surfaceContainer` color background
- **Font**: Google Fonts Quicksand (applied globally via theme — no need to set per widget)

## Supabase / Firebase

- Supabase: primary data store + realtime subscriptions. Table constants in `lib/core/constants/supabase_constants.dart`.
- Firebase: authentication (`firebase_auth_repository.dart`) and file storage (`firebase_storage_repository.dart`).
- Supabase Realtime is used for collaborative features (shopping list, meal plan). Subscribe in `initState`, unsubscribe in `dispose`.

## Code Generation Files

Never edit these manually — they are fully generated:
- `lib/presentation/router/router.gr.dart`
- Any `*.g.dart` files (Riverpod, Drift, JSON serialization)
