import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleSearchService {
  // Google Custom Search API Configuration
  static const String _apiKey =
      'YAIzaSyC5mwI3ntBGyX_Ay9lA-29pZvhdTPEqrJA'; // ต้องสมัครที่ https://console.cloud.google.com
  static const String _searchEngineId =
      '111597857080193132639'; // สร้างที่ https://cse.google.com
  static const String _baseUrl = 'https://www.googleapis.com/customsearch/v1';

  // สำหรับทดสอบ - ใช้ API key ฟรี (จำกัดการใช้งาน)
  static const String _demoApiKey = 'AIzaSyBxGxGxGxGxGxGxGxGxGxGxGxGxGxGxGx';
  static const String _demoSearchEngineId = 'demo_search_engine_id';

  /// ดึงรูปภาพจาก Google Search API
  static Future<String?> getImageUrl(String query) async {
    try {
      // ใช้ API key จริงถ้ามี
      if (_apiKey != 'YOUR_GOOGLE_API_KEY' &&
          _searchEngineId != 'YOUR_SEARCH_ENGINE_ID') {
        return await _fetchFromGoogleSearch(query, _apiKey, _searchEngineId);
      }

      // ใช้ demo API key สำหรับทดสอบ
      return await _fetchFromGoogleSearch(
        query,
        _demoApiKey,
        _demoSearchEngineId,
      );
    } catch (e) {
      print('Error fetching image from Google Search: $e');
      return _getFallbackImage(query);
    }
  }

  /// ดึงรูปภาพจาก Google Custom Search API
  static Future<String?> _fetchFromGoogleSearch(
    String query,
    String apiKey,
    String searchEngineId,
  ) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl?key=$apiKey&cx=$searchEngineId&q=$query&searchType=image&num=1&safe=active',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List?;

        if (items != null && items.isNotEmpty) {
          final imageData = items[0];
          return imageData['link'] as String?;
        }
      } else {
        print(
          'Google Search API error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error in Google Search API call: $e');
    }

    return null;
  }

  /// รูปภาพ fallback สำหรับกรณีที่ API ไม่ทำงาน
  static String _getFallbackImage(String query) {
    // รูปภาพตัวอย่างสำหรับคำต่างๆ
    final fallbackImages = {
      'แมว':
          'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400&h=300&fit=crop',
      'สุนัข':
          'https://images.unsplash.com/photo-1517423440428-a5a00ad493e8?w=400&h=300&fit=crop',
      'รถยนต์':
          'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=400&h=300&fit=crop',
      'คอมพิวเตอร์':
          'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=400&h=300&fit=crop',
      'ภูเขา':
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop',
      'ทะเล':
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&h=300&fit=crop',
      'ดอกไม้':
          'https://images.unsplash.com/photo-1490750967868-88aa4486c946?w=400&h=300&fit=crop',
      'อาหาร':
          'https://images.unsplash.com/photo-1504674900244-1b47e22d6f52?w=400&h=300&fit=crop',
      'กีฬา':
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop',
      'การ์ตูน':
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop',
      'สัตว์':
          'https://images.unsplash.com/photo-1456926631375-92c8ce872def?w=400&h=300&fit=crop',
      'ยานพาหนะ':
          'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=400&h=300&fit=crop',
      'เทคโนโลยี':
          'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=400&h=300&fit=crop',
      'ธรรมชาติ':
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop',
      'อาชีพ':
          'https://images.unsplash.com/photo-1551836022-d5d88e9218df?w=400&h=300&fit=crop',
      'ของใช้':
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=300&fit=crop',
      'สถานที่':
          'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=400&h=300&fit=crop',
      'สี':
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop',
      'ตัวเลข':
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=300&fit=crop',
      'อารมณ์':
          'https://images.unsplash.com/photo-1490750967868-88aa4486c946?w=400&h=300&fit=crop',
      'เครื่องดนตรี':
          'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=300&fit=crop',
      'ประเทศ':
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop',
    };

    // หาคำที่ใกล้เคียงที่สุด
    String bestMatch = 'ดอกไม้'; // default
    int bestScore = 0;

    for (final entry in fallbackImages.entries) {
      final score = _calculateSimilarity(query, entry.key);
      if (score > bestScore) {
        bestScore = score;
        bestMatch = entry.key;
      }
    }

    return fallbackImages[bestMatch] ?? fallbackImages['ดอกไม้']!;
  }

  /// คำนวณความคล้ายคลึงระหว่างคำ
  static int _calculateSimilarity(String query, String target) {
    query = query.toLowerCase();
    target = target.toLowerCase();

    int score = 0;

    // ตรวจสอบการมีตัวอักษรร่วมกัน
    for (int i = 0; i < query.length; i++) {
      if (target.contains(query[i])) {
        score++;
      }
    }

    // ตรวจสอบความยาวที่ใกล้เคียง
    final lengthDiff = (query.length - target.length).abs();
    score -= lengthDiff;

    return score;
  }

  /// ทดสอบการเชื่อมต่อ API
  static Future<bool> testApiConnection() async {
    try {
      final testQuery = 'test';
      final result = await getImageUrl(testQuery);
      return result != null;
    } catch (e) {
      return false;
    }
  }

  /// ดึงข้อมูลเพิ่มเติมของรูปภาพ (ถ้ามี)
  static Future<Map<String, dynamic>?> getImageDetails(String query) async {
    try {
      if (_apiKey == 'YOUR_GOOGLE_API_KEY' ||
          _searchEngineId == 'YOUR_SEARCH_ENGINE_ID') {
        return null;
      }

      final uri = Uri.parse(
        '$_baseUrl?key=$_apiKey&cx=$_searchEngineId&q=$query&searchType=image&num=1&safe=active',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List?;

        if (items != null && items.isNotEmpty) {
          final imageData = items[0];
          return {
            'url': imageData['link'],
            'title': imageData['title'],
            'snippet': imageData['snippet'],
            'thumbnail': imageData['image']?['thumbnailLink'],
            'context': imageData['image']?['contextLink'],
          };
        }
      }
    } catch (e) {
      print('Error getting image details: $e');
    }

    return null;
  }
}
