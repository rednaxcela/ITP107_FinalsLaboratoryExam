import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../main.dart' show favoritesBoxName;
import '../theme.dart';
import '../utils.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';

const String postsUrl = 'https://jsonplaceholder.typicode.com/posts';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  List<dynamic> _posts = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  // ---------------------------------------------------------------- GET
  Future<void> _fetchPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http
          .get(Uri.parse(postsUrl))
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          _posts = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'The server returned status ${response.statusCode}. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Please check your internet connection and try again.\n\nDetails: $e';
        _isLoading = false;
      });
    }
  }

  // --------------------------------------------------------------- POST
  Future<void> _submitPost(String title, String body) async {
    try {
      final response = await http.post(
        Uri.parse(postsUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'title': title, 'body': body, 'userId': 1}),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        final created = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          // JSONPlaceholder does not really save it, so show it locally.
          _posts.insert(0, {
            'id': created['id'],
            'title': title,
            'body': body,
            'userId': 1,
          });
        });
        showAppMessage(
          context,
          'Post created successfully (status 201).',
          isSuccess: true,
        );
      } else {
        showAppMessage(
          context,
          'Could not create the post (status ${response.statusCode}).',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      showAppMessage(context, 'Could not create the post: $e', isError: true);
    }
  }

  Future<void> _openNewPostDialog() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const _NewPostDialog(),
    );
    if (result != null) {
      await _submitPost(result['title']!, result['body']!);
    }
  }

  // ------------------------------------------------------------------ UI
  @override
  Widget build(BuildContext context) {
    final favorites = Hive.box(favoritesBoxName);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Reader'),
        actions: [
          ValueListenableBuilder(
            valueListenable: favorites.listenable(),
            builder: (context, Box box, _) {
              return IconButton(
                tooltip: 'Favorites',
                icon: Badge(
                  isLabelVisible: box.isNotEmpty,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  label: Text('${box.length}'),
                  child: const Icon(Icons.favorite_border_rounded, size: 28),
                ),
                onPressed: () => Navigator.pushNamed(context, '/favorites'),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(favorites),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewPostDialog,
        icon: const Icon(Icons.edit_rounded),
        label: const Text('New Post'),
      ),
    );
  }

  Widget _buildBody(Box favorites) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return EmptyState(
        icon: Icons.wifi_off_rounded,
        color: AppColors.danger,
        title: 'Something went wrong',
        message: _errorMessage!,
        actionLabel: 'Try again',
        onAction: _fetchPosts,
      );
    }

    final visiblePosts = _posts.where((post) {
      return '${post['title']}'.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: TextField(
            onChanged: (value) => setState(() => _query = value.trim()),
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              hintText: 'Search posts by title',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${visiblePosts.length} post${visiblePosts.length == 1 ? '' : 's'}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _fetchPosts,
            child: visiblePosts.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 60),
                      EmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'No posts found',
                        message: 'Try a different search word.',
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 4, bottom: 96),
                    itemCount: visiblePosts.length,
                    itemBuilder: (context, index) =>
                        _buildPostCard(visiblePosts[index], favorites),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildPostCard(dynamic post, Box favorites) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/details',
          arguments: {
            'id': post['id'],
            'title': post['title'],
            'body': post['body'],
          },
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: avatarColorFor(post['id']),
            child: Text(
              '${post['id']}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  capitalize('${post['title']}'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  capitalize('${post['body']}'.replaceAll('\n', ' ')),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ValueListenableBuilder(
            valueListenable: favorites.listenable(keys: [post['id']]),
            builder: (context, Box box, _) {
              final saved = box.containsKey(post['id']);
              return Icon(
                saved ? Icons.favorite_rounded : Icons.chevron_right_rounded,
                color: saved ? Colors.black : Colors.grey.shade500,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Dialog with title and body fields. Neither can be empty.
class _NewPostDialog extends StatefulWidget {
  const _NewPostDialog();

  @override
  State<_NewPostDialog> createState() => _NewPostDialogState();
}

class _NewPostDialogState extends State<_NewPostDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label cannot be empty';
    return null;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'title': _titleController.text.trim(),
        'body': _bodyController.text.trim(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: const Text('Create a new post'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (v) => _required(v, 'Title'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Body',
                  alignLabelWithHint: true,
                ),
                validator: (v) => _required(v, 'Body'),
              ),
            ],
          ),
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
          onPressed: _submit,
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
