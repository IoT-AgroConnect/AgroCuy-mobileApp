import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class FirebaseApi {
  static Future<String> uploadImage(File imageFile) async {
    try {
      final fileName = const Uuid().v4(); // nombre aleatorio
      final ref = FirebaseStorage.instance.ref().child('publications/$fileName.jpg');

      // Esto evita el error de metadata nulo
      final metadata = SettableMetadata(contentType: 'image/jpeg');

      final uploadTask = await ref.putFile(imageFile, metadata);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error al subir imagen a Firebase Storage: $e');
    }
  }
}
