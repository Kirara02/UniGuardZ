import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ugz_app/src/constants/gen/assets.gen.dart';
import 'package:ugz_app/src/features/auth/providers/user_data_provider.dart';
import 'package:ugz_app/src/routes/router_config.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(userDataProvider, (previous, next) {
      if (next is AsyncData) {
        if (next.value != null) {
          HomeRoute().go(context);
        } else {
          LoginRoute().go(context);
        }
      } else if (next is AsyncError) {
        context.showSnackBar(next.error.toString());
      }
    });

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Assets.icons.uniguard.svg(
              colorFilter: ColorFilter.mode(
                context.colorScheme.onSurface,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
