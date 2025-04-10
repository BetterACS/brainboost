# BrainBoost - Clean Architecture with BLoC

## Project Architecture

This project follows Clean Architecture principles with BLoC pattern for state management and Dio for network requests. The architecture is organized into layers:

### 1. Core Layer
- **Constants**: App-wide constants
- **Errors**: Failure and exception handling
- **Network**: Dio client configuration
- **Utils**: Utility classes

### 2. Data Layer
- **DataSources**: Data retrieval and storage
  - **Remote**: Firebase and API implementations
  - **Local**: Local storage implementations
- **Models**: Converts data to entities
- **Repositories**: Implementation of domain repositories

### 3. Domain Layer
- **Entities**: Business objects
- **Repositories**: Abstract interfaces
- **UseCases**: Business logic

### 4. Presentation Layer
- **BLoC**: State management
- **Pages**: Screen UI
- **Widgets**: Reusable components

## Key Components

### BLoC Pattern
State management using BLoC (Business Logic Component) pattern with:
- **Events**: Triggers for state changes
- **States**: Different UI states
- **BLoCs**: Business logic that converts events to states

### Dependency Injection
Using GetIt as service locator for dependency injection.

### Network Layer
Using Dio client for API requests with:
- Interceptors for logging
- Error handling
- Request/response formatting

### Firebase Integration
Firebase services are abstracted behind repository interfaces to maintain the clean architecture principles.

## Project Structure
```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   │   └── dio_client.dart
│   └── utils/
├── data/
│   ├── datasources/
│   │   ├── remote/
│   │   └── local/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── bloc/
│   ├── pages/
│   └── widgets/
├── main.dart
```

## Getting Started

1. Run `flutter pub get` to install dependencies
2. Run `flutter run` to start the application

## Dependencies

- **flutter_bloc**: BLoC pattern implementation
- **get_it**: Dependency injection
- **dio**: HTTP client 
- **dartz**: Functional programming
- **equatable**: Value equality