import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/services/providers/sync/sync_providers.dart';
import 'package:meal_planner/services/providers/sync/sync_status_provider.dart';

/// Single icon shown in `CommonAppbar`'s trailing slot. The only user-visible
/// surface for sync health (no snackbars, no dialogs).
///
/// Idle/ok states render nothing — we only draw an icon when there's
/// something to communicate. Tapping any visible state opens a bottom sheet
/// with the details and a "Jetzt erneut versuchen" button.
class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider);
    final visual = _visualFor(status.health, Theme.of(context).colorScheme);
    if (visual == null) return const SizedBox.shrink();

    return IconButton(
      tooltip: visual.tooltip,
      icon: Icon(visual.icon, color: visual.color),
      onPressed: () => _openSheet(context),
    );
  }

  void _openSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => const SyncStatusSheet(),
    );
  }
}

class _Visual {
  const _Visual({required this.icon, required this.color, required this.tooltip});
  final IconData icon;
  final Color color;
  final String tooltip;
}

_Visual? _visualFor(SyncHealth health, ColorScheme cs) {
  switch (health) {
    case SyncHealth.idle:
    case SyncHealth.ok:
    case SyncHealth.syncing:
      return null;
    case SyncHealth.degraded:
      return _Visual(
        icon: Icons.cloud_queue,
        color: cs.tertiary,
        tooltip: 'Synchronisation verzögert',
      );
    case SyncHealth.failing:
      return _Visual(
        icon: Icons.cloud_off,
        color: cs.error,
        tooltip: 'Synchronisation fehlgeschlagen',
      );
  }
}

/// Details sheet shown on tap. Lists raw status fields and offers a manual
/// retry that re-runs both features for the current month.
class SyncStatusSheet extends ConsumerWidget {
  const SyncStatusSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider);
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Synchronisation', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            _row('Status', status.health.name),
            _row('Fehlgeschlagene Einträge', '${status.failedItemCount}'),
            _row('Letzter Erfolg', _fmt(status.lastSuccessAt)),
            if (status.lastFatalError != null)
              _row('Letzter Fehler', status.lastFatalError.toString()),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Jetzt erneut versuchen'),
              onPressed: () {
                final coordinator = ref.read(syncCoordinatorProvider);
                coordinator.syncAll(DateTime.now());
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Flexible(
                child: Text(value,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2)),
          ],
        ),
      );

  static String _fmt(DateTime? d) {
    if (d == null) return '—';
    final t =
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} $t';
  }
}
