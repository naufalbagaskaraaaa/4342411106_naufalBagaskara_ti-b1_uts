# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

E-Ticketing Helpdesk is a Flutter application for IT support ticket management. The app allows users to submit support tickets, administrators to assign tickets, and helpdesk staff to resolve issues.

**Current Tech Stack:**
- Frontend: Flutter (Dart SDK ^3.11.0)
- State Management: None yet (planned: Riverpod)
- Backend: None yet (planned: Supabase)
- Current Data: Local dummy data only

## Architecture Note

**Current State:** The app currently uses basic Flutter structure without Clean Architecture. Models, screens, and widgets are organized in folders but lack proper separation of concerns.

**Target Architecture:** Clean Architecture with three layers per feature:
- `domain/`: Entities, use cases, and repository interfaces
- `data/`: Data sources, repository implementations, and models
- `presentation/`: UI components, state management (Riverpod providers)

## Development Commands

### Running the App
```bash
flutter run                    # Run in debug mode
flutter run --release          # Run in release mode
flutter run --profile          # Run with performance profiling
```

### Building APK
```bash
flutter build apk --release    # Build release APK
flutter build apk --debug      # Build debug APK

# APK output location: build/app/outputs/flutter-apk/
```

### Code Quality
```bash
flutter analyze                # Static analysis
flutter test                   # Run all tests
flutter test test/widget_test.dart  # Run specific test file
```

### Dependencies
```bash
flutter pub get               # Install dependencies
flutter pub upgrade           # Upgrade dependencies
flutter pub outdated          # Check for outdated packages
```

## Project Structure

### Key Directories
- `lib/models/`: Data models (UserModel, TiketModel, KomentarModel)
- `lib/screens/`: UI screens organized by feature (auth, dashboard, tiket, profile)
- `lib/widgets/`: Reusable UI components
- `lib/core/`: Constants, theme, and utilities
- `lib/core/dummy/`: Dummy data for development testing

### Current Models
- **UserModel**: User entities with roles (user, admin, helpdesk)
- **TiketModel**: Support tickets with status workflow (open → inProgress → resolved → closed)
- **KomentarModel**: Comments/updates on tickets

### Key Screens
- **Authentication**: Login, Register, Reset Password
- **Main Navigation**: MainScreen (dashboard, tickets, profile)
- **Ticket Management**: ListTiketScreen, CreateTiketScreen, DetailTiketScreen
- **Dashboard**: Role-based dashboard screen
- **Profile**: User profile management

## Important Patterns

### Status Workflow (Critical Business Logic)
Ticket status follows strict automated transitions:
1. User creates ticket → status: `open`
2. Admin accepts ticket → status: `assign` 
3. Admin assigns to helpdesk → status: `in_progress`
4. Helpdesk clicks "Selesai/Finish" → status: `close`

**Important:** Do not implement manual status change dropdowns/inputs. Status changes must be triggered by specific actions only.

### Role-Based Access
Three user roles with different permissions:
- **user**: Can create tickets, view own tickets
- **admin**: Can assign tickets to helpdesk, view all tickets
- **helpdesk**: Can process assigned tickets, add comments, mark as complete

### Theme Management
App uses `ThemeNotifier` for dark/light mode switching:
- File: `lib/core/theme/theme_notifier.dart`
- Supports dynamic theme switching via `ValueListenableBuilder<ThemeMode>`

### Current Data Layer
All data currently served from `lib/core/dummy/dummy_data.dart`. No backend integration yet.

## Build Configuration

### Android Release Build
- Uses ProGuard for code minification and obfuscation
- Configured in `android/app/build.gradle.kts`
- ProGuard rules: `android/app/proguard-rules.pro`
- Release builds are signed with debug keys (update for production)

### APK Output
Release APK location: `build/app/outputs/flutter-apk/app-release.apk`

## Migration Notes

**When implementing Clean Architecture with Riverpod + Supabase:**
1. Create proper domain/data/presentation layers per feature
2. Migrate dummy data to Supabase database
3. Replace direct model usage with repository pattern
4. Implement Riverpod providers for state management
5. Maintain the automated status workflow logic during migration
6. Ensure role-based access control is enforced in backend logic

## Testing

Current test coverage: Basic widget test (`test/widget_test.dart`)

When adding tests:
- Unit tests for business logic in domain layer
- Widget tests for UI components
- Integration tests for user flows (ticket creation, status changes)