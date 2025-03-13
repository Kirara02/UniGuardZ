import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ugz_app/src/constants/enum.dart';
import 'package:ugz_app/src/constants/gen/assets.gen.dart';
import 'package:ugz_app/src/features/history/presentation/history_detail/controller/history_detail_controller.dart';
import 'package:ugz_app/src/utils/extensions/custom_extensions.dart';
import 'package:ugz_app/src/utils/misc/print.dart';

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
    printIfDebug(data);
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
          state.isUploading
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
                            Text(
                              "Form ID: ${state.data!['formId'] ?? '-'}",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Description: ${state.data!['description'] ?? '-'}",
                            ),
                            const SizedBox(height: 8),
                            Text("Category: ${state.data!['category'] ?? '-'}"),
                            const SizedBox(height: 8),
                            Text(
                              "Timestamp: ${state.data!['timestamp'] ?? '-'}",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
    );
  }
}
