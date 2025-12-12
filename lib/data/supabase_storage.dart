import 'dart:typed_data'; 
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> uploadAvatar(Uint8List fileBytes, String userId) async {
    try {
      final String fileName = '$userId.jpg';
      
      await _supabase.storage.from('avatars').uploadBinary(
            fileName,
            fileBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final String publicUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);
      
      // Додаємо timestamp, щоб оновити кеш браузера
      return '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      throw Exception('Помилка завантаження фото: $e');
    }
  }
}