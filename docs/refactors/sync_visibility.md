# Refactor: Sync Visibility & Offline-Aware Failure Handling

**Status:** planned
**Depends on:** [`sync_engine.md`](sync_engine.md) (must be complete — it is, as of commit `827d1cd`)
**Touches:** `lib/data/sync/`, `lib/services/providers/sync/`, `lib/presentation/common/` (AppBar indicator), possibly `lib/main.dart`

## Why

The unified `SyncEngine` refactor (`sync_engine.md`) replaced the old `debugPrint`-and-swallow loops with a structured `SyncResult` (per-item errors, fatal pull error, retry counts) and a `SyncEvent` stream. The mechanism is in place — but **nobody consumes it**:

- `SyncCoordinator.enableShoppingListPolling` does `unawaited(syncShoppingList())` — result discarded.
- `SyncCoordinator.syncAll` explicitly does `.catchError((_) => _emptyResult())` — failures swallowed.
- No page subscribes to `engine.events`. No logging, no UI surface, no telemetry.

A row that repeatedly fails to sync today bumps `retryCount` and stays as `failed`, but the user has no way to know, and the dev gets no signal during testing. Goal of this refactor: make sync failures **observable** without becoming **noisy**, and lay the groundwork for a smarter retry strategy that doesn't punish offline users.

## Locked-in design decisions

1. **Connectivity-gating goes first.** The coordinator must not even attempt a sync trigger while `isOnline == false`. Polling timers keep ticking (so the timer never gets out of sync with page lifetime), but each tick early-returns when offline. The existing connectivity-restore branch is what brings sync back when the network returns.
2. **Use the existing `isOnlineProvider`** from `lib/services/providers/network/connectivity_provider.dart` rather than the coordinator's own `Connectivity().onConnectivityChanged` subscription. The coordinator currently owns its own stream — it should keep doing that for the *event-driven restore trigger*, but for the *gating check* on each tick it should read the provider so the rest of the app and the coordinator can never disagree on "are we online right now".
   - Caveat: `isOnlineProvider` derives from a `StreamProvider` and returns `false` while in the `loading` state (cold start, before the first event arrives). The coordinator must treat `false` as "skip this tick", which is the safe default — worst case is one missed tick at app startup, which the connectivity-restore trigger compensates for as soon as the first real event lands.
3. **Engine classifies errors** as either "transient/offline" or "real". Transient errors (`SocketException`, `TimeoutException`, `ClientException` from supabase, plus a runtime check of `isOnline` at catch time) leave the row as `pending`, do **not** bump `retryCount`, do **not** mark `failed`. Real errors (anything else, e.g. 4xx/5xx from PostgREST) follow today's path: mark `failed`, bump `retryCount`. This is what makes step 5 (backoff) safe.
4. **One `SyncStatusProvider`** owns the user-facing state. It listens to `engine.events` and exposes a small immutable record: `({SyncHealth health, int failedItemCount, DateTime? lastSuccessAt, Object? lastFatalError})`. `SyncHealth` is `idle | syncing | ok | degraded | failing`. This is the single source of truth for the AppBar indicator.
5. **AppBar indicator is the only user-visible surface.** No snackbars, no dialogs. A small icon in `CommonAppbar` (cloud / cloud-with-slash / cloud-with-exclamation), tappable to open a tiny details sheet listing the most recent failures. Tap-to-retry triggers `coordinator.syncAll(currentMonth)` manually.
6. **Logging via `debugPrint` with a tag, not Crashlytics (yet).** Strict scope: dev-only signal during testing. Crashlytics non-fatals are a separate decision and not in this refactor — they need consent gating and we don't yet know what error volumes look like.
7. **`syncAll` stops swallowing.** Today: `.catchError((_) => _emptyResult())`. After: it logs the error via the same logging path and lets the `SyncStatusProvider` see it through `engine.events`. No more silent `_emptyResult()` for callers.
8. **Backoff is the *last* step**, not woven into earlier steps. Until we have step 1-4 deployed and have actually seen what failure patterns look like in practice, picking `N` and a pause duration is guesswork. The plan defers this on purpose.

