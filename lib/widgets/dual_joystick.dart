import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';

class DualJoystick extends StatelessWidget {
  final Function(int roll, int pitch) onLeftJoystickChange;
  final Function(int throttle, int yaw) onRightJoystickChange;

  const DualJoystick({
    super.key,
    required this.onLeftJoystickChange,
    required this.onRightJoystickChange
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 30,
          left: 30,
          child: Joystick(
            mode: JoystickMode.all,
            listener: (details) {
              int roll = (1500 + (details.x * 500)).clamp(1000, 2000).toInt();
              int pitch = (1500 + (-details.y * 500)).clamp(1000, 2000).toInt();
              onLeftJoystickChange(roll, pitch);
            },
            onStickDragEnd: () { onLeftJoystickChange(1500, 1500); },
            base: JoystickBase(
              decoration: JoystickBaseDecoration(color: Colors.black),
              arrowsDecoration: JoystickArrowsDecoration(color: Color(0xFF05fc05)),
            ),
            stick: JoystickStick(
              decoration: JoystickStickDecoration(color: Color(0xFF05fc05)),
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          right: 30,
          child: Joystick(
            mode: JoystickMode.horizontalAndVertical,
            listener: (details) {
              int deltaThrottle = (-details.y * 10).toInt();
              int yaw = (1500 + (details.x * 500)).clamp(1000, 2000).toInt();
              onRightJoystickChange(deltaThrottle, yaw);
            },
            onStickDragEnd: () { onRightJoystickChange(0, 1500); },
            base: JoystickBase(
              decoration: JoystickBaseDecoration(color: Colors.black),
              arrowsDecoration: JoystickArrowsDecoration(color: Color(0xFF05fc05)),
            ),
            stick: JoystickStick(
              decoration: JoystickStickDecoration(color: Color(0xFF05fc05)),
            ),
          ),
        ),
      ],
    );
  }
}
