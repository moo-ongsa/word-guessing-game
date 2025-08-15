# การตั้งค่า Google Custom Search API สำหรับรูปภาพ

## 📋 ขั้นตอนการตั้งค่า

### 1. สร้าง Google Cloud Project

1. ไปที่ [Google Cloud Console](https://console.cloud.google.com/)
2. สร้างโปรเจคใหม่หรือเลือกโปรเจคที่มีอยู่
3. เปิดใช้งาน Custom Search API

### 2. สร้าง API Key

1. ไปที่ "APIs & Services" > "Credentials"
2. คลิก "Create Credentials" > "API Key"
3. คัดลอก API Key ที่ได้

### 3. สร้าง Custom Search Engine

1. ไปที่ [Google Custom Search](https://cse.google.com/)
2. คลิก "Add" เพื่อสร้าง search engine ใหม่
3. ตั้งค่าดังนี้:
   - **Sites to search**: เลือก "Search the entire web"
   - **Search the entire web**: ✅ เปิดใช้งาน
   - **Image search**: ✅ เปิดใช้งาน
4. คัดลอก Search Engine ID (cx)

### 4. แก้ไขไฟล์โค้ด

แก้ไขไฟล์ `lib/services/word_service.dart`:

```dart
// Google Custom Search API สำหรับรูปภาพ
static const String _googleApiKey = 'YOUR_ACTUAL_GOOGLE_API_KEY';
static const String _googleSearchEngineId = 'YOUR_ACTUAL_SEARCH_ENGINE_ID';
```

## ⚠️ ข้อจำกัด

- **Quota**: 100 requests/day ฟรี
- **Cost**: $5 per 1000 requests หลังจากนั้น
- **Rate Limit**: 10 requests/second

## 🔧 ทางเลือกอื่นๆ

### 1. Pixabay API (แนะนำ)

- **ข้อดี**: ฟรี, ไม่มี quota จำกัด
- **ข้อเสีย**: รูปภาพน้อยกว่า Google
- **การตั้งค่า**: สมัครที่ [Pixabay](https://pixabay.com/api/docs/)

### 2. Unsplash API

- **ข้อดี**: รูปภาพคุณภาพสูง
- **ข้อเสีย**: ต้องสมัคร, มี quota จำกัด
- **การตั้งค่า**: สมัครที่ [Unsplash Developers](https://unsplash.com/developers)

### 3. Picsum Photos (ปัจจุบัน)

- **ข้อดี**: ฟรี, ไม่ต้องสมัคร
- **ข้อเสีย**: รูปภาพไม่เกี่ยวข้องกับคำ
- **การตั้งค่า**: ไม่ต้องตั้งค่า

## 🎯 ตัวอย่างการใช้งาน

```dart
// ดึงรูปภาพสำหรับคำ "แมว"
final imageUrl = await WordService.getImageForWord('แมว');
print('Image URL: $imageUrl');
```

## 📊 การเปรียบเทียบ API

| API                  | ฟรี | Quota      | คุณภาพ     | ความเกี่ยวข้อง |
| -------------------- | --- | ---------- | ---------- | -------------- |
| Google Custom Search | ❌  | 100/day    | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐     |
| Pixabay              | ✅  | ไม่จำกัด   | ⭐⭐⭐⭐   | ⭐⭐⭐⭐       |
| Unsplash             | ✅  | 5000/month | ⭐⭐⭐⭐⭐ | ⭐⭐⭐         |
| Picsum               | ✅  | ไม่จำกัด   | ⭐⭐       | ❌             |

## 🚀 คำแนะนำ

1. **เริ่มต้น**: ใช้ Picsum Photos (ไม่ต้องตั้งค่า)
2. **พัฒนาต่อ**: เพิ่ม Pixabay API (ฟรี)
3. **ใช้งานจริง**: เพิ่ม Google Custom Search (เสียเงิน)

## 🔍 การ Debug

เปิด Console เพื่อดู Log:

```dart
print('Error fetching from Google Search: $e');
print('Error fetching from Pixabay: $e');
print('Error fetching from Unsplash: $e');
```
