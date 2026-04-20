import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/posts_provider.dart';
import 'post_detail_screen.dart';
import '../widgets/ingredients_editor.dart';
import '../widgets/content_editor.dart';

const _kOrange = Color(0xFFE85D04);
const _kBg = Color(0xFF181818);
const _kCard = Color(0xFF242424);

class EditPostScreen extends ConsumerStatefulWidget {
  final String slug;
  const EditPostScreen({super.key, required this.slug});

  @override
  ConsumerState<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends ConsumerState<EditPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _excerptController = TextEditingController();
  final _contentController = TextEditingController();
  final _ingredientsKey = GlobalKey<IngredientsEditorState>();
  XFile? _newImage;
  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic>? _post;
  int? _initialServings;
  List<Map<String, dynamic>>? _initialIngredients;

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  Future<void> _loadPost() async {
    try {
      final service = ref.read(postsServiceProvider);
      final post = await service.getPost(widget.slug);
      final rawIngredients = post['ingredients'];
      List<Map<String, dynamic>>? ingredients;
      if (rawIngredients is List) {
        ingredients = rawIngredients.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      setState(() {
        _post = post;
        _titleController.text = post['title'] ?? '';
        _excerptController.text = post['excerpt'] ?? '';
        _contentController.text = post['content'] ?? '';
        _initialServings = post['servings'] as int?;
        _initialIngredients = ingredients;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška: $e'), backgroundColor: Colors.red),
        );
        context.pop();
      }
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _newImage = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _post == null) return;
    setState(() => _isSaving = true);

    try {
      final (servings, ingredientsJson) = _ingredientsKey.currentState?.getData() ?? (null, null);
      final service = ref.read(postsServiceProvider);
      await service.updatePost(
        (_post!['id'] as num).toInt(),
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        excerpt: _excerptController.text.trim().isEmpty ? null : _excerptController.text.trim(),
        servings: servings,
        ingredientsJson: ingredientsJson,
        image: _newImage,
      );
      ref.read(postsProvider.notifier).loadPosts(refresh: true);
      ref.invalidate(postDetailProvider(widget.slug));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recept spremljen!'), backgroundColor: _kOrange),
        );
        context.pop();
      }
    } catch (e) {
      String errMsg = e.toString();
      try {
        // ignore: avoid_dynamic_calls
        final resp = (e as dynamic).response;
        if (resp != null) {
          errMsg = 'HTTP ${resp.statusCode}: ${resp.data}';
        }
      } catch (_) {}
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errMsg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
          ),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _excerptController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: _kBg,
        body: Center(child: CircularProgressIndicator(color: _kOrange)),
      );
    }

    final existingImage = _post?['image'] != null
        ? 'https://kulinar.app/storage/${_post!['image']}'
        : null;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        title: const Text('Uredi recept'),
        backgroundColor: _kBg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Slika
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: _kCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (_newImage != null || existingImage != null)
                          ? _kOrange
                          : Colors.white12,
                      width: (_newImage != null || existingImage != null) ? 2 : 1,
                    ),
                  ),
                  child: _newImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(_newImage!.path, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Center(child: Icon(Icons.image, color: _kOrange, size: 48))),
                        )
                      : existingImage != null
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(existingImage, fit: BoxFit.cover),
                                ),
                                Positioned(
                                  bottom: 8, right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(children: [
                                      Icon(Icons.edit, color: Colors.white, size: 14),
                                      SizedBox(width: 4),
                                      Text('Promijeni', style: TextStyle(color: Colors.white, fontSize: 12)),
                                    ]),
                                  ),
                                ),
                              ],
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined, size: 48, color: _kOrange),
                                SizedBox(height: 12),
                                Text('Dodaj sliku', style: TextStyle(color: Colors.white54, fontSize: 14)),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Naslov recepta *',
                  prefixIcon: Icon(Icons.title, color: _kOrange),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Naslov je obavezan' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _excerptController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Kratki opis (opcionalno)',
                  prefixIcon: Icon(Icons.short_text, color: _kOrange),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Namirnice
              if (!_isLoading)
                IngredientsEditor(
                  key: _ingredientsKey,
                  initialServings: _initialServings,
                  initialIngredients: _initialIngredients,
                ),
              if (!_isLoading) const SizedBox(height: 16),

              const Text(
                'Sadržaj recepta *',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 6),
              ContentEditor(
                controller: _contentController,
                validator: (v) => v == null || v.isEmpty ? 'Sadržaj je obavezan' : null,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    disabledBackgroundColor: _kOrange.withOpacity(0.5),
                  ),
                  icon: _isSaving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _isSaving ? 'Spremate...' : 'Spremi izmjene',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _isSaving ? null : () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white54,
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Odustani', style: TextStyle(fontSize: 15)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
