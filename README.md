# Livo - Social Media App

**Livo** adalah aplikasi sosial media berbasis Android (Flutter) yang memungkinkan pengguna untuk berbagi konten dan terhubung dengan orang lain secara real-time.

## 📱 Fitur Utama

- **🔐 Autentikasi** - Signup email & Google, Login, Reset password
- **📸 Posting Konten** - Upload foto dan video pendek (<15 detik) dengan caption
- **👥 Sosial** - Follow/unfollow, Like & comment pada post
- **💬 Chat Real-time** - Pesan 1-on-1 dengan notifikasi push
- **🔍 Pencarian** - Temukan pengguna lain berdasarkan username
- **🔔 Notifikasi** - Update real-time untuk likes, comments, followers, dan messages
- **🛡️ Moderasi** - Report post dan block user

## 🛠️ Tech Stack

### Frontend (Flutter)
- **Framework**: Flutter 3.24+
- **State Management**: Riverpod
- **Routing**: GoRouter
- **HTTP Client**: Dio
- **Local Storage**: Hive / SharedPreferences
- **Real-time**: Supabase Realtime
- **Push Notifications**: Firebase Messaging

### Backend
- **BaaS**: Supabase
  - Supabase Auth untuk autentikasi
  - PostgreSQL database
  - Supabase Storage untuk media files
  - Supabase Realtime untuk fitur live
  - Row Level Security (RLS) untuk proteksi data

## 📋 Persyaratan Sistem

- **Android**: Minimum SDK 21 (Android 5.0)
- **Flutter**: 3.24 atau lebih tinggi
- **Memory**: Minimum 2GB RAM
- **Storage**: 100MB+ untuk aplikasi

## 🚀 Memulai Pengembangan

### Prerequisites
Pastikan Anda telah menginstall:
- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.24+
- [Android Studio](https://developer.android.com/studio) atau VS Code dengan Flutter extension
- Android SDK dengan Android Virtual Device (AVD)

### Instalasi

1. **Clone repository**
   ```bash
   git clone <repository-url>
   cd livoapp
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup environment**
   ```bash
   # Copy file environment template
   cp lib/core/config/.env.example lib/core/config/.env

   # Edit .env file dengan konfigurasi Supabase dan Firebase Anda
   ```

4. **Run aplikasi**
   ```bash
   # Run di Android device/emulator
   flutter run

   # Atau spesifik platform
   flutter run -d android
   flutter run -d chrome  # Untuk web development
   ```

### Development Commands

```bash
# Install dependencies
flutter pub get

# Run di debug mode
flutter run

# Build untuk release
flutter build apk          # Android APK
flutter build appbundle     # Android App Bundle (Play Store)

# Run tests
flutter test

# Code analysis
flutter analyze

# Check Flutter environment
flutter doctor
```

## 📁 Struktur Project

```
lib/
├── core/
│   ├── config/          # Konfigurasi app dan environment
│   ├── exceptions/      # Custom exceptions
│   ├── utils/          # Utility functions
│   └── widgets/        # Reusable UI components
├── features/
│   ├── auth/           # Autentikasi (login, signup, profile)
│   ├── post/           # Posting konten
│   ├── feed/           # Feed dan timeline
│   ├── chat/           # Real-time messaging
│   ├── search/         # Pencarian pengguna
│   └── notifications/  # Notifikasi system
├── services/           # External services (Supabase, FCM)
└── main.dart          # Entry point aplikasi
```

## 🗄️ Database Schema

Aplikasi menggunakan PostgreSQL melalui Supabase dengan tabel utama:

- **users** - Profile pengguna
- **posts** - Konten yang dibagikan
- **post_media** - File media (foto/video)
- **followers** - Relasi follow
- **likes** - Likes pada post
- **comments** - Komentar
- **chats** - Room chat
- **messages** - Pesan chat
- **reports** - Laporan konten
- **blocked_users** - Daftar blokir

## 🔐 Keamanan

- **Row Level Security (RLS)** untuk proteksi data di database
- **Enkripsi** data transit dengan HTTPS
- **Autentikasi** via Supabase Auth
- **Validasi input** di client dan server side
- **Content moderation** dengan report dan block system

## 📱 Platform Support

- **Android**: Full support (Primary platform)
- **iOS**: Future scope
- **Web**: Development support
- **Windows**: Future scope

## 🧪 Testing

```bash
# Run semua tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run dengan coverage
flutter test --coverage
```

## 📦 Build & Deployment

### Android Development
```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# App Bundle untuk Play Store
flutter build appbundle --release
```

### Environment Setup
Pastikan untuk mengkonfigurasi:
- Supabase project URL dan anon key
- Firebase Cloud Messaging (FCM) configuration
- Environment variables di `lib/core/config/.env`

## 🤝 Kontribusi

1. Fork repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push ke branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

Project ini dilisensikan under MIT License - lihat [LICENSE](LICENSE) file untuk details.

## 📞 Support

Untuk bantuan teknis atau pertanyaan:
- WhatsApp: +62 812-3456-7890
- Email: livoapp@example.com
- Documentation: Lihat `CLAUDE.md` untuk technical documentation

---

**MVP Focus**: Kesederhanaan, kecepatan, real-time features, dan basic user engagement.
