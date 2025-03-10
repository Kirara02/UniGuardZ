import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ugz_app/src/constants/colors.dart';
import 'package:ugz_app/src/features/auth/widgets/ug_text_field.dart';
import 'package:ugz_app/src/routes/router_config.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';
import 'package:ugz_app/src/widgets/custom_button.dart';
import 'package:ugz_app/src/widgets/custom_view.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _retypePasswordController =
      TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _retypePasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ref.listen(
    //   userChangePasswordProvider,
    //       (previous, next) {
    //     if (next is AsyncData && next.value != null) {
    //       context.showSnackBar("Profile updated successfully!");
    //
    //       _oldPasswordController.clear();
    //       _newPasswordController.clear();
    //       _retypePasswordController.clear();
    //
    //       ref.read(routerProvider).pop();
    //     } else if (next is AsyncError) {
    //       context.showSnackBar("${next.error}");
    //     }
    //   },
    // );

    return GestureDetector(
      onTap: () {
        context.hideKeyboard();
      },
      child: CustomView(
        header: CustomViewHeader(
          children: [
            IconButton(
              onPressed: () => ref.read(routerConfigProvider).pop(),
              icon: const FaIcon(
                FontAwesomeIcons.arrowLeft,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n!.change_password,
              style: context.textTheme.titleSmall?.copyWith(
                color: AppColors.light,
              ),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  UGTextField(
                    label: context.l10n!.old_password,
                    hintText: '******',
                    controller: _oldPasswordController,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter old password';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).nextFocus(); // Move to next field
                    },
                  ),
                  const SizedBox(height: 20),
                  UGTextField(
                    label: context.l10n!.new_password,
                    hintText: '******',
                    controller: _newPasswordController,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter new password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters long';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).nextFocus(); // Move to next field
                    },
                  ),
                  const SizedBox(height: 20),
                  UGTextField(
                    label: context.l10n!.retype_new_password,
                    hintText: '******',
                    controller: _retypePasswordController,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter retype new password';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).unfocus(); // Move to next field
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    title: context.l10n!.confirm,
                    fullwidth: true,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // ref.read(userChangePasswordProvider.notifier).changePassword(
                        //     params: ChangePasswordParams(
                        //         currentPassword: _oldPasswordController.text,
                        //         newPassword: _newPasswordController.text));
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
