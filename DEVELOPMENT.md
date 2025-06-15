# NASA Daily Snapshot - Development Guide

## Getting Started

### Prerequisites
- Flutter SDK (>=2.17.0 <3.0.0)
- Dart SDK
- IDE (VS Code, Android Studio, or IntelliJ)
- NASA API Key (get one at https://api.nasa.gov/)

### Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd nasadaily
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API Key**
   - Open `lib/services/api_service.dart`
   - Replace the `_apiKey` constant with your NASA API key
   ```dart
   static const String _apiKey = 'YOUR_API_KEY_HERE';
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

## Project Dependencies

### Core Dependencies
- **flutter**: Flutter SDK
- **http**: HTTP client for API calls
- **shared_preferences**: Local data persistence
- **provider**: State management
- **cached_network_image**: Image caching and loading
- **intl**: Internationalization and date formatting
- **url_launcher**: Launch external URLs

### Development Dependencies
- **flutter_test**: Testing framework
- **flutter_lints**: Code linting rules

## Code Organization

### Import Strategy
Use barrel exports for clean imports:

```dart
// ✅ Recommended
import 'package:nasa_daily_snapshot/core/index.dart';
import 'package:nasa_daily_snapshot/models/index.dart';
import 'package:nasa_daily_snapshot/providers/index.dart';

// ❌ Avoid
import 'package:nasa_daily_snapshot/core/error_handler.dart';
import 'package:nasa_daily_snapshot/models/apod_model.dart';
```

### File Naming Conventions
- **Screens**: `*_screen.dart` (e.g., `home_screen.dart`)
- **Widgets**: `*.dart` (e.g., `apod_card.dart`)
- **Models**: `*_model.dart` (e.g., `apod_model.dart`)
- **Providers**: `*_provider.dart` (e.g., `apod_provider.dart`)
- **Services**: `*_service.dart` (e.g., `api_service.dart`)
- **Utils**: `*.dart` (e.g., `extensions.dart`)

## Development Workflow

### 1. Adding New Features

#### Step 1: Define the Model (if needed)
```dart
// lib/models/new_model.dart
class NewModel {
  final String id;
  final String title;
  
  NewModel({required this.id, required this.title});
  
  factory NewModel.fromJson(Map<String, dynamic> json) {
    return NewModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
    );
  }
}
```

#### Step 2: Create/Update Service
```dart
// lib/services/new_service.dart
class NewService {
  Future<NewModel> fetchData() async {
    // Implementation
  }
}
```

#### Step 3: Create/Update Provider
```dart
// lib/providers/new_provider.dart
class NewProvider extends ChangeNotifier {
  NewModel? _data;
  bool _isLoading = false;
  
  NewModel? get data => _data;
  bool get isLoading => _isLoading;
  
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _data = await NewService().fetchData();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

#### Step 4: Create UI Components
```dart
// lib/widgets/new_widget.dart
class NewWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<NewProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return LoadingIndicator();
        }
        
        return YourWidget();
      },
    );
  }
}
```

#### Step 5: Update Barrel Exports
Add new exports to appropriate `index.dart` files.

### 2. Error Handling

Always use the centralized error handling:

```dart
try {
  // Your code
} catch (e) {
  final appException = ErrorHandler.handleError(e);
  final userMessage = ErrorHandler.getUserMessage(appException);
  // Show user message
}
```

### 3. Responsive Design

Use responsive utilities:

```dart
// Get responsive values
final padding = ResponsiveUtils.getPadding(context);
final fontSize = ResponsiveUtils.getFontSize(context, FontSizeType.body);

// Use responsive widgets
ResponsiveWidget(
  mobile: MobileLayout(),
  tablet: TabletLayout(),
  desktop: DesktopLayout(),
)
```

### 4. Theming

Access theme values:

```dart
// Using extensions
final primaryColor = context.primaryColor;
final textTheme = context.textTheme;

// Direct access
final theme = Theme.of(context);
final colorScheme = theme.colorScheme;
```

## Testing Guidelines

### Unit Tests
```dart
// test/models/apod_model_test.dart
void main() {
  group('ApodModel', () {
    test('should create from JSON', () {
      final json = {'title': 'Test', 'date': '2023-01-01'};
      final model = ApodModel.fromJson(json);
      expect(model.title, 'Test');
    });
  });
}
```

### Widget Tests
```dart
// test/widgets/apod_card_test.dart
void main() {
  testWidgets('ApodCard displays title', (tester) async {
    final apod = ApodModel(title: 'Test Title');
    
    await tester.pumpWidget(
      MaterialApp(
        home: ApodCard(apod: apod),
      ),
    );
    
    expect(find.text('Test Title'), findsOneWidget);
  });
}
```

## Performance Best Practices

### 1. Image Loading
- Use `CachedNetworkImage` for remote images
- Implement proper error handling and placeholders
- Use appropriate image sizes

### 2. State Management
- Use `Consumer` widgets for targeted rebuilds
- Avoid unnecessary `notifyListeners()` calls
- Use `Selector` for specific property listening

### 3. API Calls
- Implement caching for frequently accessed data
- Use pagination for large datasets
- Handle rate limiting gracefully

### 4. Memory Management
- Dispose controllers and streams properly
- Use `const` constructors where possible
- Avoid memory leaks in providers

## Debugging Tips

### 1. Logging
Use the centralized logger:

```dart
AppLogger.info('User action performed');
AppLogger.error('Error occurred', error: e, stackTrace: stackTrace);
AppLogger.debug('Debug information');
```

### 2. Provider Debugging
```dart
// Enable provider debugging
Provider.debugCheckInvalidValueType = null;
```

### 3. Network Debugging
- Check API responses in debug console
- Verify API key configuration
- Test with different network conditions

## Code Quality

### Linting
Run linting checks:
```bash
flutter analyze
```

### Formatting
Format code:
```bash
flutter format .
```

### Pre-commit Checklist
- [ ] Code is properly formatted
- [ ] No linting errors
- [ ] Tests pass
- [ ] Documentation updated
- [ ] Barrel exports updated

## Common Issues and Solutions

### 1. API Rate Limiting
- Implement exponential backoff
- Use caching to reduce API calls
- Consider upgrading API key limits

### 2. Image Loading Issues
- Check network connectivity
- Verify image URLs
- Implement proper error handling

### 3. State Management Issues
- Ensure providers are properly registered
- Check for memory leaks
- Verify notifyListeners() usage

### 4. Build Issues
- Clean build: `flutter clean && flutter pub get`
- Check dependency versions
- Verify platform-specific configurations

## Contributing

1. Follow the established code organization
2. Write tests for new features
3. Update documentation
4. Use meaningful commit messages
5. Create pull requests with clear descriptions

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [NASA API Documentation](https://api.nasa.gov/)
- [Material Design Guidelines](https://material.io/design)