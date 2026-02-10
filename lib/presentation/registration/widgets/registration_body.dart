import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/validators/auth_validators.dart';
import 'package:meal_planner/presentation/common/loading_overlay.dart';
import 'package:meal_planner/presentation/registration/widgets/registration_button.dart';
import 'package:meal_planner/presentation/registration/widgets/registration_image_input.dart';
import 'package:meal_planner/presentation/registration/widgets/registration_image_preview.dart';
import 'package:meal_planner/presentation/registration/widgets/registration_textformfield.dart';
import 'package:meal_planner/presentation/router/router.gr.dart';
import 'package:meal_planner/services/providers/auth_providers.dart';
import 'package:meal_planner/services/providers/image_manager_provider.dart';

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

  GlobalKey<FormState> _formCheck = GlobalKey();

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
    ref.listen<AsyncValue<void>>(authControllerProvider, (prev, next) {
      next.when(
        loading: () {
          setState(() {
            _isLoading = true;
          });
        },
        error: (e, _) {
          setState(() => _isLoading = false);
          _showError(e.toString());
        },
        data: (_) {
          setState(() => _isLoading = false);

          context.router.replace(const GroupOnboardingRoute());
        },
      );
    });

    return LoadingOverlay(
      isLoading: _isLoading,
      child: Center(
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
                  validator: AuthValidators.name,
                  focusNode: nameFocusNode,
                  textObscured: false,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  onFieldSubmitted: () => emailFocusNode.requestFocus(),
                ),
                RegistrationTextformfield(
                  controller: emailController,
                  text: "E-Mail",
                  validator: AuthValidators.email,
                  focusNode: emailFocusNode,
                  textObscured: false,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  onFieldSubmitted: () => passwordFocusNode.requestFocus(),
                ),
                RegistrationTextformfield(
                  controller: passwordController,
                  text: "Passwort",
                  validator: AuthValidators.registrationPassword,
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
                  validator: (value) => AuthValidators.passwordCheck(
                      value, passwordController.text),
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
                RegistrationButton(onPressed: () => _register()),
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
      ),
    );
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();
    if (_formCheck.currentState?.validate() != true) {
      return;
    }

    final images = ref.read(imageManagerProvider);

    ref.read(authControllerProvider.notifier).register(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text,
          image: images.photo,
        );
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
}
