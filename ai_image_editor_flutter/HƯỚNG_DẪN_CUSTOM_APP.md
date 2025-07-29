# 🎨 Hướng Dẫn Tùy Chỉnh App (Logo, Tên, Package)

## 📱 1. ĐỔI TÊN APP

### 1.1 Tên hiển thị trên Android (dưới icon)
**File:** `android/app/src/main/AndroidManifest.xml`
```xml
<!-- Dòng 9: đổi tên từ "AI Image Editor" thành tên bạn muốn -->
android:label="Tên App Của Bạn"
```

### 1.2 Tên trong Flutter code
**File:** `lib/main.dart`
```dart
// Dòng 18: đổi title
title: 'Tên App Của Bạn',
```

**File:** `pubspec.yaml`
```yaml
# Dòng 1-2: đổi tên và mô tả
name: ten_app_cua_ban
description: "Mô tả app của bạn"
```

---

## 🖼️ 2. ĐỔI LOGO APP

### 2.1 Chuẩn bị logo
- **Kích thước:** 1024x1024 px (định dạng PNG với nền trong suốt)
- **Tên file:** `app_icon.png`

### 2.2 Thay thế logo tự động
1. Copy file `app_icon.png` vào thư mục `android/app/src/main/res/`
2. Sử dụng online tool: https://appicon.co/ để tạo các kích thước
3. Tải về và thay thế folder `mipmap-*` trong `android/app/src/main/res/`

### 2.3 Thay thế thủ công
Thay thế các file sau với logo của bạn:
```
android/app/src/main/res/mipmap-hdpi/ic_launcher.png     (72x72)
android/app/src/main/res/mipmap-mdpi/ic_launcher.png     (48x48)
android/app/src/main/res/mipmap-xhdpi/ic_launcher.png    (96x96)
android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png   (144x144)
android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png  (192x192)
```

---

## 📦 3. ĐỔI PACKAGE NAME (ApplicationID)

### 3.1 Đổi Package Name chính
**File:** `android/app/build.gradle`
```gradle
// Dòng 27: đổi namespace
namespace = "com.tencongty.tenapp"

// Dòng 38: đổi applicationId  
applicationId = "com.tencongty.tenapp"
```

### 3.2 Đổi trong AndroidManifest
**File:** `android/app/src/main/AndroidManifest.xml`
```xml
<!-- Dòng 1: thêm package -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.tencongty.tenapp">
```

### 3.3 Đổi tên folder MainActivity
1. **Đổi tên thư mục:**
   - Từ: `android/app/src/main/kotlin/com/example/ai_image_editor_flutter/`
   - Thành: `android/app/src/main/kotlin/com/tencongty/tenapp/`

2. **Sửa MainActivity.kt:**
```kotlin
package com.tencongty.tenapp

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
}
```

---

## 🏷️ 4. ĐỔI VERSION & BUILD NUMBER

**File:** `pubspec.yaml`
```yaml
# Dòng 19: đổi version
version: 2.0.0+2
#         ↑     ↑
#    Version  Build
#    Name     Number
```

**Hoặc build với custom version:**
```bash
flutter build apk --build-name=2.0.0 --build-number=2
```

---

## 🎨 5. ĐỔI MÀU SPLASH SCREEN

**File:** `android/app/src/main/res/values/styles.xml`
```xml
<style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar">
    <item name="android:windowBackground">@color/splash_color</item>
</style>
```

**File:** `android/app/src/main/res/values/colors.xml` (tạo mới nếu chưa có)
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="splash_color">#6366f1</color>
</resources>
```

---

## 📝 6. VÍ DỤ HOÀN CHỈNH

### Ví dụ: App "Photo Magic" của công ty "ABC Studio"

**1. AndroidManifest.xml:**
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.abcstudio.photomagic">
    <application android:label="Photo Magic" ...>
```

**2. build.gradle:**
```gradle
namespace = "com.abcstudio.photomagic"
applicationId = "com.abcstudio.photomagic"
```

**3. pubspec.yaml:**
```yaml
name: photo_magic
description: "Chỉnh sửa ảnh bằng AI - Xóa background chuyên nghiệp"
version: 1.0.0+1
```

**4. main.dart:**
```dart
title: 'Photo Magic',
```

**5. Cấu trúc thư mục:**
```
android/app/src/main/kotlin/com/abcstudio/photomagic/MainActivity.kt
```

---

## ✅ 7. CHECKLIST SAU KHI SỬA

- [ ] Đổi tên app trong AndroidManifest.xml
- [ ] Đổi package name trong build.gradle
- [ ] Thay logo tất cả kích thước
- [ ] Đổi tên trong pubspec.yaml
- [ ] Đổi title trong main.dart
- [ ] Di chuyển và sửa MainActivity.kt
- [ ] Test build: `flutter build apk --debug`
- [ ] Kiểm tra app name và icon trên điện thoại

---

## 🚨 LƯU Ý QUAN TRỌNG

1. **Backup trước khi sửa:** Copy toàn bộ project trước
2. **Package name unique:** Phải duy nhất trên Play Store
3. **Clean build:** Chạy `flutter clean` sau khi đổi package name
4. **Test trước khi push:** Build thử trên local trước khi push GitHub

---

## 🛠️ LỆNH BUILD SAU KHI SỬA

```bash
# Clean project
flutter clean

# Get dependencies
flutter pub get

# Build debug để test
flutter build apk --debug

# Build release sau khi test OK
flutter build apk --release
```

---

## 🎯 KẾT QUẢ

Sau khi hoàn thành:
- ✅ App có tên và logo riêng
- ✅ Package name độc đáo
- ✅ Sẵn sàng upload Play Store
- ✅ Phân biệt với các app khác
- ✅ Thương hiệu chuyên nghiệp