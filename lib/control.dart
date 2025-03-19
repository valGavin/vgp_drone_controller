import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:udp/udp.dart';
import 'dart:typed_data';
import 'dart:io';
import 'widgets/channel_value_bar.dart';

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

  @override
  void initState() {
    super.initState();
    lockLandscape();
    initSender();
  }

  Future<void> initSender() async { sender = await UDP.bind(Endpoint.any()); }

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
          Positioned.fill(
            child: Image.network(
              'http://${widget.cameraIP}/',  // ESP32-CAM stream
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Text(
                  'Camera feed error',
                  style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
          // Left joystick - Roll and Pitch
          Positioned(
            bottom: 30,
            left: 30,
            child: Joystick(
              mode: JoystickMode.all,
              listener: (details) {
                setState(() {
                  roll = (1500 + (details.x * 500)).clamp(1000, 2000).toInt();
                  pitch = (1500 + (-details.y * 500)).clamp(1000, 2000).toInt();
                });
                sendData();
              },
              onStickDragEnd: () {
                setState(() {
                  roll = 1500;
                  pitch = 1500;
                });
                sendData();
              },
              base: JoystickBase(
                decoration: JoystickBaseDecoration(color: Colors.black),
                arrowsDecoration: JoystickArrowsDecoration(color: Color(0xFF05fc05)),
              ),
              stick: JoystickStick(
                decoration: JoystickStickDecoration(color: Color(0xFF05fc05)),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: Joystick(
              mode: JoystickMode.horizontalAndVertical,
              listener: (details) {
                setState(() {
                  throttle = (throttle + (-details.y * 10)).clamp(1000, 2000).toInt();
                  yaw = (1500 + (details.x * 500)).clamp(1000, 2000).toInt();
                });
                sendData();
              },
              onStickDragEnd: () {
                setState(() { yaw = 1500; });
                sendData();
              },
              base: JoystickBase(
                decoration: JoystickBaseDecoration(color: Colors.black),
                arrowsDecoration: JoystickArrowsDecoration(color: Color(0xFF05fc05)),
              ),
              stick: JoystickStick(
                decoration: JoystickStickDecoration(color: Color(0xFF05fc05)),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ChannelValueBar(label: 'R', value: roll),
                  ChannelValueBar(label: 'P', value: pitch),
                  ChannelValueBar(label: 'T', value: throttle),
                  ChannelValueBar(label: 'Y', value: yaw),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
