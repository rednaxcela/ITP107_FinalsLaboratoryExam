import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../main.dart' show favoritesBoxName;
import '../theme.dart';
import '../utils.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  // ------------------------------------------------------------- UPDATE
  Future<void> _editNote(
    BuildContext context,
    Box box,
    dynamic key,
    Map<String, dynamic> post,
  ) async {
    final newNote = await showDialog<String>(
      context: context,
      builder: (_) => _NoteDialog(initialNote: '${post['note'] ?? ''}'),
    );

    if (newNote == null) return; // cancelled

    post['note'] = newNote;
    await box.put(key, post);

    if (!context.mounted) return;
    showAppMessage(context, 'Note saved.', isSuccess: true);
  }

  // ------------------------------------------------------------- DELETE
  Future<void> _delete(
    BuildContext context,
    Box box,
    dynamic key,
    Map<String, dynamic> post,
  ) async {
    await box.delete(key);

    if (!context.mounted) return;
    showAppMessage(
      context,
      'Removed from favorites.',
      action: SnackBarAction(
        label: 'UNDO',
        onPressed: () => box.put(key, post), // bring it back
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box(favoritesBoxName);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      // ----------------------------------------------------------- READ
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box favorites, _) {
          if (favorites.isEmpty) {
            return EmptyState(
              icon: Icons.favorite_border_rounded,
              color: Colors.black,
              title: 'No favorites yet',
              message:
                  'Open a post and tap "Save to Favorites" to keep it here.',
              actionLabel: 'Browse posts',
              actionIcon: Icons.arrow_back_rounded,
              onAction: () => Navigator.pop(context),
            );
          }

          final keys = favorites.keys.toList();

          return ListView.builder(
            padding: const EdgeInsets.only(top: 4, bottom: 24),
            itemCount: keys.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Text(
                    '${keys.length} saved post${keys.length == 1 ? '' : 's'}  •  swipe left to remove',
                    style: theme.textTheme.bodyMedium,
                  ),
                );
              }

              final key = keys[index - 1];
              final post = Map<String, dynamic>.from(favorites.get(key) as Map);
              final note = '${post['note'] ?? ''}';

              return Dismissible(
                key: ValueKey(key),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  padding: const EdgeInsets.only(right: 24),
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.delete_rounded, color: Colors.white),
                ),
                onDismissed: (_) => _delete(context, favorites, key, post),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: avatarColorFor(post['id']),
                            child: Text(
                              '${post['id']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              capitalize('${post['title']}'),
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        capitalize('${post['body']}'),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      // Sticky-note style personal note.
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.noteBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.sticky_note_2_rounded,
                                size: 18, color: AppColors.noteText),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                note.isEmpty ? 'No personal note yet' : note,
                                style: TextStyle(
                                  color: AppColors.noteText,
                                  height: 1.4,
                                  fontStyle: note.isEmpty
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () =>
                                _editNote(context, favorites, key, post),
                            icon: const Icon(Icons.edit_rounded, size: 18),
                            label:
                                Text(note.isEmpty ? 'Add note' : 'Edit note'),
                          ),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                                foregroundColor: AppColors.danger),
                            onPressed: () =>
                                _delete(context, favorites, key, post),
                            icon: const Icon(Icons.delete_outline_rounded,
                                size: 18),
                            label: const Text('Remove'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Dialog for editing the personal note on a saved post.
class _NoteDialog extends StatefulWidget {
  const _NoteDialog({required this.initialNote});

  final String initialNote;

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: const Text('Personal note'),
      content: TextField(
        controller: _controller,
        maxLines: 3,
        maxLength: 120,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          hintText: 'Write a short note about this post',
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(110, 46)),
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
