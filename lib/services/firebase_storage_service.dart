import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart'; //

class FirebaseStorageService {
  static final FirebaseStorageService _instance = FirebaseStorageService._internal();
  factory FirebaseStorageService() => _instance;
  FirebaseStorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _uuid = const Uuid(); //

  /// رفع الملصق أو الإيموجي والحصول على الرابط المباشر
  Future<String?> uploadMedia({
    required Uint8List bytes,
    required String folder, // 'stickers' أو 'emojis'
    String? extension = 'webp',
  }) async {
    try {
      final userId = _auth.currentUser?.uid ?? 'anonymous';
      final fileName = '${_uuid.v4()}.$extension'; //[cite: 6]
      
      // تنظيم المسار بشكل احترافي: folder/userId/fileName
      final Reference ref = _storage.ref().child(folder).child(userId).child(fileName);

      // ضبط الـ Metadata عشان المتصفح والتطبيق يفهموا نوع الملف فوراً
      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/$extension',
        customMetadata: {'uploaded_by': userId},
      );

      // بدء عملية الرفع
      final UploadTask uploadTask = ref.putData(bytes, metadata);
      
      // انتظار انتهاء الرفع والحصول على الرابط
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print("Firebase Storage Upload Error: $e");
      return null;
    }
  }
}
