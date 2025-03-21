import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:ugz_app/src/constants/colors.dart';
import 'package:ugz_app/src/constants/gen/assets.gen.dart';
import 'package:ugz_app/src/routes/router_config.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';
import 'package:ugz_app/src/widgets/custom_view.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final ValueNotifier<({bool isLoading, dynamic data, String? error})>
  _nfcState = ValueNotifier((isLoading: false, data: null, error: null));

  Stream<bool> _nfcAvailabilityStream() async* {
    while (true) {
      final isAvailable = await NfcManager.instance.isAvailable();
      yield isAvailable;
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override
  void dispose() {
    _nfcState.value = (isLoading: false, data: null, error: null);
    _nfcState.dispose();

    NfcManager.instance.stopSession();

    super.dispose();
  }

  void _startNfcReading() async {
    _nfcState.value = (isLoading: true, data: null, error: null);

    try {
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          final ndef = Ndef.from(tag);
          if (ndef == null) {
            _nfcState.value = (
              isLoading: false,
              data: null,
              error: "Tag tidak didukung",
            );
            return;
          }

          final message = ndef.cachedMessage;
          _nfcState.value = (
            isLoading: false,
            data: message?.records.map((e) => e.payload).toList(),
            error: null,
          );

          NfcManager.instance.stopSession();
        },
        onError: (error) async {
          _nfcState.value = (
            isLoading: false,
            data: null,
            error: context.l10n!.nfc_error_tag(error),
          );
        },
      );
    } catch (e) {
      _nfcState.value = (isLoading: false, data: null, error: "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomView(
      header: CustomViewHeader(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: FaIcon(
              FontAwesomeIcons.chevronLeft,
              size: 20,
              color: AppColors.light,
            ),
          ),
          Text(
            context.l10n!.scan,
            style: context.textTheme.titleSmall?.copyWith(
              color: AppColors.light,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<bool>(
          stream: _nfcAvailabilityStream(),
          builder: (context, snapshot) {
            // Handle loading/error NFC availability
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _buildErrorView(context.l10n!.nfc_error_msg);
            }

            final isNfcAvailable = snapshot.data ?? false;

            return ValueListenableBuilder(
              valueListenable: _nfcState,
              builder: (context, state, _) {
                if (isNfcAvailable &&
                    !state.isLoading &&
                    state.data == null &&
                    state.error == null) {
                  _startNfcReading();
                }

                return isNfcAvailable
                    ? _buildNfcContent(state)
                    : _buildNfcUnavailableView(context);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildNfcContent(
    ({bool isLoading, dynamic data, String? error}) state,
  ) {
    if (state.error != null) {
      return _buildErrorView(state.error!);
    }

    if (state.data != null) {
      return _buildSuccessView(state.data!);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Assets.images.scanning.image(scale: 1.2),
        const SizedBox(height: 20),
        Text(
          context.l10n!.nfc_near,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView(dynamic data) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Assets.images.nfcSuccess.image(scale: 1.2),
        const SizedBox(height: 20),
        Text(
          "Data: ${data.toString()}",
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: context.height * 0.3),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            child: const Text("Return Home"),
            onPressed: () => ref.read(routerConfigProvider).pop(),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(String error) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Assets.images.nfcFailed.image(scale: 1.2),
        const SizedBox(height: 20),
        Text(
          error,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: context.height * 0.3),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            child: const Text("Return Home"),
            onPressed: () => ref.read(routerConfigProvider).pop(),
          ),
        ),
      ],
    );
  }

  Widget _buildNfcUnavailableView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Assets.images.notSupport.image(scale: 1.2),
        const SizedBox(height: 20),
        Text(
          context.l10n!.nfc_not_support,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: context.height * 0.3),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            child: const Text("Return Home"),
            onPressed: () => ref.read(routerConfigProvider).pop(),
          ),
        ),
      ],
    );
  }
}
