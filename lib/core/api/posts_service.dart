import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'api_client.dart';

class PostsService {
  final ApiClient _client;

  PostsService(this._client);

  Future<Map<String, dynamic>> getPosts({int page = 1, String search = ''}) async {
    final params = <String, dynamic>{'page': page};
    if (search.isNotEmpty) params['search'] = search;
    final response = await _client.dio.get('/posts', queryParameters: params);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getPost(String slug) async {
    final response = await _client.dio.get('/posts/$slug');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createPost({
    required String title,
    required String content,
    String? excerpt,
    int? servings,
    String? ingredientsJson,
    XFile? image,
  }) async {
    final data = <String, dynamic>{
      'title': title,
      'content': content,
      if (excerpt != null) 'excerpt': excerpt,
      if (servings != null) 'servings': servings.toString(),
      if (ingredientsJson != null) 'ingredients': ingredientsJson,
    };

    if (image != null) {
      final bytes = await image.readAsBytes();
      final filename = image.name.isNotEmpty ? image.name : 'image.jpg';
      data['image'] = MultipartFile.fromBytes(bytes, filename: filename);
    }

    final response = await _client.dio.post('/posts', data: FormData.fromMap(data));
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updatePost(
    int id, {
    String? title,
    String? content,
    String? excerpt,
    int? servings,
    String? ingredientsJson,
    XFile? image,
  }) async {
    final data = <String, dynamic>{
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (excerpt != null) 'excerpt': excerpt,
      if (servings != null) 'servings': servings.toString(),
      if (ingredientsJson != null) 'ingredients': ingredientsJson,
      '_method': 'PUT',
    };

    if (image != null) {
      final bytes = await image.readAsBytes();
      final filename = image.name.isNotEmpty ? image.name : 'image.jpg';
      data['image'] = MultipartFile.fromBytes(bytes, filename: filename);
    }

    final response = await _client.dio.post('/posts/$id', data: FormData.fromMap(data));
    return response.data as Map<String, dynamic>;
  }

  Future<void> deletePost(int id) async {
    await _client.dio.delete('/posts/$id');
  }

  Future<Map<String, dynamic>> myPosts({int page = 1, String search = ''}) async {
    final params = <String, dynamic>{'page': page};
    if (search.isNotEmpty) params['search'] = search;
    final response = await _client.dio.get('/my-posts', queryParameters: params);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getBookmarks({int page = 1}) async {
    final response = await _client.dio.get('/bookmarks', queryParameters: {'page': page});
    return response.data as Map<String, dynamic>;
  }
}
