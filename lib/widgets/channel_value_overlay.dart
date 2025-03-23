import 'package:flutter/material.dart';
import 'channel_value_bar.dart';

class ChannelValueOverlay extends StatelessWidget {
  final int roll, pitch, throttle, yaw;

  const ChannelValueOverlay({
    super.key,
    required this.roll,
    required this.pitch,
    required this.throttle,
    required this.yaw});

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
    );
  }
}
