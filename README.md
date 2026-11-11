# vgp_drone_controller

A drone controller that rely on an RPi Pico W as the drone receiver, and ESP32-CAM for the camera.

## Getting Started

The application requires the phone to start the hotspot with a pre-defined SSID and password that the RPi Pico W and ESP32-CAM can connect to. It'll wait for connection from both devices before proceeding to the control page.

### 1. Clone the repo
```
git clone https://github.com/valGavin/vgp_drone_controller.git
cd vgp_drone_controller
```
### 2. AndroidManifest.xml Configuration
Location: android/app/src/main/AndroidManifest.xml
```
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

## How It Works?

The application will respond to the UDP broadcast from both the RPi Pico W and ESP32-CAM by sending the acknowledge message. The ESP32-CAM will provide the video stream, while the application will send the four AETR values and the ARM channel (AUX1) to the RPi Pico W. Roll, pitch and yaw range between 1000 and 2000; throttle ranges between 850 and 2000; AUX1 is 1200 when disarmed and 1500 when armed. This data is packed in two bytes per channel with little endian system.

The control packet is sent every 20 ms whether or not a stick is moving. The RPi Pico W treats 500 ms without a packet as a lost link and stops driving the flight controller, so this stream doubles as the link heartbeat.

The drone is disarmed, with throttle returned to idle, when the ARM switch is turned off, when Quit is pressed, and when the application leaves the foreground.

## Tests

```
flutter test
```

Part of [vGP-Drone](https://github.com/valGavin/vGP-Drone), which holds the project documentation.
