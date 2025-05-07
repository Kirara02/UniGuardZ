import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ugz_app/src/constants/gen/assets.gen.dart';
import 'package:ugz_app/src/features/home/presentation/forms/controller/forms_controller.dart';
import 'package:ugz_app/src/routes/router_config.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';
import 'package:ugz_app/src/utils/misc/print.dart';
import 'package:ugz_app/src/widgets/custom_view.dart';
import 'package:ugz_app/src/widgets/emoticons.dart';
import 'package:ugz_app/src/widgets/list_item.dart';

class FormsScreen extends ConsumerStatefulWidget {
  const FormsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FormsScreenState();
}

class _FormsScreenState extends ConsumerState<FormsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(formsControllerProvider.notifier).getForms(),
    );
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(formsControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(formsControllerProvider);

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
            context.l10n!.forms,
            style: context.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(formsControllerProvider.notifier).getForms();
        },
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            if (state.isLoading && state.forms.isEmpty)
              SizedBox(
                height: context.height * .9,
                child: const Center(child: CircularProgressIndicator()),
              )
            else if (state.error != null && state.forms.isEmpty)
              SizedBox(
                height: context.height * .9,
                child: Emoticons(text: 'Error: ${state.error}'),
              )
            else if (state.forms.isEmpty)
              Emoticons(text: context.l10n!.no_forms_found)
            else ...[
              ListView.separated(
                itemCount: state.forms.length + (state.hasMore ? 1 : 0),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder:
                    (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == state.forms.length) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child:
                            state.isLoadingMore
                                ? const CircularProgressIndicator()
                                : const SizedBox.shrink(),
                      ),
                    );
                  }

                  var form = state.forms[index];
                  return ListItem(
                    onPressed: () => FormRoute(formId: form.id).push(context),
                    title: form.formName,
                    prefixIconPath: Assets.icons.guard.path,
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
