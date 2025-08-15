import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import '../models/word_item.dart';

class WordService {
  static const String _unsplashApiKey =
      'YOUR_UNSPLASH_API_KEY'; // ต้องสมัครที่ https://unsplash.com/developers
  static const String _unsplashBaseUrl = 'https://api.unsplash.com';

  // API endpoints สำหรับดึงคำสุ่ม (ไม่บังคับ)
  static const String _randomWordApi =
      'https://api.api-ninjas.com/v1/randomword';
  static const String _apiNinjasKey =
      'YOUR_API_NINJAS_KEY'; // สมัครที่ https://api-ninjas.com

  // Google Custom Search API สำหรับรูปภาพ
  static const String _googleSearchApi =
      'https://www.googleapis.com/customsearch/v1';
  static const String _googleApiKey =
      'YOUR_GOOGLE_API_KEY'; // สมัครที่ https://console.cloud.google.com
  static const String _googleSearchEngineId =
      'YOUR_SEARCH_ENGINE_ID'; // สร้างที่ https://cse.google.com

  // ตัวแปรสำหรับเก็บข้อมูลจาก JSON
  static Map<String, dynamic>? _wordData;
  static bool _isDataLoaded = false;

  // หมวดหมู่สำหรับสุ่ม
  static const List<String> _categories = [
    'กีฬา',
    'การ์ตูน',
    'อาหาร',
    'สัตว์',
    'ยานพาหนะ',
    'เทคโนโลยี',
    'ธรรมชาติ',
    'อาชีพ',
    'ของใช้',
    'สถานที่',
    'สี',
    'ตัวเลข',
    'อารมณ์',
    'เครื่องดนตรี',
    'ประเทศ',
  ];

  // คำพื้นฐานสำหรับ fallback (กรณีที่ไฟล์ JSON ไม่ทำงาน)
  static final List<WordItem> _fallbackWords = [
    WordItem(word: 'แมว', category: 'สัตว์', description: 'สัตว์เลี้ยงสี่ขา'),
    WordItem(
      word: 'สุนัข',
      category: 'สัตว์',
      description: 'สัตว์เลี้ยงที่ซื่อสัตย์',
    ),
    WordItem(
      word: 'รถยนต์',
      category: 'ยานพาหนะ',
      description: 'ยานพาหนะสี่ล้อ',
    ),
    WordItem(
      word: 'คอมพิวเตอร์',
      category: 'เทคโนโลยี',
      description: 'เครื่องประมวลผล',
    ),
    WordItem(
      word: 'ภูเขา',
      category: 'ธรรมชาติ',
      description: 'พื้นที่สูงจากพื้นดิน',
    ),
  ];

  // โหลดข้อมูลจากไฟล์ JSON
  static Future<void> _loadWordData() async {
    if (_isDataLoaded) return;

    try {
      final jsonString = await rootBundle.loadString('assets/data/words.json');
      _wordData = json.decode(jsonString);
      _isDataLoaded = true;
      print('Word data loaded successfully');
    } catch (e) {
      print('Error loading word data: $e');
      _wordData = null;
    }
  }

  // ดึงคำสุ่มจากไฟล์ JSON หรือ API
  static Future<WordItem> getRandomWord() async {
    try {
      // ลองดึงจากไฟล์ JSON ก่อน
      await _loadWordData();
      if (_wordData != null) {
        final word = _getRandomWordFromJson();
        if (word != null) {
          return word;
        }
      }

      // ถ้าไฟล์ JSON ไม่ทำงาน ลองดึงจาก API
      final word = await _fetchFromRandomWordApi();
      if (word != null) {
        return word;
      }

      // ถ้าไม่สำเร็จ ให้ใช้คำสุ่มจาก fallback
      return _getRandomFallbackWord();
    } catch (e) {
      print('Error fetching random word: $e');
      return _getRandomFallbackWord();
    }
  }

