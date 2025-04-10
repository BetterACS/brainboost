# BrainBoost - Clean Architecture Implementation

This project has been refactored to follow Clean Architecture principles with BLoC pattern for state management. This README outlines the key components, structure, and the migration process.

## Architecture Overview

The application follows the Clean Architecture pattern, with a clear separation of concerns:

### Layers

1. **Domain Layer**: Contains business logic and entities.
   - Entities - Core business models
   - Repositories (interfaces) - Abstract definitions of data operations
   - Use Cases - Business logic operations

2. **Data Layer**: Handles data operations and transforms between domain and external data.
   - Data Sources - Remote and local data fetching implementations
   - Models - Data models that map to/from domain entities
   - Repository Implementations - Concrete implementations of domain repositories

3. **Presentation Layer**: UI components and state management.
   - BLoCs - Business Logic Components that handle UI state
   - Pages - Screen UI components
   - Widgets - Reusable UI components

4. **Core Layer**: Cross-cutting concerns and utilities.
   - Network - API client (Dio)
   - Errors - Error handling and failures
   - Utils - General utilities

### Key Patterns

- **Dependency Injection**: Using GetIt for service location.
- **BLoC Pattern**: For state management with clear separation of UI and business logic.
- **Repository Pattern**: For data access abstraction.
- **Use Cases**: Single-responsibility functions for business operations.

## Migration Status

See [MIGRATION.md](./MIGRATION.md) for the current status of the code migration.

## Getting Started

1. Run the app with the new architecture:
   ```bash
   flutter pub get
   flutter run
   ```

## Directory Structure

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
└── MIGRATION.md
```

## Benefits of the New Architecture

- **Testability**: Each layer can be tested independently.
- **Maintainability**: Clear separation of concerns makes the codebase easier to maintain.
- **Scalability**: New features can be added with minimal changes to existing code.
- **Independence of Frameworks**: Business logic is isolated from external frameworks.

## Migration Process

The migration is being done incrementally:

1. Set up the clean architecture directory structure
2. Implement core infrastructure (repositories, BLoCs, etc.)
3. Migrate screens one by one to use the new architecture
4. Replace old services with the new components
5. Add tests

## Dependencies

- **flutter_bloc**: State management
- **get_it**: Dependency injection
- **dartz**: Functional programming
- **equatable**: Value equality
- **dio**: HTTP client




  1. Run the app:
  flutter run
  2. Understanding the structure:
    - Domain Layer (/domain/): Core business logic
    - Data Layer (/data/): Implementation of repositories
    - Presentation Layer (/presentation/): UI components and state management
    - Core (/core/): Shared utilities and functionality
  3. Flow of MyGamesPage:
    - User actions trigger events in GamesBloc
    - Events are processed in the bloc, calling appropriate use cases
    - State changes are emitted and UI responds accordingly
    - All Firebase operations are abstracted behind repositories
  4. Key files to examine:
    - /presentation/pages/games/my_games_page.dart: UI implementation
    - /presentation/bloc/games/games_bloc.dart: State management
    - /domain/entities/game_entity.dart: Core data models
    - /data/models/game_model.dart: Data layer models

  This architecture separates concerns, making testing easier and code more maintainable.
