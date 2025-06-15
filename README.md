# NASA Daily Snapshot 🚀

A beautiful Flutter application that displays NASA's Astronomy Picture of the Day (APOD) with a modern, space-themed interface.

## Features ✨

- **Daily APOD**: View NASA's Astronomy Picture of the Day
- **Search & Browse**: Search through historical APOD entries
- **Favorites**: Save your favorite space images and videos
- **Responsive Design**: Optimized for mobile, tablet, and desktop
- **Dark/Light Theme**: Beautiful space-themed UI with theme switching
- **Offline Support**: Cached images for offline viewing
- **Image Zoom**: Pinch to zoom on high-resolution images
- **Video Support**: Play APOD videos directly in the app
- **Share**: Share amazing space content with friends

## Screenshots 📱

*Screenshots will be added here*

## Getting Started 🛠️

### Prerequisites

- Flutter SDK (>=2.17.0 <3.0.0)
- Dart SDK
- A NASA API key (free at [api.nasa.gov](https://api.nasa.gov/))

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/nasa-daily-snapshot.git
   cd nasa-daily-snapshot
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Get your NASA API key**
   - Visit [api.nasa.gov](https://api.nasa.gov/)
   - Sign up for a free API key
   - Copy your API key

4. **Configure the API key**
   - Open `lib/services/api_service.dart`
   - Replace the placeholder with your API key:
   ```dart
   static const String _apiKey = 'YOUR_API_KEY_HERE';
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure 📁

```
lib/
├── constants/          # App constants and strings
├── core/              # Core functionality and configuration
├── models/            # Data models
├── providers/         # State management (Provider pattern)
├── screens/           # UI screens
├── services/          # API and external services
├── themes/            # App theming
├── utils/             # Utility functions
├── widgets/           # Reusable UI components
└── main.dart          # App entry point
```

For detailed architecture information, see [ARCHITECTURE.md](ARCHITECTURE.md).

## Development 👨‍💻

For development guidelines and best practices, see [DEVELOPMENT.md](DEVELOPMENT.md).

### Key Technologies

- **Flutter**: Cross-platform UI framework
- **Provider**: State management
- **HTTP**: API communication
- **Cached Network Image**: Image caching and loading
- **Shared Preferences**: Local data persistence

### Code Organization

The project uses barrel exports for clean imports:

```dart
// ✅ Use this
import 'package:nasa_daily_snapshot/core/index.dart';
import 'package:nasa_daily_snapshot/models/index.dart';

// ❌ Instead of this
import 'package:nasa_daily_snapshot/core/error_handler.dart';
import 'package:nasa_daily_snapshot/models/apod_model.dart';
```

## API Information 🌐

This app uses NASA's APOD API:
- **Base URL**: `https://api.nasa.gov/planetary/apod`
- **Rate Limit**: 1000 requests/hour with API key (30/hour with DEMO_KEY)
- **Documentation**: [NASA APOD API](https://api.nasa.gov/)

### API Features Used
- Get today's APOD
- Get APOD by specific date
- Get APOD date range
- Support for both images and videos

## Features in Detail 🔍

### Home Screen
- Display today's APOD
- Beautiful image/video presentation
- Detailed information and explanation
- Quick actions (favorite, share)

### Search Screen
- Search through historical APOD entries
- Filter by date range
- Pagination for large result sets
- Grid and list view options

### Favorites Screen
- View saved favorite APODs
- Organize and manage favorites
- Quick access to loved content

### Settings Screen
- Theme switching (light/dark)
- Image quality preferences
- Cache management
- About information

## Performance Optimizations ⚡

- **Image Caching**: Efficient image loading and caching
- **Lazy Loading**: Load content as needed
- **State Management**: Optimized Provider usage
- **Memory Management**: Proper disposal of resources
- **API Caching**: Reduce redundant API calls

## Error Handling 🛡️

- Comprehensive error handling throughout the app
- User-friendly error messages
- Graceful degradation for network issues
- Retry mechanisms for failed requests

## Accessibility ♿

- Screen reader support
- High contrast themes
- Keyboard navigation
- Semantic labels

## Testing 🧪

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## Building for Production 📦

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

### Desktop
```bash
# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

## Contributing 🤝

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Contribution Guidelines

- Follow the existing code style
- Write tests for new features
- Update documentation as needed
- Use meaningful commit messages

## License 📄

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments 🙏

- **NASA** for providing the amazing APOD API
- **Flutter Team** for the excellent framework
- **Community** for open-source packages and inspiration

## Support 💬

If you have any questions or need help:

- Open an issue on GitHub
- Check the [documentation](DEVELOPMENT.md)
- Review the [architecture guide](ARCHITECTURE.md)

## Roadmap 🗺️

- [ ] Push notifications for daily APOD
- [ ] Social sharing features
- [ ] Advanced search filters
- [ ] Offline mode improvements
- [ ] Widget support
- [ ] Multiple language support
- [ ] Accessibility enhancements

---

**Made with ❤️ and Flutter**

*Explore the universe, one picture at a time* 🌌
