import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:ugz_app/src/features/auth/providers/user_data_provider.dart';
import 'package:ugz_app/src/features/settings/widgets/app_theme_mode_tile/app_theme_mode_tile.dart';
import 'package:ugz_app/src/l10n/generated/app_localizations.dart';
import 'package:ugz_app/src/constants/gen/assets.gen.dart';
import 'package:ugz_app/src/constants/language_list.dart';
import 'package:ugz_app/src/global_providers/global_providers.dart';
import 'package:ugz_app/src/routes/router_config.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';
import 'package:ugz_app/src/constants/colors.dart';
import 'package:ugz_app/src/widgets/custom_button.dart';
import 'package:ugz_app/src/widgets/custom_view.dart';
import 'package:ugz_app/src/widgets/radio_list_popup.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = context.textTheme;

    void _showLogoutConfirmDialog(BuildContext context, WidgetRef ref) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text(context.l10n!.logout, textAlign: TextAlign.center),
            titleTextStyle: context.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
            content: Text(
              context.l10n!.log_desc,
              style: context.textTheme.bodySmall!.copyWith(
                color: const Color(0xff71727A),
              ),
            ),
            actionsAlignment: MainAxisAlignment.spaceAround,
            actions: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: context.colorScheme.outline),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // Close the dialog
                },
                child: Text(context.l10n!.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  ref.read(userDataProvider.notifier).logout();
                  Navigator.of(dialogContext).pop(); // Close the dialog
                },
                child: Text(context.l10n!.logout),
              ),
            ],
          );
        },
      );
    }

    return CustomView(
      header: CustomViewHeader(
        children: [
          IconButton(
            onPressed: () => ref.read(routerConfigProvider).pop(),
            icon: FaIcon(
              FontAwesomeIcons.chevronLeft,
              size: 20,
              color: AppColors.light,
            ),
          ),
          Text(
            context.l10n!.settings,
            style: textTheme.titleSmall?.copyWith(color: AppColors.light),
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Assets.icons.uniguardLogo.svg(
              height: 80,
              // width: 80,
              colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(context.l10n!.profile),
            leading: const Icon(Icons.account_circle_outlined),
            onTap: () => ProfileRoute().push(context),
          ),
          // ListTile(
          //   title: Text(context.l10n!.change_password),
          //   leading: const Icon(Icons.password_rounded),
          //   onTap: () => ChangePasswordRoute().push(context),
          // ),
          // const Divider(),
          ListTile(
            title: Text(context.l10n!.app_language),
            leading: const Icon(Icons.translate_outlined),
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (context) => RadioListPopup(
                      title: context.l10n!.language,
                      optionList: AppLocalizations.supportedLocales,
                      value: context.currentLocale,
                      onChange: (locale) {
                        ref.read(l10nProvider.notifier).update(locale);
                        Navigator.pop(context);
                      },
                      getOptionTitle: getLanguageNameFormLocale,
                      getOptionSubtitle: getLanguageNameInEnFormLocale,
                    ),
              );
            },
          ),
          const AppThemeModeTile(),
          ListTile(
            title: Text(context.l10n!.about),
            leading: const Icon(Icons.info_outline),
            onTap: () => AboutRoute().push(context),
          ),
          const Gap(12),
          CustomButton(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            title: context.l10n!.logout,
            onPressed: () => _showLogoutConfirmDialog(context, ref),
          ),
        ],
      ),
    );
  }
}
