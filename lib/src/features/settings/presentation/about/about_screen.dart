import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:ugz_app/src/constants/gen/assets.gen.dart';
import 'package:ugz_app/src/features/settings/presentation/about/widgets/clipboard_list_tile.dart';
import 'package:ugz_app/src/global_providers/global_providers.dart';
import 'package:ugz_app/src/routes/router_config.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';
import 'package:ugz_app/src/constants/colors.dart';
import 'package:ugz_app/src/utils/misc/print.dart';

import 'package:ugz_app/src/utils/misc/toast/toast.dart';
import 'package:ugz_app/src/widgets/custom_view.dart';

class AboutScreen extends ConsumerStatefulWidget {
  const AboutScreen({super.key});

  @override
  ConsumerState<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen> {
  AppUpdateInfo? _updateInfo;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final packageInfo = ref.watch(packageInfoProvider);

    return CustomView(
      key: _scaffoldKey,
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
            context.l10n!.about,
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
          ClipboardListTile(
            title: context.l10n!.client,
            value: packageInfo.appName,
          ),
          ClipboardListTile(
            title: context.l10n!.client_version,
            value: "v${packageInfo.version}",
          ),
          ListTile(
            title: Text(context.l10n!.check_for_updates),
            onTap: () => _checkForInAppUpdate(),
          ),
        ],
      ),
    );
  }

  void _checkForInAppUpdate() async {
    final cContext = _scaffoldKey.currentContext;
    final toast = ref.read(toastProvider(cContext!));

    if (Platform.isAndroid) {
      await InAppUpdate.checkForUpdate()
          .then((info) {
            setState(() {
              _updateInfo = info;
            });
          })
          .catchError((e) {
            toast.showError(e.toString());
          });

      if (_updateInfo != null &&
          _updateInfo!.updateAvailability ==
              UpdateAvailability.updateAvailable) {
        InAppUpdate.performImmediateUpdate().catchError((e) {
          printIfDebug(e.toString());
          toast.showError(cContext.l10n!.update_failed);
          return AppUpdateResult.inAppUpdateFailed;
        });
      } else {
        toast.instantShow(cContext.l10n!.no_updates_available);
      }
    } else if (Platform.isIOS) {
      toast.instantShow(cContext.l10n!.check_app_store);
    }
  }
}