## Implementation order

Each step is its own commit. Run `flutter analyze` and `flutter test test/data/sync/` after each.

### Step 1 — Connectivity gating in the coordinator

**Goal:** while `isOnline == false`, no sync trigger reaches the engine.

- Add `Ref` (or a `bool Function() isOnline` callback for test injection) to `SyncCoordinator` constructor.
- In every trigger path (`syncMealPlan`, `syncShoppingList`, the polling tick callbacks, `didChangeAppLifecycleState`, the connectivity-restore branch *after* the wasOffline transition), early-return if `!isOnline`. The connectivity-restore branch is special: by definition it fires *because* we just came online, so the gate should let it through — read the new state, not the cached `_wasOffline` flag.
- `syncCoordinatorProvider` in `lib/services/providers/sync/sync_providers.dart` passes `() => ref.read(isOnlineProvider)`.
- Tests in `sync_coordinator_test.dart`:
  - new `_CountingAdapter` runs are gated: with `isOnline=false`, polling ticks for 30s should produce zero engine calls.
  - flipping `isOnline` to `true` does *not* by itself fire a sync (gating is passive); only the existing connectivity-restore trigger does, and only if a feature is enabled.
  - existing tests need their fake `isOnline` set to `true` (default for the test builder).

**Acceptance:** offline editing produces `pending` rows that never transition to `failed`, regardless of how long the user stays offline.

### Step 2 — Error classification in the engine

**Goal:** transient/offline failures don't pollute `retryCount` or `failed`.

- Add `SyncErrorKind` enum: `transient | permanent`. Add `kind` to `SyncError`.
- In `SyncEngine.sync`, the per-item `try/catch` around `pushOne` classifies caught errors:
  - `SocketException`, `TimeoutException`, `http.ClientException`, anything matching a small allowlist of supabase network exception types → `transient`. Engine does **not** call `markFailed`, does **not** bump retry count, leaves the row as-is. Logs at `debug` level.
  - Anything else → `permanent`. Today's path: `markFailed`, bumps retry count, contributes to `SyncResult.failed`.
- `pullSince` errors get the same classification → `transient` pull errors set a softer flag than `fatalError` (e.g. `SyncResult.transientPullError`), so the status provider doesn't flip to "failing" just because we lost reception mid-pull.
- Tests in `sync_engine_test.dart`:
  - throwing `SocketException` from `pushOne` → row stays `pending`, `markedFailed` is empty, `SyncResult.failed == 0`, but `SyncResult.errors` contains the entry with `kind == transient`.
  - throwing `StateError` (stand-in for permanent) → today's behaviour, `kind == permanent`.

**Acceptance:** with step 1 in place, even if a sync slips past the gate (e.g. connectivity drops mid-request), the engine recognizes it and protects the row.

### Step 3 — `SyncStatusProvider` + structured logging

**Goal:** one observable place for "how is sync doing right now", and one place for dev logs.

- New file `lib/services/providers/sync/sync_status_provider.dart`. A `Notifier<SyncStatus>` (Riverpod codegen) that subscribes to `syncEngineProvider.events` in its `build`.
- `SyncStatus` is an immutable record: `health`, `failedItemCount`, `lastSuccessAt`, `lastFatalError`, `lastEventAt`.
- Health derivation:
  - any phase `started` not yet matched by `finished` → `syncing`
  - last phase `finished` with `failed == 0` and no `fatalError` → `ok`
  - last phase `finished` with `failed > 0` (permanent only) or transient pull error on the most recent run → `degraded`
  - **3 consecutive runs ending in `failed > 0` or `fatalError`** for the same feature → `failing`
