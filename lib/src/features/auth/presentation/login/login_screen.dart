import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:ugz_app/src/constants/gen/assets.gen.dart';
import 'package:ugz_app/src/features/auth/providers/user_data_provider.dart';
import 'package:ugz_app/src/features/auth/widgets/ug_text_field.dart';
import 'package:ugz_app/src/routes/router_config.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';
import 'package:ugz_app/src/utils/launch_url_in_web.dart';
import 'package:ugz_app/src/utils/misc/print.dart';
import 'package:ugz_app/src/utils/misc/toast/toast.dart';
import 'package:ugz_app/src/widgets/custom_button.dart';
import 'package:ugz_app/src/widgets/dialog/exit_app_dialog.dart';
import 'package:ugz_app/src/widgets/dialog/loading_dialog.dart';
import 'package:ugz_app/src/global_providers/global_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with WidgetsBindingObserver {
  bool _isActive = true;
  bool _showPrivacyError = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoadingDialogVisible = false;
  bool _isPermissionDialogVisible = false;

  @override
  void initState() {
    super.initState();
    _isActive = true;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPermissions();
    });

    _initUserForDebug();
  }

  _initUserForDebug() {
    if (kDebugMode) {
      _emailController.text = "officer@gmail.com";
      _passwordController.text = "satudua";
    }
  }

  @override
  void dispose() {
    _isActive = false;
    _emailController.dispose();
    _passwordController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Listen to app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _isActive && mounted) {
      // Add a small delay to ensure the app is fully resumed
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _requestPermissions();
        }
      });
    }
  }

  // Show loading dialog
  Future<void> _showLoadingDialog(BuildContext context, String message) async {
    if (!_isLoadingDialogVisible) {
      _isLoadingDialogVisible = true;
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  // Function to request permissions
  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await _checkBluetoothPermission();
      await _checkBluetoothScanPermission();
      await _checkBluetoothConnectPermission();
      await _checkBatteryOptimization();
    }
    await _checkLocationPermissions();
    if (Platform.isAndroid && (await _getAndroidVersion() >= 30)) {
      _checkLocationAlwaysPermissions();
    } else if (Platform.isIOS) {
      _checkLocationAlwaysPermissions();
    }
  }

  Future<void> _checkBluetoothPermission() async {
    if (!mounted) return;
    await _showLoadingDialog(context, "Checking Bluetooth Permission...");

    // Check Bluetooth status
    bool isBluetoothEnabled = await _isBluetoothEnabled();
    if (mounted) {
      Navigator.of(context).pop();
    }
    _isLoadingDialogVisible = false;

    if (!isBluetoothEnabled && mounted) {
      await _showPermissionDialog(
        message:
            "Bluetooth permission: Bluetooth beacon scanning requires permission.",
        onFix: _requestEnableBluetooth,
      );
    }
  }

  Future<void> _checkBluetoothScanPermission() async {
    if (!mounted) return;
    final sdkInt = await _getAndroidVersion();
    if (sdkInt >= 31) {
      await _showLoadingDialog(
        context,
        "Checking Bluetooth Scan Permission...",
      );

      final status = await Permission.bluetoothScan.status;
      if (mounted) {
        Navigator.of(context).pop();
      }
      _isLoadingDialogVisible = false;

      if (!status.isGranted && mounted) {
        await _showPermissionDialog(
          message:
              "Bluetooth Scan permission: Required for scanning nearby Bluetooth devices.",
          onFix: () async {
            if (status.isPermanentlyDenied) {
              await openAppSettings();
            } else {
              await Permission.bluetoothConnect.request();
              await Permission.bluetoothScan.request();
            }
          },
        );
      }
    }
  }

  Future<void> _checkBluetoothConnectPermission() async {
    if (!mounted) return;
    final sdkInt = await _getAndroidVersion();
    if (sdkInt >= 31) {
      await _showLoadingDialog(
        context,
        "Checking Bluetooth Connect Permission...",
      );

      final status = await Permission.bluetoothConnect.status;
      if (mounted) Navigator.of(context).pop();
      _isLoadingDialogVisible = false;

      if (!status.isGranted && mounted) {
        await _showPermissionDialog(
          message:
              "Bluetooth Connect permission: Required to connect and read device information (like name).",
          onFix: () async {
            if (status.isPermanentlyDenied) {
              await openAppSettings();
            } else {
              await Permission.bluetoothConnect.request();
            }
          },
        );
      }
    }
  }

  Future<void> _checkBatteryOptimization() async {
    if (!mounted) return;
    await _showLoadingDialog(context, "Checking Battery Optimization...");

    // Cek kondisi battery optimization
    bool isBatteryOptimized = await _isBatteryOptimizationEnabled();
    if (mounted) {
      Navigator.of(context).pop();
    }
    _isLoadingDialogVisible = false;

    if (!isBatteryOptimized && mounted) {
      await _showPermissionDialog(
        message:
            "Battery optimizations: Battery optimization enabled. Location functions may be negatively impacted",
        onFix: _requestDisableBatteryOptimization,
      );
    }
  }

  Future<void> _checkLocationPermissions() async {
    if (!mounted) return;
    await _showLoadingDialog(context, "Checking Location Permissions...");

    // Cek status permission lokasi
    bool isLocationGranted = await _isLocationPermissionGranted();
    if (mounted) {
      Navigator.of(context).pop();
    }
    _isLoadingDialogVisible = false;

    if (!isLocationGranted && mounted) {
      await _showPermissionDialog(
        message: "GPS permission: GPS required permission",
        onFix: _requestLocationPermissions,
      );
    }
  }

  Future<void> _checkLocationAlwaysPermissions() async {
    if (!mounted) return;
    await _showLoadingDialog(
      context,
      "Checking Background Location Permissions...",
    );

    bool isLocationAlwaysGranted = await _isLocationAlwaysPermissionGranted();
    if (mounted) {
      Navigator.of(context).pop();
    }
    _isLoadingDialogVisible = false;

    if (!isLocationAlwaysGranted && mounted) {
      await _showPermissionDialog(
        message:
            "UniGuard requires background location access for:\n\n"
            "1. Real-time position tracking\n"
            "2. Security and attendance monitoring\n"
            "3. Periodic location reporting\n\n"
            "Your location data will be used solely for this application's purposes and will not be shared with third parties without your consent.\n\n"
            "Do you agree to grant background location access?",
        onFix: _requestLocationsAlwaysPermissions,
      );
    }
  }

  Future<bool> _isBatteryOptimizationEnabled() async {
    final batteryOptimizationStatus =
        await Permission.ignoreBatteryOptimizations.isGranted;

    return batteryOptimizationStatus;
  }

  Future<bool> _isBluetoothEnabled() async {
    if (Platform.isIOS) {
      // On iOS, we need to check both the permission and the service status
      final bluetoothPermission = await Permission.bluetooth.status;

      // Only proceed if all permissions are granted
      if (bluetoothPermission.isGranted) {
        return true;
      }
      return false;
    }

    // For Android, use the existing check
    final bluetoothStatus = await Permission.bluetooth.serviceStatus.isEnabled;
    printIfDebug(bluetoothStatus);
    return bluetoothStatus;
  }

  Future<bool> _isLocationPermissionGranted() async {
    final locationStatus = await Permission.location.isGranted;
    return locationStatus;
  }

  Future<bool> _isLocationAlwaysPermissionGranted() async {
    final locationAlwaysStatus = await Permission.locationAlways.isGranted;
    return locationAlwaysStatus;
  }

  Future<int> _getAndroidVersion() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt;
  }

  Future<void> _requestDisableBatteryOptimization() async {
    // AppSettings.openAppSettings(type: AppSettingsType.batteryOptimization);
    await Permission.ignoreBatteryOptimizations.request();
    printIfDebug(await Permission.ignoreBatteryOptimizations.status);
    if (await Permission
        .ignoreBatteryOptimizations
        .status
        .isPermanentlyDenied) {
      await Permission.ignoreBatteryOptimizations.request();
    }
  }

  Future<void> _requestEnableBluetooth() async {
    AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
  }

  Future<void> _requestLocationPermissions() async {
    // Check current status first
    final status = await Permission.location.status;

    if (status.isPermanentlyDenied) {
      // If permanently denied, directly open settings
      openAppSettings();
      return;
    }

    // If not permanently denied, request permission
    final requestStatus = await Permission.location.request();

    // If permission is denied after request, check if it's permanently denied
    if (requestStatus.isDenied) {
      if (requestStatus.isPermanentlyDenied) {
        openAppSettings();
      }
    }
  }

  Future<void> _requestLocationsAlwaysPermissions() async {
    // Check current status first
    final status = await Permission.locationAlways.status;

    if (status.isPermanentlyDenied) {
      // If permanently denied, directly open settings
      openAppSettings();
      return;
    }

    // If not permanently denied, request permission
    final requestStatus = await Permission.locationAlways.request();
    printIfDebug("Location always permission request status: $requestStatus");

    // If permission is denied after request, check if it's permanently denied
    if (requestStatus.isDenied) {
      if (requestStatus.isPermanentlyDenied) {
        openAppSettings();
      }
    }
  }

  // Function to show permission dialog
  Future<void> _showPermissionDialog({
    required String message,
    required Future<void> Function() onFix,
  }) async {
    if (!_isPermissionDialogVisible) {
      _isPermissionDialogVisible = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),

            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Assets.images.uniguardIcon.image(height: 24),
                    const SizedBox(width: 12),
                    Text("UniGuard", style: context.textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 16),
                Text(message, style: context.textTheme.labelMedium),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  _isPermissionDialogVisible = false; // Update status dialog
                },
                child: const Text("Deny"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Close dialog
                  _isPermissionDialogVisible = false;

                  await onFix(); // Fix permission
                },
                child: const Text("Allow"),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _showPrivacyPolicyDialog() async {
    final privacyPolicyUrl = ref.read(privacyPoliceUrlProvider);
    bool isAccepted = false;
    _showPrivacyError = false;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Privacy Policy'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'UniGuard Privacy Policy\n\n'
                            '1. Data Collection\n'
                            'We collect the following information:\n'
                            '- Location data for real-time tracking and attendance monitoring\n'
                            '- Device information for security purposes\n'
                            '- User credentials for authentication\n\n'
                            '2. How We Use Your Data\n'
                            '- Location tracking for security and attendance\n'
                            '- Device identification for authorized access\n'
                            '- User authentication and authorization\n\n'
                            '3. Data Protection\n'
                            '- All data is encrypted and stored securely\n'
                            '- Access is restricted to authorized personnel only\n'
                            '- Regular security audits are conducted\n\n'
                            '4. Your Rights\n'
                            '- Access your personal data\n'
                            '- Request data deletion\n'
                            '- Opt-out of location tracking\n'
                            '- Control your privacy settings\n\n'
                            'By using UniGuard, you agree to our privacy policy and terms of service.',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: isAccepted,
                        onChanged: (value) {
                          setState(() {
                            isAccepted = value ?? false;
                            if (isAccepted) {
                              _showPrivacyError = false;
                            }
                          });
                        },
                      ),
                      const Text('I agree to the privacy policy'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () async {
                      final toast = ref.read(toastProvider(context));

                      if (privacyPolicyUrl != null) {
                        await launchUrlInWeb(context, privacyPolicyUrl, toast);
                      }
                    },
                    child: const Text('View Full Privacy Policy'),
                  ),
                  if (_showPrivacyError)
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 300),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Please accept the privacy policy to continue',
                              style: context.textTheme.labelSmall!.copyWith(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (isAccepted) {
                      ref
                          .read(privacyPoliceProvider.notifier)
                          .updateState(true);
                      Navigator.of(context).pop();
                    } else {
                      setState(() {
                        _showPrivacyError = true;
                      });
                    }
                  },
                  child: const Text('Accept'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final toast = ref.watch(toastProvider(context));
    final hasAcceptedPrivacyPolicy = ref.watch(privacyPoliceProvider) ?? false;

    ref.listen(userDataProvider, (previous, next) {
      if (next is AsyncData) {
        hideLoadingDialog(context);
        if (next.value != null) {
          HomeRoute().go(context);
        }
      } else if (next is AsyncError) {
        next.showToastOnError(toast, withMicrotask: true);
      } else if (next.isLoading) {
        showLoadingDialog(context);
      }
    });

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
      child: GestureDetector(
        onTap: () {
          context.hideKeyboard();
        },
        child: SafeArea(
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            extendBody: true,
            body: Container(
              height: context.height,
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Column(
                        children: [
                          SizedBox(
                            height: 180,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Assets.images.uniguardIcon.image(
                                  width: 60,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  "UNIGUARD",
                                  style: context.textTheme.headlineLarge!
                                      .copyWith(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 36),
                          UGTextField(
                            controller: _emailController,
                            label: context.l10n!.email,
                            hintText: "user@mail.com",
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }

                              if (!value.isEmail) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          UGTextField(
                            controller: _passwordController,
                            label: context.l10n!.password,
                            hintText: "********",
                            obscureText: true,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.go,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            fullwidth: true,
                            title: context.l10n!.login,
                            onPressed: () async {
                              context.hideKeyboard();
                              if (_formKey.currentState!.validate()) {
                                if (!hasAcceptedPrivacyPolicy) {
                                  await _showPrivacyPolicyDialog();
                                  if (!(ref.read(privacyPoliceProvider) ??
                                      false)) {
                                    return;
                                  }
                                }
                                ref
                                    .read(userDataProvider.notifier)
                                    .login(
                                      email: _emailController.text.trim(),
                                      password: _passwordController.text.trim(),
                                    );
                              }
                            },
                          ),
                          const Divider(height: 50),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
