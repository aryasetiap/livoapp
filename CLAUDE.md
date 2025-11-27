# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Livo** is an Android social media application built with Flutter that allows users to:
- Create accounts with email/Google authentication
- Upload photos and short videos (<15 seconds)
- View chronological feed from followed users
- Like and comment on posts
- Follow/unfollow other users
- Send real-time 1-on-1 chat messages
- Receive push notifications

MVP focuses on **simplicity**, **speed**, **real-time features**, and **basic user engagement**.

## Tech Stack

### Frontend (Flutter)
- **Framework:** Flutter 3.24+
- **State management:** Riverpod (preferred) or BLoC
- **Routing:** GoRouter
- **HTTP:** Dio
- **Local storage:** Hive / SharedPreferences
- **Image/video picker:** `image_picker`
- **Video player:** `video_player`
- **Background upload:** `flutter_uploader` / isolate
- **Real-time:** Supabase Realtime client
- **Push notif:** Firebase Messaging

### Backend
- **Supabase** (primary backend):
  - Supabase Auth for authentication
  - PostgreSQL database
  - Supabase Storage for media files
  - Supabase Realtime for chat and feed notifications
  - Row Level Security (RLS) policies

## Common Development Commands

### Running the Application
- `flutter run` - Run the app in debug mode (connects to available device/emulator)
- `flutter run -d chrome` - Run the app on Chrome web browser
- `flutter run -d android` - Run the app on Android device/emulator

### Building the Application
- `flutter build apk` - Build Android APK
- `flutter build appbundle` - Build Android App Bundle (for Play Store)
- `flutter build web` - Build web application
- `flutter build windows` - Build Windows desktop application

### Development Tools
- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Upgrade dependencies to latest versions
- `flutter pub outdated` - Check for outdated dependencies
- `flutter analyze` - Run static analysis on the code
- `flutter test` - Run all tests
- `flutter doctor` - Check Flutter environment setup

### Hot Reload & Hot Restart
- During `flutter run`, press `r` for hot reload (preserves app state)
- Press `R` for hot restart (resets app state)
- In IDEs, use the hot reload button or save files to trigger hot reload

## Project Architecture

### State Management
- Uses **Riverpod** for state management (recommended)
- Provider naming convention: `xxxProvider`
- Repository pattern: `xxxRepository`
- Service layer: `xxxService`
- View controllers: `xxxController`

### Directory Structure
```
/lib
    /core
        /config
        /exceptions
        /utils
        /widgets
    /features
        /auth
            /data
            /domain
            /presentation
        /profile
        /post
        /feed
        /chat
        /search
        /notifications
    /services
        supabase_client.dart
        fcm_service.dart
    main.dart
```

## Core Features

### Authentication
- Email and Google sign-up
- Login/logout functionality
- Password reset
- Session management via Supabase Auth

### Posts & Media
- Upload photos (jpg/png) and videos (<15 seconds)
- Max resolution: 1080p
- Captions: max 300 characters
- Background upload support
- Media compression on client side

### Social Features
- Follow/unfollow users
- Like/unlike posts
- Comment system
- Real-time feed from followed users
- Search users by username (case-insensitive)

### Chat System
- Real-time 1-on-1 text chat
- Chat list with last message preview
- Seen/unseen message status
- Push notifications for new messages
- Emoji support

### Notifications
- Real-time in-app notifications (Supabase)
- Push notifications (FCM):
  - New message alerts
  - New follower notifications
  - Like and comment notifications

## Data Models

### Core Tables
- **users** - User profiles with username, email, bio, avatar
- **posts** - Post content with captions
- **post_media** - Media files (photos/videos) with metadata
- **followers** - Follow relationships
- **likes** - Post likes
- **comments** - Post comments
- **chats** - Chat rooms between users
- **messages** - Individual chat messages
- **reports** - Content moderation reports
- **blocked_users** - User blocking functionality

## API Integration (Supabase)

### Authentication
- `supabase.auth.signInWithPassword()`
- `supabase.auth.signUp()`
- `supabase.auth.signOut()`

### Database Operations
- Standard CRUD operations through Supabase client
- Realtime subscriptions for live updates
- Row Level Security (RLS) for data protection

### Storage
- Media uploads to Supabase Storage bucket `posts/`
- Automatic thumbnail generation for videos
- CDN delivery for optimized performance

## Security & Rules

### Row Level Security (RLS)
- Users can only access their own data
- Chat messages visible only to participants
- Post visibility controlled by follow relationships
- Blocked users cannot interact

### Content Rules
- Max video length: 15 seconds
- Max resolution: 1080p
- Caption limit: 300 characters
- Text-only chat messages (emoji allowed)

## Development Guidelines

### Naming Conventions
- **Providers**: `xxxProvider` (Riverpod)
- **Repositories**: `xxxRepository`
- **Services**: `xxxService`
- **View Controllers**: `xxxController`

### Code Organization
- Feature-based folder structure
- Separate data, domain, and presentation layers
- Reusable UI components in `/core/widgets`
- Centralized service configuration in `/services`

### Testing Strategy
- Unit tests for business logic
- Widget tests for UI components
- Integration tests for user flows

### Performance Considerations
- Background media uploads
- Image/video compression
- Efficient pagination for feeds
- Optimized database queries
- Proper state management to prevent rebuilds

## Target Platform
- **Primary**: Android (min SDK 21)
- **Secondary**: iOS, Web, Windows (future scope)
- **Tablet Support**: Optional for MVP