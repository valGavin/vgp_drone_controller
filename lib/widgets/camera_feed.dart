import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';

class CameraFeed extends StatelessWidget {
  final String cameraIP;
  final int refreshKey;
  const CameraFeed({super.key, required this.cameraIP, required this.refreshKey});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: KeyedSubtree(
        key: ValueKey(refreshKey),
        child: Mjpeg(
          stream: 'http://$cameraIP:9878/',
          isLive: true,
          error: (context, error, stack) => const Center(
            child: Text(
              'Camera feed error',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
