# การตั้งค่า Pixabay API (ฟรี)

## 🎯 ทำไมเลือก Pixabay?

- ✅ **ฟรี 100%** - ไม่มี quota จำกัด
- ✅ **รูปภาพคุณภาพสูง** - HD และ 4K
- ✅ **มีรูปภาพภาษาไทย** - รองรับการค้นหาภาษาไทย
- ✅ **ตั้งค่าคล้าย** - ง่ายกว่าการตั้งค่า Google Search
- ✅ **เสถียร** - API ที่น่าเชื่อถือ

## 📋 ขั้นตอนการตั้งค่า

### 1. สมัครบัญชี Pixabay

1. ไปที่ [Pixabay](https://pixabay.com/)
2. คลิก "Join" เพื่อสมัครบัญชี
3. ยืนยันอีเมล

### 2. สร้าง API Key

1. ไปที่ [Pixabay API](https://pixabay.com/api/docs/)
2. คลิก "Get API Key"
3. กรอกข้อมูลและยืนยัน
4. คัดลอก API Key ที่ได้

### 3. แก้ไขไฟล์โค้ด

แก้ไขไฟล์ `lib/services/word_service.dart`:

```dart
// ดึงรูปภาพจาก Pixabay API (ฟรี)
static const String _pixabayApiKey = 'YOUR_ACTUAL_PIXABAY_API_KEY';
```

## 🎯 ตัวอย่างการใช้งาน

```dart
// ดึงรูปภาพสำหรับคำ "แมว"
final imageUrl = await WordService.getImageForWord('แมว');
print('Image URL: $imageUrl');
```

## 📊 การเปรียบเทียบกับ API อื่น

| ฟีเจอร์        | Pixabay  | Google Search | Unsplash   | Picsum   |
| -------------- | -------- | ------------- | ---------- | -------- |
| ฟรี            | ✅       | ❌            | ✅         | ✅       |
| Quota          | ไม่จำกัด | 100/day       | 5000/month | ไม่จำกัด |
| คุณภาพ         | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐    | ⭐⭐⭐⭐⭐ | ⭐⭐     |
| ความเกี่ยวข้อง | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐    | ⭐⭐⭐     | ❌       |
| ภาษาไทย        | ✅       | ✅            | ❌         | ❌       |
| ตั้งค่า        | ง่าย     | ยาก           | ง่าย       | ไม่ต้อง  |

## 🚀 ข้อดีของ Pixabay

1. **ฟรีจริงๆ** - ไม่มีค่าใช้จ่ายใดๆ
2. **รูปภาพเยอะ** - มากกว่า 4 ล้านรูป
3. **คุณภาพดี** - HD และ 4K
4. **ค้นหาดี** - รองรับคำค้นหาภาษาไทย
5. **เสถียร** - API ที่น่าเชื่อถือ

## ⚠️ ข้อจำกัด

- รูปภาพอาจไม่เยอะเท่า Google
- บางรูปอาจมีลิขสิทธิ์ (แต่ใช้ได้ฟรี)
- ไม่มีรูปภาพเฉพาะทางบางประเภท

## 🔧 การปรับแต่ง

### เพิ่มพารามิเตอร์การค้นหา

```dart
// ค้นหารูปภาพแนวแนวนอน
'https://pixabay.com/api/?key=$key&q=$query&orientation=horizontal'

// ค้นหารูปภาพสี
'https://pixabay.com/api/?key=$key&q=$query&colors=red'

// ค้นหารูปภาพประเภท
'https://pixabay.com/api/?key=$key&q=$query&image_type=photo'
```

### พารามิเตอร์ที่แนะนำ

- `lang=th` - ค้นหาภาษาไทย
- `image_type=photo` - เฉพาะรูปภาพ
- `per_page=1` - จำนวนรูปภาพ
- `safesearch=true` - ปลอดภัย

## 🎮 การใช้งานในเกม

```dart
// ใน WordService
static Future<String?> getImageForWord(String word) async {
  // ลองดึงจาก Pixabay ก่อน
  final pixabayImage = await _fetchFromPixabay(word);
  if (pixabayImage != null) {
    return pixabayImage;
  }

  // Fallback ไปยังแหล่งอื่น
  return await getImageUrl(word);
}
```

## 🔍 การ Debug

เปิด Console เพื่อดู Log:

```dart
print('Error fetching from Pixabay: $e');
```

## 📱 ตัวอย่างผลลัพธ์

เมื่อค้นหาคำ "แมว" จะได้:

```
https://cdn.pixabay.com/photo/2014/11/30/14/11/cat-551554_1280.jpg
```

## 🎯 คำแนะนำ

1. **เริ่มต้น**: ใช้ Pixabay API (ฟรีและดี)
2. **พัฒนาต่อ**: เพิ่ม Unsplash (ถ้าต้องการรูปภาพสวยกว่า)
3. **ใช้งานจริง**: เพิ่ม Google Search (ถ้าต้องการความแม่นยำสูงสุด)

---

**Pixabay เป็นตัวเลือกที่ดีที่สุดสำหรับการเริ่มต้น! 🎉**
