import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ugz_app/src/constants/enum.dart';
import 'package:ugz_app/src/constants/gen/assets.gen.dart';
import 'package:ugz_app/src/features/history/domain/model/payload_data_activity_model.dart';
import 'package:ugz_app/src/features/history/domain/model/payload_data_alarm_model.dart';
import 'package:ugz_app/src/features/history/domain/model/payload_data_checkpoint_model.dart';
import 'package:ugz_app/src/features/history/domain/model/payload_data_form_model.dart';
import 'package:ugz_app/src/features/history/domain/model/payload_data_task_model.dart';
import 'package:ugz_app/src/features/history/domain/model/payload_data_user_model.dart';
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

  Map<String, dynamic>? logData;

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
    Map<String, dynamic>? locationData;

    if (widget.historyType == HistoryType.pending) {
      locationData = {
        'latitude': data['latitude'],
        'longitude': data['longitude'],
      };
    } else {
      final payload = data['payload_data'] as Map<String, dynamic>?;
      final type = (payload?['type'] as String?)?.toLowerCase();

      final locationMap = {
        'form': 'logForm',
        'task': 'logTask',
        'activity': 'logActivity',
        'user': 'userUserDevice',
        'checkpoint': 'logCheckpoint',
        'alarm': 'alarm',
      };

      locationData = payload?[locationMap[type]] as Map<String, dynamic>?;
    }

    if (locationData == null) return;

    final lat =
        locationData['end_latitude'] ??
        locationData['start_latitude'] ??
        locationData['latitude'];
    final long =
        locationData['end_longitude'] ??
        locationData['start_longitude'] ??
        locationData['longitude'];

    if (lat != null && long != null) {
      _coordinate = LatLng(lat as double, long as double);

      setState(() {
        _markers = {
          Marker(
            markerId: const MarkerId("dataMarker"),
            position: _coordinate!,
            infoWindow: const InfoWindow(title: "Location"),
          ),
        };
      });

      await _moveCameraToLocation(_coordinate!);
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
          setState(() {
            logData = next.data;
          });
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
                    child: Stack(
                      children: [
                        GoogleMap(
                          mapType: MapType.normal,
                          initialCameraPosition: _initialCameraPosition,
                          markers: _markers,
                          zoomControlsEnabled: false,
                          style: _mapStyle,
                          onMapCreated: (GoogleMapController controller) {
                            _controller.complete(controller);
                          },
                        ),
                        if (_coordinate == null)
                          Container(
                            color: Colors.black.withOpacity(0.5),
                            alignment: Alignment.center,
                            child: const Text(
                              "Lokasi tidak tersedia",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
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
                                _getTitleByCategory(
                                  state.data!['category'] ?? 1,
                                  state.data!,
                                ),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Submitted Time: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(state.data!['timestamp']))}",
                              ),
                              const SizedBox(height: 8),
                              _buildPendingFields(context, state.data!),
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
              "Submitted Time: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(logForm.originalSubmittedTime).toLocal())}",
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
              "Submitted Time: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(logTask.originalSubmittedTime).toLocal())}",
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
              "Submitted Time: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(logActivity.originalSubmittedTime).toLocal())}",
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
      case "user":
        final logUser = PayloadDataUserModel.fromJson(payloadData).logUser;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "History Type: ${logData?['alert_event_name']}",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "Device Name: ${logUser.deviceName}",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "Time: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(logUser.eventTime).toLocal())}",
            ),
          ],
        );

      case "checkpoint":
        final logChekpoint =
            PayloadDataCheckpointModel.fromJson(payloadData).logChekpoint;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Checkpoint Name: ${logChekpoint.checkpointName}",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "Device Name: ${logChekpoint.deviceName}",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "Time: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(logChekpoint.originalSubmittedTime).toLocal())}",
            ),
          ],
        );

      case "alarm":
        final logAlarm = PayloadDataAlarmModel.fromJson(payloadData).alarm;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "History Type: ${logData?['alert_event_name']}",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "Device Name: ${logAlarm.deviceName}",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "Start Datetime: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(logAlarm.startDateTime!).toLocal())}",
            ),
            const SizedBox(height: 8),
            Text(
              "End Datetime: ${logAlarm.endDateTime != null ? DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(logAlarm.endDateTime!).toLocal()) : "-"}",
            ),
          ],
        );

      default:
        return const Text('Unknown type');
    }
  }

  Widget _buildPendingFields(BuildContext context, Map<String, dynamic> data) {
    final formData = data['data'] as Map<String, dynamic>;
    final fields = [
      ...((formData['comments'] as List<dynamic>?) ?? []),
      ...((formData['switches'] as List<dynamic>?) ?? []),
      ...((formData['photos'] as List<dynamic>?) ?? []),
      ...((formData['signatures'] as List<dynamic>?) ?? []),
      ...((formData['selects'] as List<dynamic>?) ?? []),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          fields.map((field) {
            final fieldTypeId = field['typeId'] as String;
            final isImageField = fieldTypeId == "4" || fieldTypeId == "5";
            final isBooleanField = fieldTypeId == "3";
            final isSelectField = fieldTypeId == "6";

            String getDisplayValue() {
              if (isBooleanField) {
                return field['value'].toString().toLowerCase() == 'true'
                    ? 'True'
                    : 'False';
              }
              if (isSelectField) {
                return '${field['pickListOptionName']} (${field['pickListName']})';
              }
              return field['value']?.toString() ?? '-';
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    field['inputName'] ?? '-',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  if (isImageField && field['value'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(field['value']),
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => const SizedBox(
                              height: 200,
                              child: Center(
                                child: Text('Failed to load image'),
                              ),
                            ),
                      ),
                    )
                  else
                    Text(getDisplayValue()),
                ],
              ),
            );
          }).toList(),
    );
  }

  String _getTitleByCategory(int category, Map<String, dynamic> data) {
    switch (category) {
      case 1:
        return "Form Name: ${data['description'] ?? '-'}";
      case 2:
        return "Task Name: ${data['description'] ?? '-'}";
      case 3:
        return "Activity Name: ${data['description'] ?? '-'}";
      default:
        return "Form Name: ${data['description'] ?? '-'}";
    }
  }
}
