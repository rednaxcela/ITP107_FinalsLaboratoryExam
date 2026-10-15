# Post Reader & Favorites
ITP107 - Mobile Application Development | Finals Laboratory Examination

Fetches posts from JSONPlaceholder, shows post details, and saves favorites locally with Hive.

## Dependencies (pubspec.yaml)
- http ^1.2.2
- hive ^2.2.3
- hive_flutter ^1.1.0

## Run
1. If the android/ and ios/ folders are missing, run `flutter create . --project-name post_reader_favorites` inside this folder.
   (Keep the lib/ and pubspec.yaml from this project if asked to overwrite.)
2. `flutter pub get`
3. `flutter run`

For release builds on Android, add this to android/app/src/main/AndroidManifest.xml (inside <manifest>):
`<uses-permission android:name="android.permission.INTERNET"/>`

## Structure
- lib/main.dart - Hive init, named routes ('/', '/details', '/favorites')
- lib/theme.dart - shared ThemeData and colors
- lib/utils.dart, lib/widgets/ - shared helpers, AppCard, EmptyState
- lib/screens/posts_screen.dart - GET list, error message, POST dialog
- lib/screens/details_screen.dart - receives arguments, Create (put)
- lib/screens/favorites_screen.dart - Read, Update (note), Delete
