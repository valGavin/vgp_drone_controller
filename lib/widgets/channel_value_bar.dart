import 'package:flutter/material.dart';

class ChannelValueBar extends StatelessWidget {
  final String label;
  final int value;
  const ChannelValueBar({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$label: $value',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        Container(
          width: 100,
          height: 8,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: LinearProgressIndicator(
            value: (value - 1000) / 1000,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
          ),
        ),
      ],
    );
  }
}
