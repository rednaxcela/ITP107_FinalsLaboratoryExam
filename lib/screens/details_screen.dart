import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../main.dart' show favoritesBoxName;
import '../utils.dart';
import '../widgets/app_card.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  // ------------------------------------------------------------- CREATE
  Future<void> _saveToFavorites(
    BuildContext context,
    Map<String, dynamic> args,
  ) async {
    final box = Hive.box(favoritesBoxName);
    final id = args['id'];

    // The post id is the key, so the same post can never be saved twice.
    if (box.containsKey(id)) {
      showAppMessage(context, 'This post is already in your favorites.');
      return;
    }

    await box.put(id, {
      'id': id,
      'title': args['title'],
      'body': args['body'],
      'note': '',
    });

    if (!context.mounted) return;
    showAppMessage(context, 'Saved to favorites!', isSuccess: true);
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final box = Hive.box(favoritesBoxName);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        titleTextStyle: TextStyle(
          color: scheme.onPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Colored header with the post title.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [scheme.primary, const Color(0xFF3A3A3A)],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(45),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Post #${args['id']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    capitalize('${args['title']}'),
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Content',
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: scheme.primary),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    capitalize('${args['body']}'),
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ValueListenableBuilder(
                valueListenable: box.listenable(keys: [args['id']]),
                builder: (context, Box b, _) {
                  final saved = b.containsKey(args['id']);
                  return Column(
                    children: [
                      saved
                          ? FilledButton.tonalIcon(
                              onPressed: () => _saveToFavorites(context, args),
                              icon: const Icon(Icons.check_circle_rounded),
                              label: const Text('Saved in Favorites'),
                            )
                          : FilledButton.icon(
                              onPressed: () => _saveToFavorites(context, args),
                              icon: const Icon(Icons.favorite_rounded),
                              label: const Text('Save to Favorites'),
                            ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Back to Posts'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
