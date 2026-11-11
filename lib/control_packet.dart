import 'dart:typed_data';

/// Channel values shared with the Pico W firmware (speedybee_control).
const int channelCentre = 1500;
const int channelMin = 1000;
const int channelMax = 2000;
const int throttleIdle = 855;
const int throttleMin = 850;
const int throttleMax = 2000;
const int aux1Disarmed = 1200;
const int aux1Armed = 1500;

/// UDP port the Pico W listens on for control packets.
const int controlPort = 9877;

/// Length of a control packet in bytes: five little-endian uint16 values.
const int controlPacketLength = 10;

/// Encodes one control packet: roll, pitch, throttle, yaw, AUX1.
///
/// The firmware drops packets of any other length, so a change here has to be
/// made in speedybee_control at the same time.
Uint8List encodeControlPacket({
  required int roll,
  required int pitch,
  required int throttle,
  required int yaw,
  required int aux1,
}) {
  final buffer = ByteData(controlPacketLength);
  buffer.setUint16(0, roll, Endian.little);
  buffer.setUint16(2, pitch, Endian.little);
  buffer.setUint16(4, throttle, Endian.little);
  buffer.setUint16(6, yaw, Endian.little);
  buffer.setUint16(8, aux1, Endian.little);
  return buffer.buffer.asUint8List();
}

/// The packet that disarms the drone: sticks centred, throttle idle.
Uint8List encodeDisarmPacket() => encodeControlPacket(
  roll: channelCentre,
  pitch: channelCentre,
  throttle: throttleIdle,
  yaw: channelCentre,
  aux1: aux1Disarmed,
);
