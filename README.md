# Word Guessing Game

เกมทายคำสนุกสำหรับหลายผู้เล่น ที่สามารถสุ่มคำได้จากหลายแหล่ง

## ✨ คุณสมบัติใหม่

### 🎲 ระบบคำสุ่มที่เสถียร

- **ไฟล์ JSON**: มีคำภาษาไทยมากกว่า 300+ คำ ใน 15 หมวดหมู่
- **API ภายนอก**: รองรับการดึงคำจาก API Ninjas (ไม่บังคับ)
- **Fallback System**: ระบบสำรองเมื่อไฟล์ JSON ไม่ทำงาน
- **หมวดหมู่หลากหลาย**: กีฬา, การ์ตูน, อาหาร, สัตว์, ยานพาหนะ, เทคโนโลยี, ธรรมชาติ, อาชีพ, ของใช้, สถานที่, สี, ตัวเลข, อารมณ์, เครื่องดนตรี, ประเทศ

### 🎮 ฟีเจอร์เกม

- เกมทายคำสำหรับหลายผู้เล่น
- ระบบจับเวลา
- สถิติการเล่น
- หมวดหมู่คำที่หลากหลาย
- รูปภาพประกอบคำ (จาก Unsplash API)

## 🚀 การติดตั้ง

1. **Clone โปรเจค**

```bash
git clone <repository-url>
cd word_guessing_game
```

2. **ติดตั้ง Dependencies**

```bash
flutter pub get
```

3. **ตั้งค่า API Keys (ไม่บังคับ)**

   - สมัครที่ [API Ninjas](https://api-ninjas.com) สำหรับคำสุ่มภาษาอังกฤษ
   - สมัครที่ [Unsplash](https://unsplash.com/developers) สำหรับรูปภาพ
   - สมัครที่ [Pixabay](https://pixabay.com/api/docs/) สำหรับรูปภาพ (ฟรี)
   - สมัครที่ [Google Custom Search](https://cse.google.com/) สำหรับรูปภาพจาก Google
   - แก้ไขไฟล์ `lib/services/word_service.dart`:

   ```dart
   static const String _apiNinjasKey = 'YOUR_API_NINJAS_KEY';
   static const String _unsplashApiKey = 'YOUR_UNSPLASH_API_KEY';
   static const String _googleApiKey = 'YOUR_GOOGLE_API_KEY';
   static const String _googleSearchEngineId = 'YOUR_SEARCH_ENGINE_ID';
   ```

4. **รันแอป**

```bash
flutter run
```

## 📁 โครงสร้างไฟล์

```
lib/
├── services/
│   └── word_service.dart      # ระบบจัดการคำสุ่ม
├── models/
│   └── word_item.dart         # โมเดลคำ
├── providers/
│   └── game_provider.dart     # จัดการสถานะเกม
└── screens/
    ├── setup_screen.dart      # หน้าตั้งค่าเกม
    ├── game_screen.dart       # หน้าเล่นเกม
    └── stats_screen.dart      # หน้าสถิติ

assets/
└── data/
    └── words.json            # ฐานข้อมูลคำภาษาไทย
```

## 🎯 วิธีการทำงาน

### ระบบคำสุ่ม

1. **ลำดับการดึงคำ**:

   - ดึงจากไฟล์ JSON เป็นหลัก (เสถียรและเร็ว)
   - ถ้าไม่ได้ ลองดึงจาก API Ninjas (ไม่บังคับ)
   - ถ้าไม่ได้ ใช้ระบบ fallback

2. **หมวดหมู่ที่มี**:
   - กีฬา (20 คำ): ฟุตบอล, บาสเกตบอล, เทนนิส, กอล์ฟ, มวยไทย, ฯลฯ
   - การ์ตูน (20 คำ): โดราเอมอน, โคนัน, นารูโตะ, วันพีช, ฯลฯ
   - อาหาร (20 คำ): พิซซ่า, ซูชิ, ฮอทด็อก, ต้มยำกุ้ง, ฯลฯ
   - และอีก 12 หมวดหมู่ รวมกว่า 300+ คำ

### การเพิ่มคำใหม่

1. **เพิ่มในไฟล์ JSON**:
   แก้ไข `assets/data/words.json` เพิ่มคำใหม่ในหมวดหมู่ที่ต้องการ

2. **เพิ่มหมวดหมู่ใหม่**:
   ```json
   "หมวดหมู่ใหม่": {
     "words": [
       {"word": "คำใหม่", "description": "คำอธิบาย"}
     ]
   }
   ```

## 🔧 การปรับแต่ง

### เพิ่ม API ใหม่

แก้ไข `lib/services/word_service.dart` เพิ่มฟังก์ชันใหม่:

```dart
static Future<WordItem?> _fetchFromNewApi() async {
  // โค้ดสำหรับดึงจาก API ใหม่
}
```

### เปลี่ยนลำดับการดึงคำ

แก้ไขฟังก์ชัน `getRandomWord()` ใน `word_service.dart`

## 📊 สถิติ

- จำนวนคำทั้งหมด: 300+ คำ
- จำนวนหมวดหมู่: 15 หมวดหมู่
- รองรับ API: 2 แหล่ง (API Ninjas, Unsplash) - ไม่บังคับ
- ระบบ Fallback: 5 คำพื้นฐาน

## 🤝 การมีส่วนร่วม

1. Fork โปรเจค
2. สร้าง Feature Branch
3. Commit การเปลี่ยนแปลง
4. Push ไปยัง Branch
5. สร้าง Pull Request

## 📝 License

MIT License - ดูรายละเอียดในไฟล์ LICENSE

## 🆘 การแก้ปัญหา

### ปัญหาที่พบบ่อย

1. **API ไม่ทำงาน**: ระบบจะใช้ไฟล์ JSON แทน
2. **คำซ้ำ**: ระบบจะสุ่มคำใหม่อัตโนมัติ
3. **รูปภาพไม่โหลด**: ใช้รูปภาพจาก Picsum แทน

### การ Debug

เปิด Console เพื่อดู Log:

```dart
print('Error fetching random word: $e');
```

---

**สนุกกับการเล่นเกมทายคำ! 🎮✨**
