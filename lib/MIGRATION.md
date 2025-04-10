# Clean Architecture Migration Status

This file tracks the migration of screens and services to the new Clean Architecture with BLoC pattern.

## Migrated Components

### Screens
- [x] WelcomePage -> presentation/pages/auth/welcome_page.dart
- [x] LoginPage -> presentation/pages/auth/login_page.dart
- [x] SignupPage -> presentation/pages/auth/signup_page.dart
- [x] ProfilePage -> presentation/pages/profile/profile_page.dart
- [x] EditProfilePage -> presentation/pages/profile/edit_profile_page.dart
- [x] HomePage -> presentation/pages/home/home_page.dart

### BLoCs
- [x] AuthBloc
- [x] ProfileBloc
- [x] GamesBloc
- [x] HomeBloc

### Services
- [ ] AuthService -> Will be fully replaced by AuthBloc, UserRepository, and AuthRepository
- [ ] UserServices -> Will be fully replaced by ProfileBloc and UserRepository
- [ ] GameServices -> Will be fully replaced by GamesBloc and GameRepository
- [ ] HistoryService -> Will be fully replaced by HistoryBloc and HistoryRepository

## Pending Migration

### Screens
- [ ] History
- [ ] MyGames (Games List)
- [ ] Game Screens (Quiz, YesNo, Bingo)
- [ ] Results
- [ ] Settings

### Other Components
- [ ] Update Firebase Auth Provider
- [ ] Add Loading Screens
- [ ] Handle Error States
- [ ] Add Unit Tests