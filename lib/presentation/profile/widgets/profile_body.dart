import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/common/native_ad_widget.dart';
import 'package:meal_planner/presentation/profile/widgets/active_group_card.dart';
import 'package:meal_planner/presentation/profile/widgets/profile_groups_list.dart';
import 'package:meal_planner/presentation/profile/widgets/profile_picture.dart';
import 'package:meal_planner/services/providers/user/user_profile_provider.dart';

class ProfileBody extends ConsumerWidget {
  const ProfileBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);

    return SizedBox(
      width: double.infinity,
      child: userAsync.when(
        data: (userProfile) {
          if (userProfile == null) return const SizedBox.shrink();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 15,
              children: [
                ProfilePicture(imageUrl: userProfile.imageUrl),
                Text(
                  userProfile.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  userProfile.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
                const NativeAdWidget(),
                const ActiveGroupCard(),
                const ProfileGroupsList(),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Fehler: $e')),
      ),
    );
  }
}
