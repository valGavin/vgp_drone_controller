import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:udp/udp.dart';
import 'widgets/device_status_box.dart';
import 'control.dart';

class Connection extends StatefulWidget {
  const Connection({super.key});

  @override
  State<Connection> createState() => _ConnectionState();
}

class _ConnectionState extends State<Connection> {
  bool showDialogBox = true;
  bool droneConnected = false;
  bool cameraConnected = false;
  String droneIP = '';
  String cameraIP = '';
  bool waitingDots = true;

  late UDP receiver;

  @override
  void initState() {
    super.initState();
    startUDPListener();
    animateDots();
  }

  void animateDots() {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted || droneConnected && cameraConnected) timer.cancel();
      setState(() { waitingDots = !waitingDots; });
    });
  }

  void startUDPListener() async {
    receiver = await UDP.bind(Endpoint.any(port: const Port(8888)));
    receiver.asStream().listen((datagram) async {
      if (datagram == null) return;
      final message = String.fromCharCodes(datagram.data);
      final senderIP = datagram.address.address;
      if (message.startsWith('DRONE|') && !droneConnected) {
        setState(() {
          droneConnected = true;
          droneIP = message.split('|')[1];
        });
        await sendAck(senderIP, 9877);
      }
      if (message.startsWith('CAMERA|') && !cameraConnected) {
        setState(() {
          cameraConnected = true;
          cameraIP = message.split('|')[1];
        });
        await sendAck(senderIP, 9878);
      }
      if (droneConnected && cameraConnected) {
        await Future.delayed(const Duration(seconds: 1));
        receiver.close();
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => Control(
              droneIP: droneIP, cameraIP: cameraIP)),
          );
        }
      }
    });
  }

  Future<void> sendAck(String targetIP, int targetPort) async {
    final sender = await UDP.bind(Endpoint.any());
    final ownIP = await getOwnIP();
    final ackMessage = 'PHONE|$ownIP';
    await sender.send(
      ackMessage.codeUnits,
      Endpoint.unicast(InternetAddress(targetIP), port: Port(targetPort)));
    sender.close();
  }
  
  Future<String> getOwnIP() async {
    for (var interface in await NetworkInterface.list(type: InternetAddressType.IPv4)) {
      for (var addr in interface.addresses) {
        if (!addr.isLoopback && addr.address.startsWith('192.168.')) {
          return addr.address;
        }
      }
    }

    return '0.0.0.0';  // Fallback
  }
  
  @override
  void dispose() {
    receiver.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          opacity: .2,
          child: SizedBox.expand(
            child: Image.asset('assets/logo.webp', fit: BoxFit.cover),
          ),
        ),
        Column(
          children: [
            Expanded(
              child: DeviceStatusBox(
                connected: droneConnected,
                label: 'Drone',
                ip: droneIP,
                icon: Icons.airplanemode_active,
                waitingDots: waitingDots,
              ),
            ),
            Expanded(
              child: DeviceStatusBox(
                connected: cameraConnected,
                label: 'Camera',
                ip: cameraIP,
                icon: Icons.videocam,
                waitingDots: waitingDots,
              ),
            ),
          ],
        ),
        if (showDialogBox)
          AlertDialog(
            backgroundColor: Colors.black87,
            title: const Text(
              'Connection Reminder',
              style: TextStyle(color: Colors.white)),
            content: const Text(
              'Ensure your hotspot is ON and configured with the correct SSID and password.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () { setState(() { showDialogBox = false; }); },
                child: const Text(
                  'I understand', style: TextStyle(color: Color(0xFF05fc05)),
                ),
              ),
            ],
          ),
      ],
    );
  }
}