import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';

class CameraFeed extends StatelessWidget {
  final String cameraIP;
  final int refreshKey;
  final VoidCallback onReload;

  const CameraFeed({
    super.key,
    required this.cameraIP,
    required this.refreshKey,
    required this.onReload
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: KeyedSubtree(
        key: ValueKey(refreshKey),
        child: Mjpeg(
          stream: 'http://$cameraIP:9878/',
          isLive: true,
          error: (context, error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Camera feed error', style: TextStyle(color: Colors.white)),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black45,
                    shape: const CircleBorder(),
                  ),
                  onPressed: onReload,
                  child: const Icon(Icons.refresh, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
