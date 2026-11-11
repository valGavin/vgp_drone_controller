import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:udp/udp.dart';
import 'dart:async';
import 'dart:io';
import 'control_packet.dart';
import 'widgets/camera_feed.dart';
import 'widgets/channel_value_overlay.dart';
import 'widgets/brightness_control.dart';
import 'widgets/settings_menu.dart';
import 'widgets/dual_joystick.dart';

class Control extends StatefulWidget {
  final String droneIP;
  final String cameraIP;
  const Control({super.key, required this.droneIP, required this.cameraIP});

  @override
  State<Control> createState() => _ControlState();
}

class _ControlState extends State<Control> with WidgetsBindingObserver {
  /// How often the control packet is sent, whether or not a stick is moving.
  /// The Pico W stops its iBUS output if packets stop for 500 ms, so this
  /// stream is the drone's link heartbeat.
  static const Duration sendInterval = Duration(milliseconds: 20);

  int roll = channelCentre;
  int pitch = channelCentre;
  int throttle = throttleIdle;
  int yaw = channelCentre;
  int aux1 = aux1Disarmed;

  UDP? sender;
  Timer? sendTimer;
  late final Endpoint droneEndpoint = Endpoint.unicast(
    InternetAddress(widget.droneIP),
    port: const Port(controlPort),
  );

  int feedRefreshKey = 0;

  bool isArmed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    lockLandscape();
    initSender();
  }

  Future<void> initSender() async {
    final socket = await UDP.bind(Endpoint.any());
    if (!mounted) {
      socket.close();
      return;
    }
    sender = socket;
    sendTimer = Timer.periodic(sendInterval, (_) { sendData(); });
  }

  void handleLeftJoystick(int newRoll, int newPitch) {
    setState(() {
      roll = newRoll;
      pitch = newPitch;
    });
  }

  void handleRightJoystick(int deltaThrottle, int newYaw) {
    setState(() {
      throttle = (throttle + deltaThrottle).clamp(throttleMin, throttleMax);
      yaw = newYaw;
    });
  }

  void lockLandscape() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  void resetOrientation() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  void toggleArm() {
    if (isArmed) {
      disarm();
      return;
    }
    setState(() {
      isArmed = true;
      throttle = throttleIdle;
      aux1 = aux1Armed;
    });
    sendData();
  }

  /// Disarms, centres the sticks and returns throttle to idle, so that
  /// arming again never starts from a leftover throttle value.
  void disarm() {
    void reset() {
      isArmed = false;
      roll = channelCentre;
      pitch = channelCentre;
      throttle = throttleIdle;
      yaw = channelCentre;
      aux1 = aux1Disarmed;
    }

    if (mounted) {
      setState(reset);
    } else {
      reset();
    }
    sendData();
  }

  /// Disarms, makes sure the drone has been told, then closes the app.
  Future<void> quit() async {
    disarm();
    for (var i = 0; i < 3; i++) {
      await sendData();
    }
    exit(0);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Leaving the foreground must not leave an armed drone behind. `inactive`
    // is left out on purpose: it also fires for brief interruptions such as
    // the notification shade.
    final leftForeground = state == AppLifecycleState.hidden
        || state == AppLifecycleState.paused
        || state == AppLifecycleState.detached;
    if (leftForeground && isArmed) disarm();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    sendTimer?.cancel();
    final socket = sender;
    sender = null;
    if (socket != null) {
      socket
          .send(encodeDisarmPacket(), droneEndpoint)
          .catchError((_) => 0)
          .whenComplete(socket.close);
    }
    resetOrientation();
    super.dispose();
  }

  Future<void> sendData() async {
    final socket = sender;
    if (socket == null) return;

    final packet = encodeControlPacket(
      roll: roll,
      pitch: pitch,
      throttle: throttle,
      yaw: yaw,
      aux1: aux1,
    );
    try {
      await socket.send(packet, droneEndpoint);
    } catch (_) {
      // A failed send is a dropped packet. If they keep failing, the Pico W
      // times out and the flight controller's failsafe takes over.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CameraFeed(
            cameraIP: widget.cameraIP,
            refreshKey: feedRefreshKey,
            onReload: () { setState(() { feedRefreshKey++; }); },
          ),
          DualJoystick(
            onLeftJoystickChange: handleLeftJoystick,
            onRightJoystickChange: handleRightJoystick,
            isEnabled: isArmed,
          ),
          ChannelValueOverlay(
            roll: roll,
            pitch: pitch,
            throttle: throttle,
            yaw: yaw,
          ),
          BrightnessControl(cameraIP: widget.cameraIP),
          SettingsMenu(
            onReloadCamera: () { setState(() { feedRefreshKey++; }); },
            isArmed: isArmed,
            onToggleArm: toggleArm,
            onQuit: quit,
          ),
        ],
      ),
    );
  }
}
