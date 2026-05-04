# Tayyib — Halal Food Checker (Flutter App)

> **Is it Halal?** Scan, type, or snap a photo — get instant halal verification.

**Tayyib** is a beautiful Flutter mobile app that helps Muslims check if food products are halal according to their madhab.

**Backend API:** [tayyib.io](https://github.com/java-rakhmonaliev/tayyib.io)

---

## Features

- **Barcode Scanner** — Real-time scanning with mobile_scanner
- **Text Analysis** — Paste ingredient lists manually
- **Photo Analysis** — Take a picture of the label (OCR + AI)
- **Madhab Selector** — Switch between Hanafi, Maliki, Shafi'i, Hanbali
- **Beautiful UI** — Modern dark/light theme with smooth animations
- **Offline Auth** — Secure local storage for tokens and user data

---

## Tech Stack

| Layer              | Technology                              |
|--------------------|-----------------------------------------|
| Framework          | Flutter 3.24                            |
| Barcode Scanning   | mobile_scanner ^5.2.3                   |
| HTTP Client        | http ^1.2.2                             |
| Local Storage      | shared_preferences ^2.3.3               |
| Theming            | Custom Space Grotesk + Neo-brutalist    |
| State Management   | ValueNotifier + setState                |
| Platforms          | iOS + Android                           |

---

## Quick Start

### Prerequisites
- Flutter SDK 3.24+
- iOS Simulator / Android Emulator (or physical device)
- Backend running (or use production API)

### Setup

```bash
git clone https://github.com/java-rakhmonaliev/tayyib-app.git
cd tayyib-app

flutter pub get
flutter run
```

The app is pre-configured to use the production backend at `http://13.217.178.63`.

---

## Project Structure

```
tayyib-app/
├── lib/
│   ├── main.dart                    # App entry + theme notifier
│   ├── core/
│   │   └── theme.dart               # Colors, typography, TayyibTheme
│   ├── models/
│   │   ├── user.dart
│   │   └── analysis_result.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── scanner_screen.dart
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── ...
│   ├── services/
│   │   ├── api_service.dart         # analyzeText, analyzeBarcode, analyzeImage
│   │   └── auth_service.dart        # register, login, profile, logout
│   └── widgets/
│       ├── bottom_bar.dart          # Animated tab bar
│       ├── ui_components.dart       # TayyibCard, TayyibButton, etc.
│       └── brutal_button.dart
├── assets/
│   ├── icon.png
│   ├── 1.png
│   └── 2.png
├── pubspec.yaml
└── README.md
```

---

## Key Screens

- **Home** — Quick actions + recent analyses
- **Scanner** — Full-screen barcode scanner with torch toggle
- **Analyze** — Text input + photo upload
- **Profile** — Madhab selector + account settings

---

## How It Works

1. User selects madhab (stored locally + synced to backend)
2. App sends request to backend with `madhab` parameter
3. Backend returns detailed breakdown + overall status
4. Results shown with color-coded verdicts (green = halal, red = haram, orange = questionable)

---

## Building for Release

```bash
# iOS
flutter build ios --release

# Android
flutter build apk --release
flutter build appbundle --release
```

---

## Screenshots

*(Add screenshots here when available)*

---

## Disclaimer

Tayyib is an **assistive tool**, not a religious authority. Always consult a qualified scholar or certified halal body for important dietary decisions.

---

## License

MIT License © 2026 Javokhirbek Rakhmonaliev

---

**Built with Flutter + ❤️ for the Ummah**

*Last updated: May 2026*
