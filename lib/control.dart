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
  int throttle = 1500;
  int yaw = 1500;

  late UDP sender;

  int feedRefreshKey = 0;

  @override
  void initState() {
    super.initState();
    lockLandscape();
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
      throttle = (throttle + deltaThrottle).clamp(1000, 2000);
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

  @override
  void dispose() {
    sender.close();
    resetOrientation();
    super.dispose();
  }

  void sendData() async {
    final buffer = ByteData(8);
    buffer.setUint16(0, roll, Endian.little);
    buffer.setUint16(2, pitch, Endian.little);
    buffer.setUint16(4, throttle, Endian.little);
    buffer.setUint16(6, yaw, Endian.little);

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
            onRightJoystickChange: handleRightJoystick
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
          ),
        ],
      ),
    );
  }
}
