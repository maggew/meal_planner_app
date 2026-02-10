import 'package:auto_route/auto_route.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/exceptions/auth_exceptions.dart';
import 'package:meal_planner/presentation/registration/widgets/registration_image_input.dart';
import 'package:meal_planner/presentation/registration/widgets/registration_image_preview.dart';
import 'package:meal_planner/presentation/registration/widgets/registration_textformfield.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/services/providers/image_manager_provider.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';

class RegistrationBody extends ConsumerStatefulWidget {
  const RegistrationBody({super.key});

  @override
  ConsumerState<RegistrationBody> createState() => _RegistrationBodyState();
}

class _RegistrationBodyState extends ConsumerState<RegistrationBody> {
  late TextEditingController nameController;
  late FocusNode nameFocusNode;
  late TextEditingController emailController;
  late FocusNode emailFocusNode;
  late TextEditingController passwordController;
  late FocusNode passwordFocusNode;
  late TextEditingController passwordCheckController;
  late FocusNode passwordCheckFocusNode;
  bool _obscurePassword = true;
  bool _obscurePasswordCheck = true;
  bool _isLoading = false;

  late TextEditingController pictureNameController;

  GlobalKey<FormState> _formCheck = new GlobalKey();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    passwordCheckController = TextEditingController();
    nameFocusNode = FocusNode();
    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    passwordCheckFocusNode = FocusNode();

    pictureNameController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordCheckController.dispose();
    nameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    passwordCheckFocusNode.dispose();

    pictureNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Form(
          key: _formCheck,
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(
            spacing: 15,
            children: [
              RegistrationTextformfield(
                controller: nameController,
                text: "Name",
                validator: _validateName,
                focusNode: nameFocusNode,
                textObscured: false,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                onFieldSubmitted: () => emailFocusNode.requestFocus(),
              ),
              RegistrationTextformfield(
                controller: emailController,
                text: "E-Mail",
                validator: _validateEmail,
                focusNode: emailFocusNode,
                textObscured: false,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                onFieldSubmitted: () => passwordFocusNode.requestFocus(),
              ),
              RegistrationTextformfield(
                controller: passwordController,
                text: "Passwort",
                validator: _validatePassword,
                focusNode: passwordFocusNode,
                textObscured: _obscurePassword,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.visiblePassword,
                onFieldSubmitted: () => passwordCheckFocusNode.requestFocus(),
                suffixIcon: IconButton(
                  onPressed: () => setState(() {
                    _obscurePassword = !_obscurePassword;
                  }),
                  icon: Icon(_obscurePassword
                      ? Icons.visibility
                      : Icons.visibility_off),
                ),
              ),
              RegistrationTextformfield(
                controller: passwordCheckController,
                text: "Passwort wiederholen",
                validator: _validatePasswordCheck,
                focusNode: passwordCheckFocusNode,
                textObscured: _obscurePasswordCheck,
                textInputAction: TextInputAction.unspecified,
                keyboardType: TextInputType.visiblePassword,
                onFieldSubmitted: () => FocusScope.of(context).unfocus(),
                suffixIcon: IconButton(
                  onPressed: () => setState(() {
                    _obscurePasswordCheck = !_obscurePasswordCheck;
                  }),
                  icon: Icon(_obscurePasswordCheck
                      ? Icons.visibility
                      : Icons.visibility_off),
                ),
              ),
              RegistrationImageInput(),
              RegistrationImagePreview(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(150, 40),
                ),
                onPressed: () {
                  _isLoading ? null : _register();
                },
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text("Registrieren"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Du hast schon einen Account?",
                    style: TextStyle(color: Colors.black),
                  ),
                  TextButton(
                    child: Text(
                      "Login",
                      style: TextStyle(
                          color: Colors.green[100],
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline),
                    ),
                    onPressed: () {
                      context.router.push(const LoginRoute());
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    if (_formCheck.currentState?.validate() != true) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final images = ref.read(imageManagerProvider);

      final uid = await authRepo.registerWithEmail(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        image: images.photo,
      );

      final session = ref.read(sessionProvider.notifier);
      session.setActiveUserAfterRegistration(uid);

      ref.read(imageManagerProvider.notifier).clearPhoto();

      if (mounted) {
        context.router.push(const GroupOnboardingRoute());
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Registrierung fehlgeschlagen: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
      ),
    );
  }

  String? _validateName(String? name) {
    if (name == null || name.isEmpty) {
      return "Bitte Name eingeben.";
    } else if (name.length < 3) {
      return "Der Name ist zu kurz.";
    } else {
      return null;
    }
  }

  String? _validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return "Bitte E-Mail Adresse eingeben.";
    } else if (!EmailValidator.validate(email)) {
      return "Bitte richtige E-Mail Adresse eingeben.";
    } else {
      return null;
    }
  }

  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return "Bitte Passwor t eingeben.";
    } else if (password.length < 6) {
      return "Das Passwort ist zu kurz.";
    } else if (!password.contains(RegExp(r'[0-9]'))) {
      return "Passwort benötigt mind. eine Ziffer.";
    } else
      return null;
  }

  String? _validatePasswordCheck(String? passwordCheck) {
    if (passwordCheck == null || passwordCheck.isEmpty) {
      return "Bitte Passwort wiederholen.";
    } else if (passwordController.text != passwordCheck) {
      return "Passwörter stimmen nicht überein.";
    } else {
      return null;
    }
  }
}
