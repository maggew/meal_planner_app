import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/common/common_appbar.dart';
import 'package:meal_planner/presentation/common/loading_overlay.dart';
import 'package:meal_planner/presentation/create_group/widgets/create_group_body.dart';
import 'package:meal_planner/services/providers/image_manager_provider.dart';

@RoutePage()
class CreateGroupPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends ConsumerState<CreateGroupPage> {
  late TextEditingController groupNameController;
  late TextEditingController imagePathController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    groupNameController = TextEditingController();
    imagePathController = TextEditingController();
  }

  @override
  void dispose() {
    groupNameController.dispose();
    imagePathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(imageManagerProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
        ref.read(imageManagerProvider.notifier).clearError();
      }
    });

    return LoadingOverlay(
      isLoading: _isLoading,
      child: AppBackground(
        scaffoldAppBar: const CommonAppbar(title: 'Gruppe erstellen'),
        scaffoldBody: CreateGroupBody(
          groupNameController: groupNameController,
          imagePathController: imagePathController,
          onLoadingChanged: (loading) {
            setState(() => _isLoading = loading);
          },
        ),
      ),
    );
  }
}