  // ดึงคำสุ่มจากไฟล์ JSON
  static WordItem? _getRandomWordFromJson() {
    if (_wordData == null) return null;

    try {
      final random = Random();
      final categories = _wordData!['categories'].keys.toList();
      final randomCategory = categories[random.nextInt(categories.length)];
      final words = _wordData!['categories'][randomCategory]['words'] as List;
      final randomWordData = words[random.nextInt(words.length)];

      return WordItem(
        word: randomWordData['word'],
        category: randomCategory,
        description: randomWordData['description'],
      );
    } catch (e) {
      print('Error getting random word from JSON: $e');
      return null;
    }
  }

  // ดึงคำสุ่มจาก API Ninjas (ภาษาอังกฤษ) - ไม่บังคับ
  static Future<WordItem?> _fetchFromRandomWordApi() async {
    try {
      if (_apiNinjasKey == 'YOUR_API_NINJAS_KEY') {
        return null; // ไม่มี API key
      }

      final response = await http.get(
        Uri.parse(_randomWordApi),
        headers: {'X-Api-Key': _apiNinjasKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final word = data['word'] as String;
        final category = _getRandomCategory();
        return WordItem(
          word: word,
          category: category,
          description: _generateDescription(word, category),
        );
      }
    } catch (e) {
      print('Error fetching from API Ninjas: $e');
    }
    return null;
  }

  // สร้างคำอธิบายตามคำและหมวดหมู่
  static String _generateDescription(String word, String category) {
    final descriptions = {
      'กีฬา': 'กีฬาที่น่าสนใจ',
      'การ์ตูน': 'ตัวละครจากการ์ตูน',
      'อาหาร': 'อาหารที่อร่อย',
      'สัตว์': 'สัตว์ที่น่ารัก',
      'ยานพาหนะ': 'ยานพาหนะที่ใช้เดินทาง',
      'เทคโนโลยี': 'เทคโนโลยีที่ทันสมัย',
      'ธรรมชาติ': 'สิ่งธรรมชาติที่สวยงาม',
      'อาชีพ': 'อาชีพที่น่าสนใจ',
      'ของใช้': 'ของใช้ในชีวิตประจำวัน',
      'สถานที่': 'สถานที่ที่สำคัญ',
      'สี': 'สีที่สวยงาม',
      'ตัวเลข': 'ตัวเลขที่ใช้ในการนับ',
      'อารมณ์': 'อารมณ์ที่เรารู้สึก',
      'เครื่องดนตรี': 'เครื่องดนตรีที่สร้างเสียงไพเราะ',
      'ประเทศ': 'ประเทศที่น่าสนใจ',
    };

    return descriptions[category] ?? 'คำที่น่าสนใจ';
  }

  // สุ่มหมวดหมู่
  static String _getRandomCategory() {
    final random = Random();
    return _categories[random.nextInt(_categories.length)];
  }

  // ดึงคำสุ่มจาก fallback
  static WordItem _getRandomFallbackWord() {
    final random = Random();
    return _fallbackWords[random.nextInt(_fallbackWords.length)];
  }

  // ดึงคำสุ่มตามหมวดหมู่
  static Future<WordItem> getRandomWordByCategory(String category) async {
    try {
      // ลองดึงจากไฟล์ JSON ก่อน
      await _loadWordData();
      if (_wordData != null) {
        final word = _getRandomWordFromJsonByCategory(category);
        if (word != null) {
          return word;
        }
      }

      // ถ้าไม่ได้ ให้สร้างคำในหมวดหมู่ที่ต้องการ
      final wordText = _generateWordByCategory(category);
      return WordItem(
        word: wordText,
        category: category,
        description: _generateDescription(wordText, category),
      );
    } catch (e) {
      print('Error fetching word by category: $e');
      return _getRandomFallbackWord();
    }
  }

  // ดึงคำสุ่มจากไฟล์ JSON ตามหมวดหมู่
  static WordItem? _getRandomWordFromJsonByCategory(String category) {
    if (_wordData == null) return null;

    try {
      if (_wordData!['categories'][category] == null) return null;

      final words = _wordData!['categories'][category]['words'] as List;
      if (words.isEmpty) return null;

      final random = Random();
      final randomWordData = words[random.nextInt(words.length)];

      return WordItem(
        word: randomWordData['word'],
        category: category,
        description: randomWordData['description'],
      );
    } catch (e) {
      print('Error getting random word from JSON by category: $e');
      return null;
    }
  }

  // สร้างคำตามหมวดหมู่ (สำหรับกรณีที่ไฟล์ JSON ไม่ทำงาน)
  static String _generateWordByCategory(String category) {
    final random = Random();

    switch (category) {
      case 'กีฬา':
        final sports = [
          'ฟุตบอล',
          'บาสเกตบอล',
          'เทนนิส',
          'กอล์ฟ',
          'ว่ายน้ำ',
          'วิ่ง',
          'ปิงปอง',
          'แบดมินตัน',
        ];
        return sports[random.nextInt(sports.length)];

      case 'การ์ตูน':
        final cartoons = [
          'โดราเอมอน',
          'โคนัน',
          'นารูโตะ',
          'วันพีช',
          'ดราก้อนบอล',
          'แอตแทคออนไททัน',
        ];
        return cartoons[random.nextInt(cartoons.length)];

      case 'อาหาร':
        final foods = [
          'พิซซ่า',
          'ซูชิ',
          'ฮอทด็อก',
          'ไอศกรีม',
          'ช็อกโกแลต',
          'เค้ก',
          'ไก่ทอด',
          'ข้าวผัด',
        ];
        return foods[random.nextInt(foods.length)];

      case 'สัตว์':
        final animals = [
          'แมว',
          'สุนัข',
          'ช้าง',
          'สิงโต',
          'นกแก้ว',
          'กระต่าย',
          'ม้า',
          'ปลา',
        ];
        return animals[random.nextInt(animals.length)];

      case 'ยานพาหนะ':
        final vehicles = [
          'รถยนต์',
          'เครื่องบิน',
          'เรือ',
          'รถไฟ',
          'มอเตอร์ไซค์',
          'จักรยาน',
          'รถเมล์',
        ];
        return vehicles[random.nextInt(vehicles.length)];

      case 'เทคโนโลยี':
        final tech = [
          'คอมพิวเตอร์',
          'สมาร์ทโฟน',
          'หุ่นยนต์',
          'โดรน',
          'แว่น VR',
          'แท็บเล็ต',
          'แล็ปท็อป',
        ];
        return tech[random.nextInt(tech.length)];

      case 'ธรรมชาติ':
        final nature = [
          'ภูเขา',
          'ทะเล',
          'ป่าไม้',
          'น้ำตก',
          'พระอาทิตย์',
          'ดวงจันทร์',
          'ดอกไม้',
          'ต้นไม้',
        ];
        return nature[random.nextInt(nature.length)];

      case 'อาชีพ':
        final jobs = [
          'หมอ',
          'ครู',
          'ตำรวจ',
          'นักบิน',
          'นักดับเพลิง',
          'วิศวกร',
          'ทนายความ',
          'พยาบาล',
        ];
        return jobs[random.nextInt(jobs.length)];

      case 'ของใช้':
        final items = [
          'โทรทัศน์',
          'ตู้เย็น',
          'เตียง',
          'โต๊ะ',
          'เก้าอี้',
          'โทรศัพท์',
          'หนังสือ',
          'ปากกา',
        ];
        return items[random.nextInt(items.length)];

      case 'สถานที่':
        final places = [
          'โรงเรียน',
          'โรงพยาบาล',
          'ห้างสรรพสินค้า',
          'สนามบิน',
          'สถานีรถไฟ',
          'สวนสาธารณะ',
          'หอสมุด',
        ];
        return places[random.nextInt(places.length)];

      case 'สี':
        final colors = [
          'แดง',
          'น้ำเงิน',
          'เขียว',
          'เหลือง',
          'ส้ม',
          'ม่วง',
          'ชมพู',
          'ดำ',
          'ขาว',
        ];
        return colors[random.nextInt(colors.length)];

      case 'ตัวเลข':
        final numbers = [
          'หนึ่ง',
          'สอง',
          'สาม',
          'สี่',
          'ห้า',
          'หก',
          'เจ็ด',
          'แปด',
          'เก้า',
          'สิบ',
        ];
        return numbers[random.nextInt(numbers.length)];

      case 'อารมณ์':
        final emotions = [
          'สุข',
          'เศร้า',
          'โกรธ',
          'กลัว',
          'ประหลาดใจ',
          'รัก',
          'เกลียด',
          'เบื่อ',
        ];
        return emotions[random.nextInt(emotions.length)];

      case 'เครื่องดนตรี':
        final instruments = [
          'กีตาร์',
          'เปียโน',
          'กลอง',
          'ไวโอลิน',
          'ฟลุต',
          'ทรัมเป็ต',
          'แซกโซโฟน',
        ];
        return instruments[random.nextInt(instruments.length)];

      case 'ประเทศ':
        final countries = [
          'ไทย',
          'ญี่ปุ่น',
          'จีน',
          'เกาหลี',
          'อเมริกา',
          'อังกฤษ',
          'ฝรั่งเศส',
          'เยอรมัน',
        ];
        return countries[random.nextInt(countries.length)];

      default:
        return 'คำสุ่ม';
    }
  }

  // ดึงรูปภาพจากหลายแหล่ง
  static Future<String?> getImageUrl(String query) async {
    try {
      // ลองดึงจาก Google Custom Search ก่อน
      final googleImage = await _fetchFromGoogleSearch(query);
      if (googleImage != null) {
        return googleImage;
      }

      // ลองดึงจาก Unsplash API
      final unsplashImage = await _fetchFromUnsplash(query);
      if (unsplashImage != null) {
        return unsplashImage;
      }

      // ลองดึงจาก Pixabay API (ฟรี)
      final pixabayImage = await _fetchFromPixabay(query);
      if (pixabayImage != null) {
        return pixabayImage;
      }
    } catch (e) {
      print('Error fetching image: $e');
    }

    // Fallback to Picsum
    return 'https://picsum.photos/400/300?random=${DateTime.now().millisecondsSinceEpoch}';
  }

  // ดึงรูปภาพจาก Google Custom Search API
  static Future<String?> _fetchFromGoogleSearch(String query) async {
    try {
      if (_googleApiKey == 'YOUR_GOOGLE_API_KEY' ||
          _googleSearchEngineId == 'YOUR_SEARCH_ENGINE_ID') {
        return null; // ไม่มี API key
      }

      final response = await http.get(
        Uri.parse(
          '$_googleSearchApi?key=$_googleApiKey&cx=$_googleSearchEngineId&q=$query&searchType=image&num=1',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List?;
        if (items != null && items.isNotEmpty) {
          return items[0]['link'];
        }
      }
    } catch (e) {
      print('Error fetching from Google Search: $e');
    }
    return null;
  }

  // ดึงรูปภาพจาก Unsplash API
  static Future<String?> _fetchFromUnsplash(String query) async {
    try {
      if (_unsplashApiKey == 'YOUR_UNSPLASH_API_KEY') {
        return null; // ไม่มี API key
      }

      final response = await http.get(
        Uri.parse('$_unsplashBaseUrl/search/photos?query=$query&per_page=1'),
        headers: {'Authorization': 'Client-ID $_unsplashApiKey'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        if (results.isNotEmpty) {
          return results[0]['urls']['regular'];
        }
      }
    } catch (e) {
      print('Error fetching from Unsplash: $e');
    }
    return null;
  }

  // ดึงรูปภาพจาก Pixabay API (ฟรี)
  static Future<String?> _fetchFromPixabay(String query) async {
    try {
      const pixabayApiKey =
          'YOUR_PIXABAY_API_KEY'; // สมัครที่ https://pixabay.com/api/docs/
      if (pixabayApiKey == 'YOUR_PIXABAY_API_KEY') {
        // ใช้ API key ฟรีสำหรับทดสอบ (ไม่แนะนำสำหรับใช้งานจริง)
        return _getPixabayDemoImage(query);
      }

      final response = await http.get(
        Uri.parse(
          'https://pixabay.com/api/?key=$pixabayApiKey&q=$query&image_type=photo&per_page=1&lang=th',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final hits = data['hits'] as List;
        if (hits.isNotEmpty) {
          return hits[0]['webformatURL'];
        }
      }
    } catch (e) {
      print('Error fetching from Pixabay: $e');
    }
    return null;
  }

  // รูปภาพตัวอย่างจาก Pixabay (สำหรับทดสอบ)
  static String? _getPixabayDemoImage(String query) {
    // รูปภาพตัวอย่างสำหรับคำต่างๆ
    final demoImages = {
      'แมว':
          'https://cdn.pixabay.com/photo/2014/11/30/14/11/cat-551554_1280.jpg',
      'สุนัข':
          'https://cdn.pixabay.com/photo/2016/12/13/05/15/puppy-1903313_1280.jpg',
      'รถยนต์':
          'https://cdn.pixabay.com/photo/2015/05/28/23/12/auto-788747_1280.jpg',
      'คอมพิวเตอร์':
          'https://cdn.pixabay.com/photo/2016/11/29/08/41/apple-1868496_1280.jpg',
      'ภูเขา':
          'https://cdn.pixabay.com/photo/2015/06/19/21/24/avenue-815297_1280.jpg',
      'ทะเล':
          'https://cdn.pixabay.com/photo/2017/02/16/19/47/bokeh-2080072_1280.jpg',
      'ดอกไม้':
          'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_1280.jpg',
      'อาหาร':
          'https://cdn.pixabay.com/photo/2016/11/06/23/31/breakfast-1804457_1280.jpg',
    };

    return demoImages[query] ?? demoImages['ดอกไม้'];
  }

  // ดึงรูปภาพสำหรับคำที่กำหนด
  static Future<String?> getImageForWord(String word) async {
    return await getImageUrl(word);
  }

  // ดึงรายการหมวดหมู่ทั้งหมด
  static List<String> getAllCategories() {
    return _categories;
  }

  // ดึงคำทั้งหมดในหมวดหมู่ (สำหรับการแสดงผล)
  static Future<List<WordItem>> getWordsByCategory(String category) async {
    try {
      await _loadWordData();
      if (_wordData != null && _wordData!['categories'][category] != null) {
        final words = _wordData!['categories'][category]['words'] as List;
        return words
            .map(
              (wordData) => WordItem(
                word: wordData['word'],
                category: category,
                description: wordData['description'],
              ),
            )
            .toList();
      }
    } catch (e) {
      print('Error getting words by category: $e');
    }

    // Fallback: สร้างคำตัวอย่างในหมวดหมู่
    final words = <WordItem>[];
    for (int i = 0; i < 5; i++) {
      final wordText = _generateWordByCategory(category);
      words.add(
        WordItem(
          word: wordText,
          category: category,
          description: _generateDescription(wordText, category),
        ),
      );
    }
    return words;
  }

  // ฟังก์ชันสำหรับทดสอบ API
  static Future<bool> testApiConnection() async {
    try {
      final response = await http.get(Uri.parse('https://httpbin.org/get'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ฟังก์ชันสำหรับดูจำนวนคำทั้งหมด
  static Future<int> getTotalWordCount() async {
    try {
      await _loadWordData();
      if (_wordData != null) {
        int count = 0;
        for (final category in _wordData!['categories'].values) {
          count += (category['words'] as List).length;
        }
        return count;
      }
    } catch (e) {
      print('Error getting word count: $e');
    }
    return 0;
  }
}
