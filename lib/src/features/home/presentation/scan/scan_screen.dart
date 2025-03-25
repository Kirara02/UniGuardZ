import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:ugz_app/src/constants/colors.dart';
import 'package:ugz_app/src/constants/gen/assets.gen.dart';
import 'package:ugz_app/src/features/home/domain/model/nfc_tag_model.dart';
import 'package:ugz_app/src/features/home/presentation/scan/controller/scan_controller.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';
import 'package:ugz_app/src/widgets/custom_view.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  StreamSubscription<bool>? _nfcAvailabilitySubscription;
  bool _isNfcAvailable = false;
  bool _previousSubmitting = false;
  bool _showUploadSuccess = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeNfcAvailability();
  }

  void _initializeNfcAvailability() {
    _nfcAvailabilitySubscription = _nfcAvailabilityStream().listen((
      isAvailable,
    ) {
      if (_isDisposed) return;

      setState(() => _isNfcAvailable = isAvailable);

      if (isAvailable) {
        try {
          final state = ref.read(scanControllerProvider);
          if (!state.isLoading && state.tag == null && state.error == null) {
            ref.read(scanControllerProvider.notifier).startScanning();
          }
        } catch (e) {
          // Handle possible disposed widget errors silently
          debugPrint('Error accessing ref: $e');
        }
      }
    });
  }

  Stream<bool> _nfcAvailabilityStream() async* {
    while (!_isDisposed) {
      try {
        final isAvailable = await NfcManager.instance.isAvailable();
        yield isAvailable;
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        debugPrint('Error in NFC availability stream: $e');
        yield false;
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  void _navigateBack() {
    if (!_isDisposed && mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _nfcAvailabilitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        try {
          if (mounted) {
            // Safely stop scanning before popping
            final controller = ref.read(scanControllerProvider.notifier);
            controller.stopScanning();
          }
        } catch (e) {
          debugPrint('Error in onWillPop: $e');
        }
        return true;
      },
      child: CustomView(
        header: CustomViewHeader(
          children: [
            IconButton(
              onPressed: _navigateBack,
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
        body: Consumer(
          builder: (context, ref, child) {
            late final ScanState state;
            try {
              state = ref.watch(scanControllerProvider);
            } catch (e) {
              debugPrint('Error watching scanControllerProvider: $e');
              return const Center(child: Text('An error occurred'));
            }

            // Check if submission just completed successfully
            if (_previousSubmitting &&
                !state.isSubmitting &&
                state.error == null &&
                !_showUploadSuccess) {
              // Use post-frame callback to avoid setState during build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!_isDisposed && mounted) {
                  setState(() {
                    _showUploadSuccess = true;
                  });
                }
              });
            }
            _previousSubmitting = state.isSubmitting;

            if (!_isNfcAvailable) {
              return _buildNfcUnavailableView();
            }

            // Show loading overlay when submitting
            return SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child:
                        _showUploadSuccess
                            ? _buildUploadSuccessView(state.tag)
                            : _buildNfcContent(state),
                  ),
                  if (state.isSubmitting)
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.black54,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'Uploading scan data...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUploadSuccessView(NfcTagModel? tag) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Assets.images.nfcSuccess.image(scale: 1.2),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Column(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green, size: 48),
                const SizedBox(height: 16),
                Text(
                  "Upload Successful!",
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Your scan data has been successfully uploaded.",
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: Colors.green.shade700,
                  ),
                ),
                if (tag != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "ID: ${tag.uid}",
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text("Scan Again"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    if (!_isDisposed && mounted) {
                      try {
                        setState(() {
                          _showUploadSuccess = false;
                        });
                        // Reset state and start scanning again
                        ref.read(scanControllerProvider.notifier).reset();
                        ref
                            .read(scanControllerProvider.notifier)
                            .startScanning();
                      } catch (e) {
                        debugPrint('Error restarting scan: $e');
                      }
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.home),
                  label: const Text("Return Home"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _navigateBack,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNfcContent(ScanState state) {
    if (state.error != null) {
      return _buildErrorView(state.error!);
    }

    if (state.tag != null) {
      return _buildSuccessView(state.tag!);
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
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
      ),
    );
  }

  Widget _buildSuccessView(NfcTagModel tag) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Assets.images.nfcSuccess.image(scale: 1.2),
        const SizedBox(height: 20),
        Text(
          "Card Type: ${tag.type}",
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "UID: ${tag.uid}",
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Complete Tag Data:",
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(tag.rawData.toString(), style: context.textTheme.bodySmall),
            ],
          ),
        ),
        if (tag.message != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "NDEF Data:",
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tag.message.toString(),
                  style: context.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
        SizedBox(height: context.height * 0.1),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text("Scan Again"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  if (!_isDisposed && mounted) {
                    try {
                      // Reset state and start scanning again
                      ref.read(scanControllerProvider.notifier).reset();
                      ref.read(scanControllerProvider.notifier).startScanning();
                    } catch (e) {
                      debugPrint('Error restarting scan: $e');
                    }
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.home),
                label: const Text("Return Home"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _navigateBack,
              ),
            ),
          ],
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: _navigateBack,
            child: const Text("Return Home"),
          ),
        ),
      ],
    );
  }

  Widget _buildNfcUnavailableView() {
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: _navigateBack,
            child: const Text("Return Home"),
          ),
        ),
      ],
    );
  }
}
