# vgp_drone_controller

A drone controller that rely on an RPi Pico W as the drone receiver, and ESP32-CAM for the camera.

## Getting Started

The application requires the phone to start the hotspot with a pre-defined SSID and password that the RPi Pico W and ESP32-CAM can connect to. It'll wait for connection from both devices before proceeding to the control page.

### 1. Clone the repo
```
git clone https://github.com/yourusername/vgp_drone_controller.git
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

The application will respond to the UDP broadcast from both the RPi Pico W and ESP32-CAM by sending the acknowledge message. The ESP32-CAM will provide the video stream, while the application will send the four AETR values to the RPi Pico W with the range between 1000 and 2000. This data is packed in two bytes per channel with little endian system.


