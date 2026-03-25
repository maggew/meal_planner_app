import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/constants/app_dimensions.dart';
import 'package:meal_planner/domain/exceptions/group_exceptions.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';

class JoinGroupBody extends ConsumerStatefulWidget {
  final TextEditingController groupIdController;
  const JoinGroupBody({
    super.key,
    required this.groupIdController,
  });

  @override
  ConsumerState<JoinGroupBody> createState() => _JoinGroupBodyState();
}

class _JoinGroupBodyState extends ConsumerState<JoinGroupBody> {
  bool _isLoading = false;

  Future<void> _joinViaCode() async {
    final code = widget.groupIdController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(groupInvitationRepositoryProvider);
      final groupId = await repo.joinViaInviteCode(code);

      // Update session to the joined group
      await ref.read(sessionProvider.notifier).setActiveGroup(groupId);

      if (mounted) {
        context.router.replaceAll([const CookbookRoute()]);
      }
    } on AlreadyGroupMemberException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Du bist bereits Mitglied dieser Gruppe')),
        );
      }
    } on InvitationExpiredException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Einladungscode abgelaufen oder ungültig')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Beitreten: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenMargin),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            spacing: 30,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Einladungscode eingeben:",
                style: textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              TextFormField(
                controller: widget.groupIdController,
                autovalidateMode: AutovalidateMode.disabled,
                textCapitalization: TextCapitalization.characters,
                maxLength: 8,
                decoration: const InputDecoration(
                  hintText: "z.B. A3K7MXPQ",
                  labelText: "Einladungscode",
                  counterText: '',
                ),
              ),
              ElevatedButton(
                onPressed: _isLoading ? null : _joinViaCode,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Beitreten"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
