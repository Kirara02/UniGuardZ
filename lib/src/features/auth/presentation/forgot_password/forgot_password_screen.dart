import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ugz_app/src/constants/gen/assets.gen.dart';
import 'package:ugz_app/src/features/auth/widgets/ug_text_field.dart';
import 'package:ugz_app/src/routes/router_config.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';
import 'package:ugz_app/src/widgets/custom_button.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.hideKeyboard();
      },
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: context.colorScheme.surface,
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            height: 180,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Assets.images.uniguardIcon.image(
                                  width: 60,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  "UNIGUARD",
                                  style: context.textTheme.headlineLarge!
                                      .copyWith(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 36),
                          UGTextField(
                            controller: _emailController,
                            label: context.l10n!.email,
                            hintText: "user@mail.com",
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }

                              if (!value.isEmail) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            fullwidth: true,
                            title: context.l10n!.submit,
                            onPressed: () async {
                              context.hideKeyboard();
                              if (_formKey.currentState!.validate()) {}
                            },
                          ),
                          const Divider(height: 50),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 28,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        ref.read(routerConfigProvider).pop();
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.chevronLeft,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      context.l10n!.forgot_password,
                      style: context.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
