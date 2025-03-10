import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:ugz_app/src/constants/gen/assets.gen.dart';
import 'package:ugz_app/src/features/home/presentation/home/controller/home_controller.dart';
import 'package:ugz_app/src/routes/router_config.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';
import 'package:ugz_app/src/utils/misc/print.dart';
import 'package:ugz_app/src/widgets/list_item.dart';
import 'package:ugz_app/src/widgets/navigator_header.dart';

class FormsSection extends ConsumerStatefulWidget {
  const FormsSection({super.key});

  @override
  ConsumerState<FormsSection> createState() => _FormsSectionState();
}

class _FormsSectionState extends ConsumerState<FormsSection> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(formsProvider.notifier).getForms());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final forms = ref.watch(formsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(formsProvider.notifier).getForms();
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          NavigatorHeader(title: context.l10n!.forms),
          const Gap(16),
          forms.when(
            data: (data) {
              if (data.isEmpty) {
                return const Center(child: Text("Forms empty"));
              }
              return ListView.separated(
                itemCount: data.length,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                separatorBuilder:
                    (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  var form = data[index];
                  return ListItem(
                    onPressed: () => FormRoute(formId: form.id).push(context),
                    title: form.formName,
                    prefixIconPath: Assets.icons.file.path,
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
              printIfDebug('Error fetching forms: $e');
              return SizedBox(
                height: context.height * .9,
                child: Center(child: Text('Error: $e')),
              );
            },
          ),
        ],
      ),
    );
  }
}
