import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ugz_app/src/constants/gen/assets.gen.dart';
import 'package:ugz_app/src/features/home/presentation/home/controller/home_controller.dart';
import 'package:ugz_app/src/routes/router_config.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';
import 'package:ugz_app/src/utils/misc/print.dart';
import 'package:ugz_app/src/widgets/custom_view.dart';
import 'package:ugz_app/src/widgets/list_item.dart';

class FormsScreen extends ConsumerStatefulWidget {
  const FormsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FormsScreenState();
}

class _FormsScreenState extends ConsumerState<FormsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(formsProvider.notifier).getForms());
  }

  @override
  Widget build(BuildContext context) {
    final activities = ref.watch(formsProvider);

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
            "Forms",
            style: context.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(formsProvider.notifier).getForms();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // NavigatorHeader(title: context.l10n!.activity_log),
            // const Gap(16),
            activities.when(
              data: (data) {
                if (data.isEmpty) {
                  return const Center(child: Text("Forms empty"));
                }
                return ListView.separated(
                  itemCount: data.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const BouncingScrollPhysics(),
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    var form = data[index];
                    return ListItem(
                      // onPressed: () => ref
                      //     .read(routerProvider)
                      //     .push(Routes.form, extra: activity),
                      onPressed: () => FormRoute(formId: form.id).push(context),
                      title: form.formName,
                      prefixIconPath: Assets.icons.guard.path,
                    );
                  },
                );
              },
              loading:
                  () => SizedBox(
                    height: context.height * .9,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              error: (e, stack) {
                printIfDebug('Error fetching activities: $e');
                return SizedBox(
                  height: context.height * .9,
                  child: Center(child: Text('Error: $e')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
