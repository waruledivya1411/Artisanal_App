import 'dart:async';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:artisnal_app/features/learn/data/displays.dart';
import 'package:artisnal_app/features/learn/screens/shoot_screen.dart';

/// A camera that opens straight away and counts opens and closes.
class FakeCamera extends CameraPlatform {
  int created = 0;
  int disposed = 0;
  final _init = StreamController<CameraInitializedEvent>.broadcast();

  @override
  Future<List<CameraDescription>> availableCameras() async => const [
        CameraDescription(
          name: 'back',
          lensDirection: CameraLensDirection.back,
          sensorOrientation: 90,
        ),
      ];

  @override
  Future<int> createCameraWithSettings(
    CameraDescription description,
    MediaSettings mediaSettings,
  ) async =>
      ++created;

  @override
  Stream<CameraInitializedEvent> onCameraInitialized(int cameraId) =>
      _init.stream.where((e) => e.cameraId == cameraId);

  @override
  Stream<CameraErrorEvent> onCameraError(int cameraId) =>
      StreamController<CameraErrorEvent>().stream;

  @override
  Stream<DeviceOrientationChangedEvent> onDeviceOrientationChanged() =>
      const Stream.empty();

  @override
  Future<void> initializeCamera(
    int cameraId, {
    ImageFormatGroup imageFormatGroup = ImageFormatGroup.unknown,
  }) async {
    scheduleMicrotask(() => _init.add(CameraInitializedEvent(
          cameraId, 1280, 720, ExposureMode.auto, false, FocusMode.auto, false)));
  }

  @override
  Widget buildPreview(int cameraId) => const ColoredBox(color: Colors.green);

  @override
  Future<void> dispose(int cameraId) async => disposed++;
}

void main() {
  testWidgets('camera comes back after the app returns', (t) async {
    final camera = FakeCamera();
    CameraPlatform.instance = camera;
    await t.pumpWidget(MaterialApp(
      home: ShootScreen(
        locale: 'en-US',
        display: everyDisplay.first,
        product: 'Saree',
      ),
    ));
    await t.pumpAndSettle();
    expect(camera.created, 1);
    expect(find.text('Opening the camera…'), findsNothing);

    // Out of view: the camera is given up and the screen shows it.
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await t.pump();
    expect(camera.disposed, 1);
    expect(find.text('Opening the camera…'), findsOneWidget);
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await t.pump();

    // Back in view: the camera opens again, once.
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await t.pumpAndSettle();
    expect(camera.created, 2);
    expect(find.text('Opening the camera…'), findsNothing);

    // A second resume while the camera is already open does nothing.
    t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await t.pumpAndSettle();
    expect(camera.created, 2);
  });
}
