import 'package:flutter/material.dart';
import 'package:ugz_app/src/constants/colors.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';

class CustomView extends StatelessWidget {
  final CustomViewHeader header;
  final Widget body;
  final Widget? bottomNavigationBar;
  final bool? resizeToAvoidBottomInset;
  final Color? backgroundColor;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool canPop;

  const CustomView({
    super.key,
    required this.header,
    required this.body,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset,
    this.backgroundColor,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.canPop = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      bottomNavigationBar: bottomNavigationBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: Container(
        height: context.height,
        decoration: BoxDecoration(color: AppColors.primary),
        child: Column(
          children: [
            header,
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomViewHeader extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  const CustomViewHeader({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.isPortrait ? context.height * 0.1 : context.height * 0.2,
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      ),
    );
  }
}
