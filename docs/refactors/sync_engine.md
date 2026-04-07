# Refactor: Unified Offline-First SyncEngine

**Status:** planned
**Replaces:** `offline_first_meal_plan_repository.dart`, `offline_first_shopping_list_repository.dart`, `meal_plan_realtime_provider.dart`, `shopping_list_realtime_provider.dart` (and any other realtime providers), the two `*_sync_observer.dart` files, ad-hoc sync triggering in `main.dart` and page `initState`s.

## Why

Both offline-first repos are near copy-paste: own `Timer`, own `_isSyncing` flag, hardcoded intervals, push-pending + pull-since loops, errors silently swallowed. Realtime adds a parallel write path that races with local pending edits. Testing requires standing up the whole repo. We want one engine, one trigger surface, one place to look when sync misbehaves.

## Locked-in design decisions

1. **One engine for both features** (recipes can adopt later).
2. **No realtime.** Removed in this refactor. Polling + lifecycle/connectivity/page-open triggers cover the "feels live" use case.
3. **Per-item status (minimal):** `pending` / `synced` / `failed` / `pendingDelete`, plus `lastError` and `retryCount`. No exponential backoff — every trigger retries `pending` and `failed` together.
4. **Conflict resolution: local-pending-wins.** Pull skips items locally in `pending` or `pendingDelete`. Justified by ~5s sync window — concurrent edits at the same item are vanishingly rare.
5. **Soft delete via `syncStatus = pendingDelete`** (no extra column, no tombstone table). Engine pushes the delete, then hard-deletes locally on success.
6. **Engine is stateless.** A separate `SyncCoordinator` owns timers, lifecycle hooks, connectivity, page-open triggers.
7. **Adapter pattern, no generics.** Engine speaks only its own value types (`PendingChange`, `RemoteRow`). Each feature has a concrete adapter that translates Drift rows ↔ engine types ↔ Supabase DTOs.
8. **Opaque `SyncScope` parameter** for windowed pulls (meal plan = per month, shopping list = full).
9. **`SyncMeta` Drift table** holds `lastPulledAt` per `(featureKey, scopeKey)`. Engine reads/writes via a `SyncMetaDao`. Adapter never sees it.

## Interface shape

```dart
// Engine value types
enum SyncItemStatus { pending, synced, failed, pendingDelete }

class PendingChange {
  final String id;
  final SyncItemStatus status; // pending or pendingDelete
  final int retryCount;
  final Map<String, dynamic> payload; // adapter-encoded
}

class RemoteRow {
  final String id;
  final DateTime updatedAt;
  final bool deleted;
  final Map<String, dynamic> data;
}

abstract class SyncScope {
  String get key; // e.g. "2026-04" or "all"
}
class FullScope implements SyncScope { const FullScope(); String get key => 'all'; }
class MonthScope implements SyncScope { /* year+month → "2026-04" */ }

class SyncError { final String itemId; final Object error; final StackTrace st; }

class SyncResult {
  final int pushed, pulled, failed;
  final List<SyncError> errors;
  final Object? fatalError;
  final DateTime ranAt;
  bool get ok => fatalError == null && failed == 0;
}

enum SyncPhase { started, finished, failed }
class SyncEvent { final String featureKey; final SyncScope scope; final SyncPhase phase; final SyncResult? result; final DateTime at; }

// Engine — one method, plus an optional observation stream
class SyncEngine {
  SyncEngine(this._meta);
  final SyncMetaDao _meta;
  Future<SyncResult> sync(SyncAdapter adapter, SyncScope scope);
  Stream<SyncEvent> get events;
}

// Adapter — narrow, no optional hooks
abstract class SyncAdapter {
  String get featureKey;
  Future<List<PendingChange>> readPending();
  Future<Set<String>> localPendingIds(); // engine uses for local-pending-wins filter
  Future<void> markSynced(String id);
  Future<void> markFailed(String id, Object error);
  Future<void> applyRemote(List<RemoteRow> rows); // dumb upsert; engine pre-filters
  Future<void> pushOne(PendingChange change);     // throws on failure
  Future<List<RemoteRow>> pullSince(DateTime? since, SyncScope scope);
}

// Coordinator — explicit typed methods per feature, no registry, no string keys
class SyncCoordinator {
  SyncCoordinator(this._engine, this._mealPlan, this._shopping);
  Future<SyncResult> syncMealPlan(DateTime month);
  Future<SyncResult> syncShoppingList();
  Future<void> syncAll(DateTime currentMonth);
  void start();  // attaches lifecycle + connectivity + polling
  void stop();
}
```

## What lives where

- Engine: push-then-pull, per-item try/catch, `lastPulledAt` read/write, `localPendingIds` filter on pull, reentrancy dedup per `(featureKey, scopeKey)`, event emission.
- Adapter: Drift queries, Supabase DTO mapping, `pushOne` HTTP call, status transitions on rows.
- Coordinator: timers (5s shopping list when page open, 15-30s meal plan when page open), lifecycle resume, connectivity restore, manual `syncNow` from pages.

## Implementation order

1. `SyncMeta` Drift table + DAO + migration (bump schemaVersion).
2. Add `pendingDelete` to existing `syncStatus` columns (check current usage, no schema change needed if it's already TEXT).
3. Engine value types + `SyncEngine` class + tests with a fake adapter.
4. `MealPlanSyncAdapter` + tests.
5. `ShoppingListSyncAdapter` + tests.
6. `SyncCoordinator` + Riverpod providers.
7. Wire pages to coordinator; remove `*_sync_observer.dart` and ad-hoc triggers.
8. Delete realtime providers and Supabase channel setup. **(no-op — already gone with the observers in step 7)**
9. Strip old `offline_first_*` repositories to write-path only (chose option **(b)** from the original decision note: smaller diff, domain interfaces unchanged). Removed `Timer`/`_isSyncing`/`SupabaseClient`/remote deps and the `startPeriodicSync`/`syncPending`/`pullRemoteForMonth`/`pullRemoteItems`/`sync` methods. Providers (`shoppingListRepositoryProvider`, `mealPlanRepositoryProvider`) now construct the lean repos directly; the intermediate `offlineFirst*Provider` + `*SyncServiceProvider` indirection is gone, and the connectivity-restore listener in `main.dart` no longer pokes the repos (coordinator owns that). **(done up to here)**
10. Delete old realtime tests; add coordinator integration test. *(Old `test/repositories/offline_first_*_repository_test.dart` and `test/services/shopping_list_sync_service_test.dart` deleted with step 9 — they tested the now-removed sync paths. Coverage of the new sync code lives in `test/data/sync/`. A coordinator-level integration test is still TODO.)*

## Out of scope

- Recipes adopting the engine (Cluster #5) — separate refactor.
- Subscription gating (Cluster #6) — unrelated.
- Field-level merge — not needed under local-pending-wins given the 5s sync window.
