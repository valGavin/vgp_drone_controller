import 'package:flutter/material.dart';
import 'package:udp/udp.dart';
import 'dart:io';

class BrightnessControl extends StatefulWidget {
  final String cameraIP;

  const BrightnessControl({super.key, required this.cameraIP});

  @override
  State<BrightnessControl> createState() => _BrightnessControlState();
}

class _BrightnessControlState extends State<BrightnessControl> {
  bool showSlider = false;
  int brightness = 32;
  late UDP brightnessSender;

  @override
  void initState() {
    super.initState();
    initSender();
  }

  Future<void> initSender() async {
    brightnessSender = await UDP.bind(Endpoint.any());
  }

  Future<void> sendBrightness(int value) async {
    final message = 'BRIGHTNESS|$value';
    await brightnessSender.send(
        message.codeUnits,
        Endpoint.unicast(InternetAddress(widget.cameraIP), port: const Port(9879)),
    );
  }

  @override
  void dispose() {
    brightnessSender.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 80,
      left: 20,
      child: Column(
        children: [
          GestureDetector(
            onTap: () { setState(() { showSlider = !showSlider; }); },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.lightbulb,
                color: brightness == 0 ? Colors.grey : Colors.amberAccent,
                size: 32,
              ),
            ),
          ),
          if (showSlider)
            Container(
              height: 150,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: RotatedBox(
                quarterTurns: -1,
                child: Slider(
                  value: brightness.toDouble(),
                  min: 0,
                  max: 255,
                  divisions: 255,
                  activeColor: Colors.amberAccent,
                  onChanged: (value) {
                    sendBrightness(value.toInt());
                    setState(() { brightness = value.toInt(); });
                  },
                  onChangeEnd: (value) { setState(() { showSlider = false; }); },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
