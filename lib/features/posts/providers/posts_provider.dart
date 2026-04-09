import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/posts_service.dart';
import '../../auth/providers/auth_provider.dart';

final postsServiceProvider = Provider<PostsService>((ref) {
  final client = ref.watch(apiClientProvider);
  return PostsService(client);
});

class PostsState {
  final List<Map<String, dynamic>> posts;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String? error;

  const PostsState({
    this.posts = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.error,
  });

  PostsState copyWith({
    List<Map<String, dynamic>>? posts,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? error,
    bool clearError = false,
  }) {
    return PostsState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class PostsNotifier extends Notifier<PostsState> {
  @override
  PostsState build() => const PostsState();

  Future<void> loadPosts({bool refresh = false}) async {
    if (state.isLoading) return;
    if (!refresh && !state.hasMore) return;

    final page = refresh ? 1 : state.currentPage;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await ref.read(postsServiceProvider).getPosts(page: page);
      final newPosts = (result['data'] as List).cast<Map<String, dynamic>>();
      final lastPage = result['last_page'] as int;

      state = state.copyWith(
        posts: refresh ? newPosts : [...state.posts, ...newPosts],
        isLoading: false,
        hasMore: page < lastPage,
        currentPage: page + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void refresh() => loadPosts(refresh: true);
}

final postsProvider = NotifierProvider<PostsNotifier, PostsState>(PostsNotifier.new);
