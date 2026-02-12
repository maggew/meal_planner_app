import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/common/app_background.dart';
import 'package:meal_planner/presentation/common/common_appbar.dart';
import 'package:meal_planner/presentation/common/loading_overlay.dart';
import 'package:meal_planner/presentation/profile/widgets/profile_body.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/services/providers/image_manager_provider.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';
import 'package:meal_planner/services/providers/user/user_profile_provider.dart';

@RoutePage()
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late TextEditingController _nameController;
  bool _isEditing = false;
  bool _isLoading = false;
  File? _pickedImage;

  void _startEditing() {
    final userProfile = ref.read(userProfileProvider).value;
    if (userProfile != null) {
      _nameController.text = userProfile.name;
    }
    setState(() => _isEditing = true);
  }

  void _saveChanges() async {
    setState(() {
      _isLoading = true;
    });
    final userProfile = ref.read(userProfileProvider).value;
    // only update if changes are made
    if (_nameController.text != userProfile!.name || _pickedImage != null) {
      final session = ref.read(sessionProvider);
      final userRepo = ref.read(userRepositoryProvider);
      await userRepo.updateUserProfile(
        userId: session.userId!,
        image: _pickedImage,
        name: _nameController.text,
      );
      ref.invalidate(userProfileProvider);
      await ref.read(userProfileProvider.future);
    }

    setState(() {
      _isEditing = false;
      _pickedImage = null;
      _isLoading = false;
    });
  }

  void _endEditing() {
    final userProfile = ref.read(userProfileProvider).value;
    if (userProfile != null) {
      _nameController.text = userProfile.name;
    }
    setState(() => _isEditing = false);
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      scaffoldAppBar:
          CommonAppbar(title: "Profil", actionsButtons: _actionButtons),
      scaffoldBody: LoadingOverlay(
        isLoading: _isLoading,
        child: ProfileBody(
          isEditing: _isEditing,
          nameController: _nameController,
          pickedImage: _pickedImage,
          onEditImage: () async {
            final imageManagerNotifier =
                ref.read(imageManagerProvider.notifier);
            await imageManagerNotifier.pickImageFromCamera(
                imageType: AnalysisImageType.photo);

            final imageManager = ref.read(imageManagerProvider);
            setState(() {
              _pickedImage = imageManager.photo;
            });
            imageManagerNotifier.clearPhoto();
          },
        ),
      ),
    );
  }

  List<Widget> get _actionButtons {
    if (_isEditing) {
      return [
        IconButton(
          key: ValueKey("close"),
          onPressed: _endEditing,
          icon: Icon(Icons.close),
        ),
        IconButton(
          key: ValueKey("save"),
          onPressed: _saveChanges,
          icon: Icon(Icons.check),
        ),
      ];
    }
    return [
      IconButton(
        key: ValueKey("settings"),
        onPressed: () {
          context.router.push(const SettingsRoute());
        },
        icon: Icon(Icons.settings),
      ),
      IconButton(
        key: ValueKey("edit"),
        onPressed: _startEditing,
        icon: Icon(Icons.edit),
      ),
    ];
  }
}
