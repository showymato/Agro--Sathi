# Agro-sathi

A new Flutter project.

## Getting Started
Here’s a comprehensive README file for the AgroHealth project:

---

# AgroHealth IoT Monitoring System

AgroHealth is an Internet of Things (IoT) based system designed to monitor various environmental parameters to enhance agricultural productivity. This system collects real-time data on soil moisture, temperature, humidity, and light intensity, providing farmers with actionable insights to improve crop health and yield.

## Features

- Real-time Monitoring: Collect and visualize data from multiple sensors.
- Notifications: Get alerts for critical conditions directly on your mobile device.
- Web and Mobile Dashboards: Visualize data on a web dashboard (using Flask) and a mobile app (using Flutter).
- Data Logging: Store historical data for trend analysis and decision making.

## Components

### Hardware

- NodeMCU (20 nodes): Microcontroller to collect and send sensor data.
- Sensors:
  - Soil Moisture Sensor: Measures soil moisture level.
  - DHT11 Sensor: Measures temperature and humidity.
  - LDR Sensor: Measures light intensity.

### Software

- NodeMCU Firmware: Arduino code to read sensor data and send it to the server.
- Server: Flask application to receive data and send notifications.
- Mobile App: Flutter application to visualize data and receive alerts.

## Hardware Setup

1. Connect Sensors to NodeMCU:
   - Soil Moisture Sensor: Connect to analog input A0.
   - DHT11 Sensor: Connect data pin to D2.
   - LDR Sensor: Connect to analog input A0.
2. Power the NodeMCU: Use a power source like a USB adapter.

## Software Setup

### 1. NodeMCU Firmware

1. Install Arduino IDE: Download and install from [Arduino](https://www.arduino.cc/en/software).
2. Install NodeMCU Board: Add the NodeMCU board in Arduino IDE.
3. Install Libraries: Install necessary libraries (`DHT`, `ESP8266WiFi`, etc.).
4. Upload Code: Flash the NodeMCU firmware to the device.

### 2. Server (Flask Application)

1. Set Up Virtual Environment**:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows, use `venv\Scripts\activate`
   ```
2. Install Dependencies**:
   ```bash
   pip install Flask flask_cors paho-mqtt
   ```
3. Run Server:
   ```bash
   python app.py
   ```

### 3. Mobile App (Flutter)

1. Set Up Flutter Environment**: Follow [Flutter installation guide](https://flutter.dev/docs/get-started/install).
2. Clone Repository:
   ```bash
   git clone <repo_url>
   cd agrohealth_app
   ```
3. Install Dependencies:
   ```bash
   flutter pub get
   ```
4. Run App:
   ```bash
   flutter run
   ```

## Project Structure

```
agrohealth/
├── NodeMCU/
│   └── nodemcu_firmware.ino
├── Server/
│   ├── app.py
│   ├── requirements.txt
│   └── templates/
│       └── index.html
└── MobileApp/
    ├── lib/
    │   ├── main.dart
    │   ├── services/
    │   │   └── notification_service.dart
    │   ├── models/
    │   │   └── measurement.dart
    │   └── screens/
    │       └── home_screen.dart
    ├── pubspec.yaml
    └── assets/
        └── images/
```

## Usage

1. Start NodeMCU Devices: Power up all NodeMCU devices with connected sensors.
2. Run Server: Start the Flask server to handle incoming data.
3. Open Mobile App: Use the Flutter app to monitor sensor data in real-time.
4. Check Web Dashboard: Optionally, view data and alerts on the web dashboard.

## Contributing

1. Fork the repository.
2. Create a new branch (`git checkout -b feature/your-feature`).
3. Commit your changes (`git commit -am 'Add some feature'`).
4. Push to the branch (`git push origin feature/your-feature`).
5. Create a new Pull Request.
