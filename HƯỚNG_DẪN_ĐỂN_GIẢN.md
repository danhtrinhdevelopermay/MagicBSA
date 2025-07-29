# 📱 Hướng Dẫn Build APK Đơn Giản

## 🎯 Mục tiêu
Tạo file APK để cài đặt ứng dụng AI Image Editor lên điện thoại Android.

---

## ⚡ Cách nhanh nhất (Dùng script tự động)

### 1. Mở terminal/command prompt
### 2. Di chuyển vào thư mục dự án:
```bash
cd ai_image_editor_flutter
```

### 3. Chạy script tự động:
```bash
bash build_apk.sh
```

Script sẽ tự động:
- ✅ Kiểm tra Flutter
- ✅ Cài đặt dependencies 
- ✅ Kiểm tra lỗi
- ✅ Build APK
- ✅ Hướng dẫn cài đặt

---

## 🔧 Cách thủ công từng bước

### Bước 1: Chuẩn bị
```bash
# Di chuyển vào thư mục
cd ai_image_editor_flutter

# Cài đặt packages
flutter pub get
```

### Bước 2: Cấu hình API Key (QUAN TRỌNG!)

**File cần sửa:** `lib/services/clipdrop_service.dart`

**Tìm dòng này:**
```dart
static const String _apiKey = 'YOUR_CLIPDROP_API_KEY';
```

**Thay bằng:**
```dart
static const String _apiKey = 'sk-xxxxxxxxxxxxxxx'; // API key thật của bạn
```

**Lấy API key miễn phí tại:** https://clipdrop.co/apis

### Bước 3: Build APK

**Để phát hành (khuyến nghị):**
```bash
flutter build apk --release
```

**Để test:**
```bash
flutter build apk --debug
```

### Bước 4: Tìm file APK

File APK sẽ ở: `build/app/outputs/flutter-apk/`

- `app-release.apk` (dùng để phát hành)
- `app-debug.apk` (dùng để test)

---

## 📲 Cài đặt APK lên điện thoại

### Cách 1: Copy file APK
1. Copy file APK vào điện thoại
2. Mở file manager, tìm file APK
3. Tap vào file APK
4. Cho phép cài từ "Unknown sources" nếu được hỏi
5. Tap "Install"

### Cách 2: Qua USB
```bash
# Kết nối điện thoại, bật USB debugging
flutter install
```

---

## 🚨 Khắc phục lỗi thường gặp

### ❌ "Flutter command not found"
**Giải pháp:** Cài đặt Flutter từ https://flutter.dev/docs/get-started/install

### ❌ "Gradle build failed"
**Giải pháp:**
```bash
flutter clean
flutter pub get
flutter build apk --release
```

### ❌ "API key error" trong app
**Giải pháp:** Kiểm tra API key trong `lib/services/clipdrop_service.dart`

### ❌ "Permission denied" khi cài APK
**Giải pháp:** Bật "Install unknown apps" trong Settings điện thoại

---

## 📊 So sánh các loại APK

| Loại APK | Lệnh | Kích thước | Tốc độ | Mục đích |
|----------|------|------------|--------|----------|
| Debug | `flutter build apk --debug` | ~40MB | Chậm | Test |
| Release | `flutter build apk --release` | ~20MB | Nhanh | Phát hành |
| Split | `flutter build apk --split-per-abi` | ~15MB | Nhanh | Tối ưu |

---

## 🔄 Build tự động với GitHub

### 1. Tạo thư mục `.github/workflows/`
### 2. Tạo file `build-apk.yml` với nội dung:

```yaml
name: Build APK

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-java@v4
      with:
        distribution: 'zulu'
        java-version: '17'
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.22.0'
    
    - name: Build APK
      run: |
        cd ai_image_editor_flutter
        flutter pub get
        flutter build apk --release
    
    - name: Upload APK
      uses: actions/upload-artifact@v4
      with:
        name: android-apk
        path: ai_image_editor_flutter/build/app/outputs/flutter-apk/*.apk
```

### 3. Commit và push lên GitHub
### 4. Vào tab "Actions" để tải APK

---

## ✅ Checklist hoàn thành

- [ ] Flutter đã cài đặt (`flutter --version`)
- [ ] API key đã cấu hình trong `clipdrop_service.dart`
- [ ] Dependencies đã cài (`flutter pub get`)
- [ ] APK build thành công (`flutter build apk --release`)
- [ ] File APK đã tạo trong `build/app/outputs/flutter-apk/`
- [ ] APK cài đặt thành công trên điện thoại
- [ ] App chạy và có thể chọn ảnh

---

## 🆘 Cần hỗ trợ?

**Lỗi Flutter:**
```bash
flutter doctor
```

**Lỗi build:**
```bash
flutter clean
flutter pub get
flutter analyze
```

**Kiểm tra APK:**
```bash
flutter build apk --release --analyze-size
```

**Test app:**
```bash
flutter test
```

---

## 🎉 Kết quả cuối cùng

Sau khi hoàn thành, bạn sẽ có:
- ✅ File APK có thể cài lên bất kỳ điện thoại Android nào
- ✅ Ứng dụng hoạt động offline (trừ tính năng AI cần internet)
- ✅ Giao diện tiếng Việt, thân thiện với người dùng
- ✅ Tính năng xóa background và đối tượng bằng AI

**Kích thước APK:** ~15-20MB  
**Yêu cầu Android:** 5.0+ (API level 21+)  
**Permissions:** Camera, Storage, Internet