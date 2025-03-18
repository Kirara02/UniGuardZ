import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:badges/badges.dart' as badges;
import 'package:ugz_app/src/constants/colors.dart';
import 'package:ugz_app/src/constants/gen/assets.gen.dart';
import 'package:ugz_app/src/features/auth/providers/user_data_provider.dart';
import 'package:ugz_app/src/global_providers/geolocation_tracking_service_providers.dart';
import 'package:ugz_app/src/global_providers/pending_count_providers.dart';
import 'package:ugz_app/src/local/usecases/delete_all_pending_forms/delete_all_pending_forms.dart';
import 'package:ugz_app/src/routes/router_config.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';
import 'package:ugz_app/src/widgets/custom_view.dart';
import 'package:ugz_app/src/widgets/dialog/exit_app_dialog.dart';

// import 'big_screen_navigation_bar.dart';
import 'small_screen_navigation_bar.dart';

class ShellScreen extends ConsumerStatefulWidget {
  const ShellScreen({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends ConsumerState<ShellScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) {
      // ref.read(geolocationServiceProvider.notifier).startTracking();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = ref.watch(pendingCountProvider);

    ref.listen(userDataProvider, (previous, next) {
      if (previous != null && next is AsyncData && next.value == null) {
        // Stop background service when logging out

        ref.read(geolocationServiceProvider.notifier).stopTracking();

        LoginRoute().go(context);
      } else if (next is AsyncError) {
        context.showSnackBar(next.error.toString());
      }
    });

    if (context.isTablet) {
      return Scaffold(
        body: Row(
          children: [
            // BigScreenNavigationBar(selectedScreen: context.location),
            Expanded(child: widget.child),
          ],
        ),
      );
    } else {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (!didPop) {
            final shouldExit = await showExitDialog(context);
            if (shouldExit == true) {
              exitApp();
            }
          }
        },
        child: CustomView(
          header: CustomViewHeader(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Assets.images.loginLogo.image(width: 120),
              Row(
                children: [
                  pendingCount.when(
                    data: (data) {
                      if (data != null && data > 0) {
                        return badges.Badge(
                          badgeContent: Text(
                            data.toString(),
                            textAlign: TextAlign.center,
                            style: context.textTheme.labelSmall!,
                          ),
                          badgeStyle: badges.BadgeStyle(
                            padding: const EdgeInsets.all(4),
                            badgeColor: context.colorScheme.secondaryFixedDim,
                            elevation: 0,
                          ),
                          position: badges.BadgePosition.topEnd(top: 2, end: 2),
                          child: IconButton(
                            onPressed: () {},
                            icon: const FaIcon(
                              FontAwesomeIcons.cloudArrowUp,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        );
                      }

                      return const SizedBox();
                    },
                    error: (err, _) => const SizedBox(),
                    loading: () => const SizedBox(),
                  ),
                  IconButton(
                    onPressed: () {
                      SettingsRoute().push(context);
                    },
                    icon: const FaIcon(
                      FontAwesomeIcons.gear,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  if (kDebugMode)
                    IconButton(
                      onPressed: () {
                        ref.read(dbDeleteAllPendingFormsProvider).call(null);
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.trashArrowUp,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ],
          ),
          body: widget.child,
          backgroundColor: context.colorScheme.surfaceContainer,
          floatingActionButton: FloatingActionButton(
            shape: const CircleBorder(),
            // onPressed: () => ref.read(routerProvider).push(Routes.SCAN),
            onPressed: () {},
            backgroundColor: AppColors.primary,
            child: Assets.icons.scan.svg(),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: SmallScreenNavigationBar(
            selectedScreen: context.location,
          ),
        ),
      );
    }
  }
}
