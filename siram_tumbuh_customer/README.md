# Siram Tumbuh - Customer App

Flutter B2C mobile application untuk customers yang ingin memesan jasa pembuatan dan perawatan taman.

## 📋 Features

- **Authentication**: Login, Register, Profile Management
- **Browse Services**: Browse jasa pembuatan & perawatan taman dengan filter
- **Booking System**: Pesan jasa, pilih tanggal & lokasi, pembayaran
- **Project Tracking**: Monitor progress proyek dengan real-time updates
- **Progress Photos**: Lihat foto progress dari contractor
- **Notifications**: Push notifications untuk status updates
- **Review & Rating**: Rate dan review jasa yang sudah selesai
- **Payment Integration**: Terintegrasi dengan payment gateway

## 🛠️ Tech Stack

- **Framework**: Flutter 3.9+
- **Language**: Dart
- **State Management**: Riverpod
- **Navigation**: Go Router
- **HTTP Client**: Dio
- **Local Storage**: SharedPreferences, Hive
- **UI Components**: Material 3, Google Fonts
- **API**: RESTful API dengan CodeIgniter 4 Backend

## 📁 Project Structure

```
lib/
├── main.dart                 # Entry point
├── config/
│   ├── routes/              # Navigation & routing
│   │   └── app_router.dart  # GoRouter configuration
│   └── theme/               # UI Theme
│       └── app_theme.dart   # Material 3 Theme
├── core/
│   ├── constants/           # App-wide constants
│   │   └── app_constants.dart
│   ├── errors/              # Error handling
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   └── utils/               # Utilities & extensions
├── features/                # Feature modules (Clean Architecture)
│   ├── auth/               # Authentication feature
│   │   ├── presentation/   # UI Screens & Widgets
│   │   └── data/           # API calls & data layer
│   ├── home/               # Home dashboard
│   │   ├── presentation/
│   │   └── data/
│   ├── services/           # Browse & search services
│   │   ├── presentation/
│   │   └── data/
│   ├── booking/            # Booking & checkout
│   │   ├── presentation/
│   │   └── data/
│   └── projects/           # My projects & progress tracking
│       ├── presentation/
│       └── data/
├── services/               # Shared services
│   ├── api_client.dart     # HTTP client (Dio)
│   └── models.dart         # Shared data models
└── widgets/                # Reusable widgets
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.9+
- Dart SDK 3.0+
- Android SDK / Xcode (untuk native development)

### Installation

1. **Get dependencies**
   ```bash
   flutter pub get
   ```

2. **Generate code (if needed)**
   ```bash
   flutter pub run build_runner build
   ```

3. **Run app**
   ```bash
   flutter run
   ```

### Environment Configuration

Update `lib/core/constants/app_constants.dart` dengan backend URL:

```dart
static const String baseUrl = 'http://your-backend-url/api';
```

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| flutter_riverpod | State Management |
| go_router | Navigation |
| dio | HTTP Client |
| google_fonts | Typography |
| cached_network_image | Image Caching |
| intl | Localization |

## 🏗️ Architecture

Menggunakan **Clean Architecture** dengan 3 layers:
- **Presentation**: UI screens & widgets
- **Data**: Repositories & API calls
- **Domain**: Business logic & entities

## 🎨 Design System

- **Primary Color**: Green (#2ECC71)
- **Secondary Color**: Blue (#3498DB)
- **Accent Color**: Orange (#F39C12)
- **Font**: Poppins (via Google Fonts)
- **Component Design**: Material 3

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web (experimental)

## 📝 Development Guidelines

- Follow Dart style guide
- Use meaningful variable names
- Add documentation comments
- Implement features in dedicated feature folders

## 🐛 Troubleshooting

- Clear cache: `flutter clean`
- Get dependencies: `flutter pub get`
- Run builder: `flutter pub run build_runner build --delete-conflicting-outputs`

## 📚 Resources

- [Flutter Documentation](https://flutter.dev)
- [Riverpod Documentation](https://riverpod.dev)
- [GoRouter Documentation](https://pub.dev/packages/go_router)

## 📄 License

MIT License
