import 'package:flutter_test/flutter_test.dart';

import 'package:vgp_drone_controller/control_packet.dart';

void main() {
  test('control packet is five little-endian uint16 values', () {
    final packet = encodeControlPacket(
      roll: 1500,
      pitch: 1000,
      throttle: 855,
      yaw: 2000,
      aux1: 1200,
    );

    expect(packet, [
      0xDC, 0x05, // roll 1500
      0xE8, 0x03, // pitch 1000
      0x57, 0x03, // throttle 855
      0xD0, 0x07, // yaw 2000
      0xB0, 0x04, // AUX1 1200
    ]);
  });

  test('control packet has the length the firmware expects', () {
    expect(encodeDisarmPacket().length, controlPacketLength);
    expect(controlPacketLength, 10);
  });

  test('disarm packet centres the sticks, idles throttle and disarms', () {
    expect(encodeDisarmPacket(), [
      0xDC, 0x05,
      0xDC, 0x05,
      0x57, 0x03,
      0xDC, 0x05,
      0xB0, 0x04,
    ]);
  });
}
