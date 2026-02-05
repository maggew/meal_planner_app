import 'package:auto_route/auto_route.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:meal_planner/core/constants/local_storage_service.dart';
import 'package:meal_planner/presentation/login/widgets/login_register_widget.dart';
import 'package:meal_planner/presentation/login/widgets/login_reset_password_widget.dart';
import 'package:meal_planner/presentation/login/widgets/login_textformfield.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/services/providers/auth_providers.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';

class LoginBody extends ConsumerStatefulWidget {
  const LoginBody({super.key});

  @override
  ConsumerState<LoginBody> createState() => _LoginBodyState();
}

class _LoginBodyState extends ConsumerState<LoginBody> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final FocusNode emailFocusNode;
  late final FocusNode passwordFocusNode;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() != true) return;

    final authController = ref.read(authControllerProvider.notifier);

    await authController.login(
      emailController.text.trim(),
      passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    ref.listen<AsyncValue<void>>(authControllerProvider, (prev, next) {
      next.whenOrNull(
        data: (_) async {
          final session = ref.read(sessionProvider);
          if (session.groupId != null && session.groupId!.isNotEmpty) {
            context.router.replace(const CookbookRoute());
          } else {
            final groups = await ref
                .read(groupRepositoryProvider)
                .getUserGroups(session.userId!);
            if (groups.isNotEmpty) {
              context.router.replace(GroupsRoute());
            } else {
              context.router.replace(GroupOnboardingRoute());
            }
          }
        },
        error: (e, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_mapAuthError(e))),
          );
        },
      );
    });

    return Center(
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Login",
                style: Theme.of(context).textTheme.displayLarge,
              ),
              SizedBox(
                height: 35,
              ),
              LoginTextFormField(
                controller: emailController,
                validator: _validateEmail,
                text: "E-mail",
                textInputType: TextInputType.emailAddress,
                textObscured: false,
                focusNode: emailFocusNode,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: () => passwordFocusNode.requestFocus(),
              ),
              Gap(15),
              LoginTextFormField(
                controller: passwordController,
                validator: _validatePassword,
                text: "Passwort",
                textInputType: TextInputType.visiblePassword,
                textObscured: _obscurePassword,
                focusNode: passwordFocusNode,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: () => _submitForm(),
                suffixIcon: IconButton(
                  onPressed: () => setState(() {
                    _obscurePassword = !_obscurePassword;
                  }),
                  icon: Icon(_obscurePassword
                      ? Icons.visibility
                      : Icons.visibility_off),
                ),
              ),
              Gap(15),
              ElevatedButton(
                onPressed: isLoading ? null : _submitForm,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Login'),
              ),
              SizedBox(
                height: 60,
              ),
              LoginRegisterWidget(),
              Gap(15),
              ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text('Mit Google anmelden'),
                onPressed: authState.isLoading
                    ? null
                    : () {
                        ref
                            .read(authControllerProvider.notifier)
                            .loginWithGoogle();
                      },
              ),
              LoginResetPasswordWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

String? _validateEmail(String? email) {
  if (email == null || email.isEmpty) {
    return "Bitte E-Mail Adresse eingeben.";
  } else if (!EmailValidator.validate(email)) {
    return "Ungültige E-Mail-Adressee";
  }

  return null;
}

String? _validatePassword(String? password) {
  if (password == null || password.isEmpty) {
    return "Bitte Passwort eingeben.";
  }
  return null;
}

String _mapAuthError(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'user-not-found':
      case 'wrong-password':
        return 'E-Mail oder Passwort ist falsch.';
      case 'invalid-email':
        return 'Die E-Mail-Adresse ist ungültig.';
      case 'network-request-failed':
        return 'Keine Internetverbindung.';
      case 'too-many-requests':
        return 'Zu viele Versuche. Bitte später erneut versuchen.';
      default:
        return error.message ?? 'Ein unbekannter Fehler ist aufgetreten.';
    }
  }

  return 'Ein unbekannter Fehler ist aufgetreten.';
}
