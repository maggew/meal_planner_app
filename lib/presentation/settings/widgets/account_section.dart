import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/common/loading_overlay.dart';
import 'package:meal_planner/presentation/profile/widgets/profile_name_widget.dart';
import 'package:meal_planner/presentation/profile/widgets/profile_picture.dart';
import 'package:meal_planner/services/providers/image_manager_provider.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';
import 'package:meal_planner/services/providers/user/user_profile_provider.dart';

class AccountSection extends ConsumerStatefulWidget {
  const AccountSection({super.key});

  @override
  ConsumerState<AccountSection> createState() => _AccountSectionState();
}

class _AccountSectionState extends ConsumerState<AccountSection> {
  late TextEditingController _nameController;
  bool _isEditing = false;
  bool _isLoading = false;
  File? _pickedImage;

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

  void _startEditing() {
    final userProfile = ref.read(userProfileProvider).value;
    if (userProfile != null) {
      _nameController.text = userProfile.name;
    }
    setState(() => _isEditing = true);
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      final userProfile = ref.read(userProfileProvider).value;
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
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil konnte nicht gespeichert werden')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _endEditing() {
    final userProfile = ref.read(userProfileProvider).value;
    if (userProfile != null) {
      _nameController.text = userProfile.name;
    }
    setState(() {
      _isEditing = false;
      _pickedImage = null;
    });
  }

  Future<void> _pickImage({required bool pickFromCamera}) async {
    final imageManagerNotifier = ref.read(imageManagerProvider.notifier);
    if (pickFromCamera) {
      await imageManagerNotifier.pickImageFromCamera(imageType: AnalysisImageType.photo);
    } else {
      await imageManagerNotifier.pickImageFromGallery(imageType: AnalysisImageType.photo);
    }
    final imageManager = ref.read(imageManagerProvider);
    if (mounted) {
      setState(() => _pickedImage = imageManager.photo);
    }
    imageManagerNotifier.clearPhoto();
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

    final userAsync = ref.watch(userProfileProvider);

    return userAsync.when(
      data: (userProfile) {
        if (userProfile == null) return const SizedBox.shrink();

        return LoadingOverlay(
          isLoading: _isLoading,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 12,
            children: [
              Text(
                'Account',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ProfilePicture(
                imageUrl: userProfile.imageUrl,
                isEditing: _isEditing,
                pickedImage: _pickedImage,
                onPickFromCamera: () => _pickImage(pickFromCamera: true),
                onPickFromGallery: () => _pickImage(pickFromCamera: false),
              ),
              ProfileNameWidget(
                nameController: _nameController,
                isEditing: _isEditing,
                userProfile: userProfile,
              ),
              Text(userProfile.email),
              if (!_isEditing)
                OutlinedButton.icon(
                  onPressed: _startEditing,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Bearbeiten'),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 12,
                  children: [
                    OutlinedButton(
                      onPressed: _endEditing,
                      child: const Text('Abbrechen'),
                    ),
                    FilledButton(
                      onPressed: _saveChanges,
                      child: const Text('Speichern'),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Fehler: $e'),
    );
  }
}