- Logging: `_log(SyncEvent e)` private function, `debugPrint('[sync:${e.featureKey}/${e.scope.key}] ${e.phase} ...')` with details on errors. Centralized so we can later swap to a real logger.
- `syncAll` in coordinator: drop the `.catchError((_) => _emptyResult())`. Let exceptions propagate to the engine's event stream; the status provider picks them up. The `Future.wait` keeps `eagerError: false` so one feature failing doesn't cancel the other.
- Tests:
  - `sync_status_provider_test.dart`: feed synthetic `SyncEvent`s through a fake engine, assert health transitions.
  - `sync_coordinator_test.dart` gets one new test: `syncAll` no longer swallows; with one adapter throwing on pull and the other succeeding, the engine event stream sees a `failed` event and a `finished` event (in some order), and the failing adapter's call still completed.

**Acceptance:** `flutter run` against a broken backend shows tagged `[sync:...]` logs in the console; in widget tests we can read `SyncStatus` from a `ProviderContainer` and watch it move through `syncing → ok → degraded` etc.

### Step 4 — AppBar indicator

**Goal:** user sees something is wrong without being yelled at.

- New widget `lib/presentation/common/sync_status_indicator.dart`. A small `IconButton`, sized to fit in `CommonAppbar`'s right slot.
- States:
  - `idle` / `ok` → no icon at all (don't add visual noise when everything's fine).
  - `syncing` → faint cloud-up icon, no animation (avoid attention-stealing spinners).
  - `degraded` → cloud-with-clock, in `colorScheme.tertiary` (warning, not error).
  - `failing` → cloud-with-slash, in `colorScheme.error`.
- Tap → `showModalBottomSheet` with a `SyncStatusSheet`: lists `failedItemCount`, `lastSuccessAt`, `lastFatalError?.toString()`, and a "Jetzt erneut versuchen" button that calls `coordinator.syncAll(DateTime.now())`.
- Wire into `CommonAppbar` as an optional trailing widget — opt-in per page (only the meal-plan and shopping pages should show it; settings/cookbook don't sync, no need to confuse users there). Or: always show it but only when state != `idle/ok`, which is effectively the same. Pick the second — simpler.
- Widget tests: pump `CommonAppbar` with various overridden `SyncStatus` values, assert which icon (or none) appears, assert tap opens the sheet.

**Acceptance:** during a deliberate offline session followed by a server-rejecting payload (e.g. RLS denial in a manual test), the AppBar icon transitions visibly through the states.

### Step 5 — Backoff for permanent failures *(deferred — separate refactor when needed)*

**Trigger to start this step:** field reports or test logs from steps 1-4 show the same `permanent` error retried on every poll for the same item, creating noise. Until then, don't.

When that day comes:
- Add `pausedUntil DateTime?` to the local row schema (or a side table to avoid touching every feature's schema).
- Engine consults `pausedUntil` in `readPending` filter (skip if `now < pausedUntil`).
- After Nth permanent failure (`N=3`?), set `pausedUntil = now + min(retryCount * 30s, 5min)` or similar — pick from real data.
- Manual "Jetzt erneut versuchen" from the AppBar sheet clears `pausedUntil` for all rows (already implemented in step 4 as a coordinator call — extend it to also reset paused state).

## Out of scope

- Crashlytics non-fatals — needs consent gating, separate decision.
- Per-feature health (vs. global). The `SyncStatusProvider` could split per `featureKey`, but the AppBar icon doesn't need that granularity. If the bottom sheet grows a "which feature" breakdown, we add it then.
- Optimistic UI rollback when a sync permanently fails (e.g. show the user "this entry couldn't be saved, restore?"). Interesting but a much bigger UX call — not now.
- Backoff (see step 5).

## Open questions to resolve before starting step 1

- **Test injection shape for `isOnline` in `SyncCoordinator`:** prefer `bool Function() isOnline` in the constructor (default `() => true` for non-Riverpod tests, real provider read in `sync_providers.dart`) over passing `Ref`. Keeps the coordinator Riverpod-free, matches how `connectivityStream` is already injected. → confirm before coding.
- **Where does the AppBar indicator live in the existing `CommonAppbar`?** Need to read `lib/presentation/common/common_appbar.dart` to see if there's already a trailing-widget slot or if we need to add one. → check on resume.
