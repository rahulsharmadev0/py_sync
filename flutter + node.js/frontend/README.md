# PiSync - Admin Panel

A clean, minimalist Flutter web application for managing and synchronizing Raspberry Pi devices.

## Project Overview

PiSync is a responsive Flutter application designed with a clean, monochromatic aesthetic. The application features a comprehensive device management system with authentication, real-time sync status, and error logging.

## Design Principles

- **Clean, Minimalist UI**: Black and white color scheme with strategic color accents
- **Responsive Layout**: Adapts to different screen sizes using Wrap widgets
- **Performance Optimized**: Following Flutter web best practices for loading speed

## Project Structure

```
lib/
  ├── app/           # App configuration and initialization
  │   ├── bootstrap.dart    # App startup configuration
  │   ├── app.dart          # Main app widget
  │   ├── theme.dart        # App theme configuration
  │   └── routes/           # Navigation and routing
  │
  ├── logic/         # Business logic layer
  │   ├── apis/            # API clients for backend communication
  │   ├── models/          # Data models
  │   ├── repositories/    # Repository implementations
  │   └── utils/           # Utility classes and mixins
  │
  ├── ui/            # User interface components
  |   └── screens/         # Application screens
  |       ├── auth/        # Authentication screens
  |       ├── dashboard/   # Dashboard views
  |       └── errors_log_screen.dart
  |
  └──main.dart  # root of project
```

## Architecture Overview

### Repository Pattern

The application uses a repository pattern to abstract data sources and handle caching:

1. **Repositories** (`AuthRepository`, `DevicesRepository`)

   - Extend `CachedState` for persistent state management
   - Mix in `ErrorHandlingAndRetryMixin` for error handling and retry logic
   - Provide a clean API for the UI layer

2. **Implementation Flow**:

   ```
   UI Layer (BLoC) -> Repository -> API Client -> Backend Server
   ```

3. **State Management**:
   - Repositories use HydratedBloc for persisting state
   - Cache expiration and refresh mechanisms
   - Retry logic for handling network failures

Example from `DevicesRepositoryImpl`:

```dart
@override
FutureOr<List<Device>> getAllDevices() async {
  // Check auth status
  var jwtToken = AuthRepository.currentUser?.jwtToken;
  if (jwtToken == null) {
    throw Exception('User is not logged in');
  }

  return handleErrorsAndRetry(() async {
    // Call API and process response
    final response = await devicesApi.getAllDevices(jwtToken);
    List<Device> devices = [];
    // Transform response to model objects
    // ...
    // Update local cache
    emit(devices);
    return devices;
  });
}
```

### BLoC Pattern Implementation

The application uses the BLoC (Business Logic Component) pattern for state management:

1. **Events**: Simple, immutable objects that represent user actions or system events

   - Example: `RefreshDeviceEvent`, `LoadPageEvent`, `SyncSingleDeviceEvent`

2. **State**: Immutable objects representing UI state

   - Example: `DeviceState` with status, devices list, pagination info

3. **BLoC**: Handles events, updates state, and communicates with repositories
   - Example: `DeviceBloc` processes sync requests and refreshes

Example BLoC event handler:

```dart
Future<void> _handleSyncDevice(
  SyncSingleDeviceEvent event,
  Emitter<DeviceState> emit,
) async {
  // Update device status to syncing
  emit(updatedState);

  try {
    // Call repository
    var device = await devicesRepos.syncDeviceById(event.deviceId);
    // Update state with success
    emit(successState);
  } catch (e) {
    // Handle error and update state
    emit(errorState);
  }
}
```

### API Integration

The API layer handles communication with the backend:

1. **API Clients** (`AuthApi`, `DevicesApi`)

   - Encapsulate HTTP requests and response parsing
   - Handle authentication headers
   - Convert between JSON and model objects

2. **Endpoints**:

   - Authentication: `/pisync/auth/login`, `/pisync/auth/register`
   - Devices: `/pisync/devices`, `/pisync/devices/:id`

3. **Pagination and Filtering**:
   ```dart
   Future<Map<String, dynamic>> getAllDevices(
     String token, {
     int page = 1,
     int limit = 10,
     String? syncStatusCode,
     String? sortBy,
     String? order,
   }) async {
     // Build query parameters
     final queryParams = <String, String>{};
     // Add pagination and filters
     // Make HTTP request
     // Parse response
   }
   ```

## UI Layer

The UI is built with responsive design in mind:

1. **Adaptive Layout**:

   - Uses Wrap widgets for responsive content
   - Adapts to different screen sizes with conditional layouts
   - Consistent spacing and alignment

2. **State Consumption**:
   - Uses BlocBuilder for reactive UI updates
   - Uses BlocListener for side effects (like showing error messages)

Example adaptive layout from `DashboardScreen`:

```dart
width > 800
  ? Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: children,
    )
  : Column(children: children)
```

## Getting Started

1. Clone the repository
2. Install dependencies:
   ```
   flutter pub get
   ```
3. Run the application:
   ```
   flutter run -d chrome
   ```

## Best Practices Followed

- **Clean Architecture**: Separation of concerns with logic/UI layers
- **State Management**: BLoC pattern for predictable state flow
- **Error Handling**: Centralized error processing with retry mechanisms
- **Responsive Design**: Adaptive layouts using Wrap and conditional widgets
- **Performance**: Following Flutter web performance best practices
