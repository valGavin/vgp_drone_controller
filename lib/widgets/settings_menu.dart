import 'package:flutter/material.dart';
import 'dart:io';

class SettingsMenu extends StatefulWidget {
  final VoidCallback onReloadCamera, onToggleArm;
  final bool isArmed;

  const SettingsMenu({
    super.key,
    required this.onReloadCamera,
    required this.onToggleArm,
    required this.isArmed,
  });

  @override
  State<SettingsMenu> createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {
  bool showMenu = false;
  double rotation = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 20,
          left: 20,
          child: GestureDetector(
            onTap: () {
              setState(() {
                showMenu = !showMenu;
                rotation += 45;
              });
            },
            child: AnimatedRotation(
              turns: rotation / 360,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.settings, color: Colors.white, size: 32),
              ),
            ),
          ),
        ),
        if (showMenu)
          Positioned.fill(
            child: GestureDetector(
              onTap: () { setState(() { showMenu = false; }); },
              child: Container(
                color: Colors.black54,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    margin: const EdgeInsets.only(top: 70, left: 20),
                    padding: const EdgeInsets.all(8),
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: const Text(
                            'Reload Camera',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            widget.onReloadCamera();
                            setState(() { showMenu = false; });
                          },
                        ),
                        ListTile(
                          title: const Text(
                            'Quit',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () { exit(0); },
                        ),
                        ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'ARM',
                                style: TextStyle(color: Colors.white),
                              ),
                              Switch(
                                value: widget.isArmed,
                                onChanged: (_) {
                                  widget.onToggleArm();
                                  setState(() => showMenu = false);
                                },
                                activeColor: Colors.greenAccent,
                                inactiveThumbColor: Colors.redAccent,
                              ),
                            ],
                          ),
                          onTap: () {
                            widget.onToggleArm;
                            setState(() => showMenu = false);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
