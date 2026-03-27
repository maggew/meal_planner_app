import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/presentation/common/glass_card.dart';

class LicensesBody extends StatefulWidget {
  const LicensesBody({super.key});

  @override
  State<LicensesBody> createState() => _LicensesBodyState();
}

class _LicensesBodyState extends State<LicensesBody> {
  late final Future<Map<String, List<String>>> _licensesFuture;

  @override
  void initState() {
    super.initState();
    _licensesFuture = _loadLicenses();
  }

  Future<Map<String, List<String>>> _loadLicenses() async {
    final result = <String, List<String>>{};
    await for (final entry in LicenseRegistry.licenses) {
      final text = entry.paragraphs.map((p) => p.text).join('\n\n');
      for (final package in entry.packages) {
        result.putIfAbsent(package, () => []).add(text);
      }
    }
    return Map.fromEntries(
      result.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, List<String>>>(
      future: _licensesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final licenses = snapshot.data ?? {};
        final packages = licenses.keys.toList();
        final colorScheme = Theme.of(context).colorScheme;

        return ListView.separated(
          padding: const EdgeInsets.all(AppDimensions.screenMargin),
          itemCount: packages.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final package = packages[index];
            final texts = licenses[package]!;

            return GlassCard(
              padding: EdgeInsets.zero,
              child: Material(
                color: Colors.transparent,
                child: ExpansionTile(
                backgroundColor: Colors.transparent,
                collapsedBackgroundColor: Colors.transparent,
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.screenMargin,
                  vertical: 4,
                ),
                title: Text(
                  package,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                subtitle: Text(
                  '${texts.length} Lizenz${texts.length == 1 ? '' : 'en'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                children: [
                  for (final text in texts)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: Text(
                        text,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                      ),
                    ),
                ],
              ),
              ),
            );
          },
        );
      },
    );
  }
}
