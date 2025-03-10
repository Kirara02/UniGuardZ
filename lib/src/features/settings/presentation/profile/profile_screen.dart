import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:ugz_app/src/constants/colors.dart';
import 'package:ugz_app/src/features/auth/providers/user_data_provider.dart';
import 'package:ugz_app/src/features/auth/widgets/ug_text_field.dart';
import 'package:ugz_app/src/routes/router_config.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';
import 'package:ugz_app/src/widgets/custom_view.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final bool isEdit;
  const ProfileScreen({super.key, this.isEdit = false});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    var user = ref.read(userDataProvider).valueOrNull;
    _nameController.text = user?.name ?? "";
    _emailController.text = user?.email ?? "";
    // _roleController.text = "Employee";
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomView(
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
            widget.isEdit ? 'Edit Profile' : context.l10n!.profile,
            style: context.textTheme.titleSmall?.copyWith(
              color: AppColors.light,
            ),
          ),
        ],
      ),
      body: Container(
        height: context.height * .9,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipOval(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const Gap(20),
              UGTextField(
                label: context.l10n!.name,
                hintText: 'Enter your name',
                controller: _nameController,
                readOnly: widget.isEdit ? false : true,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 20),
              UGTextField(
                label: context.l10n!.email,
                hintText: 'Enter your email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                readOnly: widget.isEdit ? false : true,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 20),
              UGTextField(
                label: context.l10n!.role,
                hintText: 'Enter Roll',
                controller: _roleController,
                keyboardType: TextInputType.emailAddress,
                readOnly: true,
                enabled: true,
                textInputAction: TextInputAction.done,
              ),
              const Spacer(),
              if (widget.isEdit)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text(context.l10n!.submit),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
