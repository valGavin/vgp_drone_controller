import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:udp/udp.dart';
import 'dart:typed_data';
import 'dart:io';
import 'widgets/camera_feed.dart';
import 'widgets/channel_value_overlay.dart';
import 'widgets/brightness_control.dart';
import 'widgets/settings_menu.dart';
import 'widgets/dual_joystick.dart';

class Control extends StatefulWidget {
  final String droneIP;
  final String cameraIP;
  const Control({super.key, required this.droneIP, required this.cameraIP});

  @override
  State<Control> createState() => _ControlState();
}

class _ControlState extends State<Control> {
  int roll = 1500;
  int pitch = 1500;
  int throttle = 855;
  int yaw = 1500;
  int aux1 = 1200;

  late UDP sender;
  bool senderReady = false;

  int feedRefreshKey = 0;

  bool isArmed = false;

  @override
  void initState() {
    super.initState();
    lockLandscape();
    initSender();
  }

  Future<void> initSender() async {
    sender = await UDP.bind(Endpoint.any());
    setState(() { senderReady = true; });
  }

  void handleLeftJoystick(int newRoll, int newPitch) {
    setState(() {
      roll = newRoll;
      pitch = newPitch;
    });
    sendData();
  }

  void handleRightJoystick(int deltaThrottle, int newYaw) {
    setState(() {
      throttle = (throttle + deltaThrottle).clamp(850, 2000);
      yaw = newYaw;
    });
    sendData();
  }

  void lockLandscape() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  void resetOrientation() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  void toggleArm() {
    setState(() {
      isArmed = !isArmed;
      aux1 = isArmed ? 1500 : 1200;
    });
    sendData();
  }

  @override
  void dispose() {
    sender.close();
    resetOrientation();
    super.dispose();
  }

  void sendData() async {
    if (!senderReady) return;

    final buffer = ByteData(10);
    buffer.setUint16(0, roll, Endian.little);
    buffer.setUint16(2, pitch, Endian.little);
    buffer.setUint16(4, throttle, Endian.little);
    buffer.setUint16(6, yaw, Endian.little);
    buffer.setUint16(8, aux1, Endian.little);

    await sender.send(
      buffer.buffer.asUint8List(),
      Endpoint.unicast(InternetAddress(widget.droneIP), port: const Port(9877)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CameraFeed(
            cameraIP: widget.cameraIP,
            refreshKey: feedRefreshKey,
            onReload: () { setState(() { feedRefreshKey++; }); },
          ),
          DualJoystick(
            onLeftJoystickChange: handleLeftJoystick,
            onRightJoystickChange: handleRightJoystick,
            isEnabled: isArmed,
          ),
          ChannelValueOverlay(
            roll: roll,
            pitch: pitch,
            throttle: throttle,
            yaw: yaw,
          ),
          BrightnessControl(cameraIP: widget.cameraIP),
          SettingsMenu(
            onReloadCamera: () { setState(() { feedRefreshKey++; }); },
            isArmed: isArmed,
            onToggleArm: toggleArm,
          ),
        ],
      ),
    );
  }
}
