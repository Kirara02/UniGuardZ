import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ugz_app/src/constants/enum.dart';
import 'package:ugz_app/src/constants/gen/assets.gen.dart';
import 'package:ugz_app/src/features/history/domain/model/payload_data_activity_model.dart';
import 'package:ugz_app/src/features/history/domain/model/payload_data_form_model.dart';
import 'package:ugz_app/src/features/history/domain/model/payload_data_task_model.dart';
import 'package:ugz_app/src/features/history/presentation/history_detail/controller/history_detail_controller.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';
import 'package:intl/intl.dart';

class HistoryDetailScreen extends ConsumerStatefulWidget {
  final String historyId;
  final HistoryType historyType;
  const HistoryDetailScreen({
    super.key,
    required this.historyId,
    required this.historyType,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends ConsumerState<HistoryDetailScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  String? _mapStyle;

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(-6.2088, 106.8456), // Default to Jakarta
    zoom: 15,
  );

  LatLng? _coordinate;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
  }

  Future<void> _loadMapStyle() async {
    try {
      final string = await rootBundle.loadString(Assets.map.mapStyle);
      setState(() {
        _mapStyle = string;
      });
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Failed to load map style');
      }
    }
  }

  Future<void> _initializeLocation(Map<String, dynamic> data) async {
    if (widget.historyType == HistoryType.pending) {
      if (data['latitude'] != null && data['longitude'] != null) {
        final lat = data['latitude'] as double;
        final long = data['longitude'] as double;

        setState(() {
          _coordinate = LatLng(lat, long);
          _markers = {
            Marker(
              markerId: const MarkerId("dataMarker"),
              position: _coordinate!,
              infoWindow: const InfoWindow(title: "Location"),
            ),
          };
        });

        if (_coordinate != null) {
          await _moveCameraToLocation(_coordinate!);
        }
      }
    } else {
      final payloadData = data['payload_data'] as Map<String, dynamic>;
      final type = payloadData['type'] as String;

      Map<String, dynamic>? locationData;

      // Get location data based on type
      switch (type.toLowerCase()) {
        case 'form':
          locationData = payloadData['logForm'] as Map<String, dynamic>?;
        case 'task':
          locationData = payloadData['logTask'] as Map<String, dynamic>?;
        case 'activity':
          locationData = payloadData['logActivity'] as Map<String, dynamic>?;
        default:
          locationData = null;
      }

      if (locationData != null &&
          locationData['latitude'] != null &&
          locationData['longitude'] != null) {
        final lat = locationData['latitude'] as double;
        final long = locationData['longitude'] as double;

        setState(() {
          _coordinate = LatLng(lat, long);
          _markers = {
            Marker(
              markerId: const MarkerId("dataMarker"),
              position: _coordinate!,
              infoWindow: const InfoWindow(title: "Location"),
            ),
          };
        });

        if (_coordinate != null) {
          await _moveCameraToLocation(_coordinate!);
        }
      }
    }
  }

  Future<void> _moveCameraToLocation(LatLng newLocation) async {
    try {
      final GoogleMapController controller = await _controller.future;
      await controller.animateCamera(CameraUpdate.newLatLng(newLocation));
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Failed to move camera');
      }
    }
  }

  @override
  void dispose() {
    _disposeMapController();
    super.dispose();
  }

  Future<void> _disposeMapController() async {
    try {
      final controller = await _controller.future;
      controller.dispose();
    } catch (e) {
      // Ignore dispose errors
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      historyDetailControllerProvider(widget.historyId, widget.historyType),
    );

    ref.listen(
      historyDetailControllerProvider(widget.historyId, widget.historyType),
      (previous, next) {
        if (next.data != null) {
          _initializeLocation(next.data!);
        }
        if (next.error != null) {
          context.showSnackBar(next.error!);
        }
      },
    );

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n!.maps)),
      body:
          state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: _initialCameraPosition,
                      markers: _markers,
                      zoomControlsEnabled: false,
                      onMapCreated: (GoogleMapController controller) async {
                        _controller.complete(controller);
                        if (_mapStyle != null) {
                          await controller.setMapStyle(_mapStyle);
                        }
                      },
                    ),
                  ),
                  if (state.data != null) ...[
                    Expanded(
                      flex: 2,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.historyType == HistoryType.pending) ...[
                              Text(
                                "Form ID: ${state.data!['formId'] ?? '-'}",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Description: ${state.data!['description'] ?? '-'}",
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Category: ${state.data!['category'] ?? '-'}",
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Timestamp: ${state.data!['timestamp'] ?? '-'}",
                              ),
                            ] else ...[
                              _buildUploadedContent(context, state.data!),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
    );
  }

  Widget _buildUploadedContent(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final payloadData = data['payload_data'] as Map<String, dynamic>;
    final type = payloadData['type'] as String;

    switch (type.toLowerCase()) {
      case 'form':
        final formData = PayloadDataFormModel.fromJson(payloadData);
        final logForm = formData.logForm;
        final fields = formData.fields;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Form Name: ${logForm.formName}",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "Submitted Time: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(logForm.originalSubmittedTime))}",
            ),
            const SizedBox(height: 16),
            Text(
              "Form Fields:",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...fields.map((field) {
              final fieldTypeId = field.fieldTypeId;
              final isImageField = fieldTypeId == 4 || fieldTypeId == 5;
              final isBooleanField = fieldTypeId == 3;

              String getDisplayValue() {
                if (isBooleanField) {
                  return field.fieldTypeValue == '1' ? 'True' : 'False';
                }
                return field.fieldTypeValue ?? '-';
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      field.formFieldName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    if (isImageField && field.fieldTypeValue != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: field.fieldTypeValue!,
                          placeholder:
                              (context, url) => const SizedBox(
                                height: 200,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => const SizedBox(
                                height: 200,
                                child: Center(
                                  child: Text('Failed to load image'),
                                ),
                              ),
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Text(getDisplayValue()),
                  ],
                ),
              );
            }).toList(),
          ],
        );

      case 'task':
        final taskData = PayloadDataTaskModel.fromJson(payloadData);
        final logTask = taskData.logTask;
        final fields = taskData.fields;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Task Name: ${logTask.taskName}",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "Submitted Time: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(logTask.originalSubmittedTime))}",
            ),
            const SizedBox(height: 16),
            Text(
              "Task Fields:",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...fields.map((field) {
              final fieldTypeId = field.fieldTypeId;
              final isImageField = fieldTypeId == 4 || fieldTypeId == 5;
              final isBooleanField = fieldTypeId == 3;

              String getDisplayValue() {
                if (isBooleanField) {
                  return field.fieldTypeValue == '1' ? 'True' : 'False';
                }
                return field.fieldTypeValue ?? '-';
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      field.taskFieldName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    if (isImageField && field.fieldTypeValue != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: field.fieldTypeValue!,
                          placeholder:
                              (context, url) => const SizedBox(
                                height: 200,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          errorWidget:
                              (context, error, stackTrace) => const SizedBox(
                                height: 200,
                                child: Center(
                                  child: Text('Failed to load image'),
                                ),
                              ),
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Text(getDisplayValue()),
                  ],
                ),
              );
            }).toList(),
          ],
        );

      case 'activity':
        final logActivity =
            PayloadDataActivityModel.fromJson(payloadData).logActivity;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Activity Name: ${logActivity.activityName}",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "Submitted Time: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(logActivity.originalSubmittedTime))}",
            ),
            const SizedBox(height: 8),
            if (logActivity.comment != null) ...[
              Text("Comment:", style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(logActivity.comment!),
              const SizedBox(height: 8),
            ],
            if (logActivity.photoUrl != null) ...[
              Text("Photo:", style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Image.network(
                logActivity.photoUrl!,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Text('Failed to load image'),
              ),
            ],
          ],
        );

      default:
        return const Text('Unknown type');
    }
  }
}
