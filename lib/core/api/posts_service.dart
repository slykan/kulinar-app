import 'dart:io';
import 'package:dio/dio.dart';
import 'api_client.dart';

class PostsService {
  final ApiClient _client;

  PostsService(this._client);

  Future<Map<String, dynamic>> getPosts({int page = 1}) async {
    final response = await _client.dio.get('/posts', queryParameters: {'page': page});
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
    File? image,
  }) async {
    final formData = FormData.fromMap({
      'title': title,
      'content': content,
      if (excerpt != null) 'excerpt': excerpt,
      if (image != null)
        'image': await MultipartFile.fromFile(image.path, filename: image.path.split('/').last),
    });

    final response = await _client.dio.post('/posts', data: formData);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updatePost(
    int id, {
    String? title,
    String? content,
    String? excerpt,
    File? image,
  }) async {
    final formData = FormData.fromMap({
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (excerpt != null) 'excerpt': excerpt,
      if (image != null)
        'image': await MultipartFile.fromFile(image.path, filename: image.path.split('/').last),
      '_method': 'PUT',
    });

    final response = await _client.dio.post('/posts/$id', data: formData);
    return response.data as Map<String, dynamic>;
  }

  Future<void> deletePost(int id) async {
    await _client.dio.delete('/posts/$id');
  }

  Future<Map<String, dynamic>> myPosts({int page = 1}) async {
    final response = await _client.dio.get('/my-posts', queryParameters: {'page': page});
    return response.data as Map<String, dynamic>;
  }
}
