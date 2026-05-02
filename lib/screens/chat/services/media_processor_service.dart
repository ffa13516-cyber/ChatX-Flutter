import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;

class MediaProcessorService {
  // Singleton Pattern لضمان وجود نسخة واحدة فقط في الميموري
  static final MediaProcessorService _instance = MediaProcessorService._internal();
  factory MediaProcessorService() => _instance;
  MediaProcessorService._internal();

  // API Key لخدمة إزالة الخلفية (مثل remove.bg) - يفضل نقله لملف .env لاحقاً
  final String _bgRemovalApiUrl = "https://api.remove.bg/v1.0/removebg";
  final String _apiKey = "YOUR_API_KEY_HERE"; 

  /// تحويل أي صورة لـ WebP لتقليل الحجم بنسبة تصل لـ 80% مع الحفاظ على الجودة
  Future<Uint8List?> convertToWebP(Uint8List imageBytes, {int quality = 80}) async {
    try {
      final img.Image? decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) return null;

      // التشفير لصيغة WebP الحديثة
      return img.encodeWebp(decodedImage, quality: quality);
    } catch (e) {
      print("Error converting to WebP: $e");
      return null;
    }
  }

  /// إزالة الخلفية بالذكاء الاصطناعي وتحويل النتيجة فوراً لـ WebP
  Future<Uint8List?> removeBackground(Uint8List imageBytes) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_bgRemovalApiUrl));
      request.headers['X-Api-Key'] = _apiKey;
      
      request.files.add(http.MultipartFile.fromBytes(
        'image_file', 
        imageBytes, 
        filename: 'sticker.png'
      ));
      
      request.fields['size'] = 'auto'; // معالجة تلقائية للحجم

      var response = await request.send();
      
      if (response.statusCode == 200) {
        final respBytes = await response.stream.toBytes();
        // تمرير النتيجة الشفافة لدالة التحويل لضغطها
        return await convertToWebP(respBytes, quality: 90) ?? respBytes;
      } else {
        print("Background removal API failed: ${response.statusCode}");
        return null; // يمكن إرجاع الصورة الأصلية هنا كـ Fallback
      }
    } catch (e) {
      print("Error in removeBackground: $e");
      return null;
    }
  }
}
