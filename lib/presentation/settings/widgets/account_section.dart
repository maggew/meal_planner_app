import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/presentation/common/loading_overlay.dart';
import 'package:meal_planner/presentation/profile/widgets/profile_name_widget.dart';
import 'package:meal_planner/presentation/profile/widgets/profile_picture.dart';
import 'package:meal_planner/services/providers/groups/group_members_provider.dart';
import 'package:meal_planner/services/providers/image_manager_provider.dart';
import 'package:meal_planner/services/providers/network/connectivity_provider.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';
import 'package:meal_planner/services/providers/user/user_profile_provider.dart';

class AccountSection extends ConsumerStatefulWidget {
  final void Function(bool)? onEditingChanged;

  const AccountSection({super.key, this.onEditingChanged});

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
    widget.onEditingChanged?.call(true);
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
        final groupId = ref.read(sessionProvider).groupId;
        if (groupId != null) ref.invalidate(groupMembersProvider(groupId));
        await ref.read(userProfileProvider.future);
      }
      setState(() {
        _isEditing = false;
        _pickedImage = null;
      });
      widget.onEditingChanged?.call(false);
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
    widget.onEditingChanged?.call(false);
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final repo = ref.read(deleteAccountRepositoryProvider);
    final isGoogleUser = !repo.requiresPasswordReauth;

    final passwordController = TextEditingController();
    bool confirmed = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, 16 + MediaQuery.viewInsetsOf(ctx).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Account löschen',
                style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(
              'Dein Account wird dauerhaft gelöscht. '
              'Rezepte in geteilten Gruppen bleiben erhalten, '
              'aber werden nicht mehr dir zugeordnet.',
              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                  ),
            ),
            if (!isGoogleUser) ...[
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Passwort zur Bestätigung',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Abbrechen'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      confirmed = true;
                      Navigator.of(ctx).pop();
                    },
                    style: FilledButton.styleFrom(
                        backgroundColor: Colors.red),
                    child: const Text('Löschen'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (!confirmed || !mounted) return;

    setState(() => _isLoading = true);
    try {
      await repo.deleteAccount(
        password: isGoogleUser ? null : passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.code == 'wrong-password'
            ? 'Falsches Passwort'
            : 'Fehler: ${e.message}'),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account konnte nicht gelöscht werden')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
    Future.delayed(const Duration(milliseconds: 500), passwordController.dispose);
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
    final isOnline = ref.watch(isOnlineProvider);

    return userAsync.when(
      data: (userProfile) {
        if (userProfile == null) return const SizedBox.shrink();

        return LoadingOverlay(
          isLoading: _isLoading,
          child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 12,
            children: [
              Text(
                'Account',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              ProfilePicture(
                imageUrl: userProfile.imageUrl,
                isEditing: _isEditing && isOnline,
                pickedImage: _pickedImage,
                onPickFromCamera: () => _pickImage(pickFromCamera: true),
                onPickFromGallery: () => _pickImage(pickFromCamera: false),
              ),
              ProfileNameWidget(
                nameController: _nameController,
                isEditing: _isEditing && isOnline,
                userProfile: userProfile,
              ),
              Text(userProfile.email),
              if (!_isEditing || !isOnline) ...[
                OutlinedButton.icon(
                  onPressed: isOnline ? _startEditing : null,
                  icon: Icon(isOnline ? Icons.edit : Icons.cloud_off_outlined,
                      size: 16),
                  label: const Text('Bearbeiten'),
                ),
                if (!isOnline)
                  Text(
                    'Nur online bearbeitbar',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.4),
                        ),
                  ),
                TextButton.icon(
                  onPressed: isOnline ? () => _showDeleteAccountDialog(context) : null,
                  icon: const Icon(Icons.delete_forever_outlined, size: 16),
                  label: const Text('Account löschen'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ] else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 12,
                  children: [
                    OutlinedButton(
                      onPressed: _endEditing,
                      child: const Text('Abbrechen'),
                    ),
                    FilledButton(
                      onPressed: _isLoading ? null : _saveChanges,
                      child: const Text('Speichern'),
                    ),
                  ],
                ),
            ],
          ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Fehler: $e'),
    );
  }
}
