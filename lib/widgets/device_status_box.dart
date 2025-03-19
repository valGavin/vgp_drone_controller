import 'package:flutter/material.dart';

class DeviceStatusBox extends StatelessWidget {
  final bool connected;
  final String label;
  final String ip;
  final IconData icon;
  final bool waitingDots;

  const DeviceStatusBox({
    super.key,
    required this.connected,
    required this.label,
    required this.ip,
    required this.icon,
    required this.waitingDots});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black54,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            connected ? Icons.check_circle : icon,
            color: connected ? const Color(0xFF05fc05) : Colors.white70,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(connected
            ? '$label connected'
            : '$label: Waiting for connection ${waitingDots ? '.' : '..'}',
            style: const TextStyle(fontSize: 20, color: Colors.white),
          ),
          if (connected)
            Text(
              'IP: $ip',
              style: const TextStyle(fontSize: 20, color: Colors.white70),
            ),
        ],
      ),
    );
  }
}
