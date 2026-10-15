import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'screens/details_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/posts_screen.dart';
import 'theme.dart';

/// Name of the Hive box that stores favorite posts.
const String favoritesBoxName = 'favoritesBox';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox(favoritesBoxName);
  runApp(const PostReaderApp());
}

class PostReaderApp extends StatelessWidget {
  const PostReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Post Reader & Favorites',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      initialRoute: '/',
      routes: {
        '/': (context) => const PostsScreen(),
        '/details': (context) => const DetailsScreen(),
        '/favorites': (context) => const FavoritesScreen(),
      },
    );
  }
}
