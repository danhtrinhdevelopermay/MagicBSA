# GitHub Actions APK Build Debug Guide

## 🔍 Phân tích lỗi và giải pháp

### Các lỗi thường gặp và cách khắc phục

#### 1. Android SDK không được cài đặt
**Lỗi**: `Unable to locate Android SDK`
**Giải pháp**: Đã thêm `android-actions/setup-android@v3` để tự động setup Android SDK

#### 2. License chưa được chấp nhận  
**Lỗi**: `You have not accepted the license agreements`
**Giải pháp**: Đã thêm step `flutter doctor --android-licenses`

#### 3. Gradle wrapper thiếu
**Lỗi**: `gradlew: command not found`
**Giải pháp**: Đã tạo sẵn `gradlew`, `gradlew.bat`, và `gradle-wrapper.jar`

#### 4. Dependencies version conflicts
**Lỗi**: Dart dependencies outdated
**Giải pháp**: Đã cấu hình để bỏ qua warning về outdated packages

## 🛠️ Workflow được tối ưu

### Thay đổi chính:
1. **Android SDK setup**: Sử dụng action chuyên dụng
2. **License handling**: Tự động chấp nhận license
3. **Build options**: Thêm `--no-shrink` để tránh lỗi minification
4. **Error handling**: `continue-on-error` cho split APKs
5. **Environment**: Loại bỏ các env vars không cần thiết

### Cấu hình hiện tại:
- **Flutter**: 3.22.0 (stable)
- **Java**: 17 (Zulu distribution) 
- **Android API**: 34
- **Build tools**: 34.0.0
- **Min SDK**: 21 (Android 5.0+)
- **Target SDK**: 34

## 📱 APK Output

Sau khi build thành công:
- **Universal APK**: `app-release.apk` (~50-100MB)
- **Split APKs**: 
  - `app-arm64-v8a-release.apk` (~30-50MB)
  - `app-armeabi-v7a-release.apk` (~30-50MB) 
  - `app-x86_64-release.apk` (~30-50MB)

## 🚀 Các bước test workflow

1. **Push code**: Workflow tự động chạy
2. **Monitor**: Xem trong GitHub Actions tab
3. **Download**: APK sẽ có trong Artifacts
4. **Install**: Test trên Android device

## 🔧 Nếu vẫn gặp lỗi

### Kiểm tra logs:
1. Vào repository GitHub
2. Clicks Actions tab  
3. Click vào workflow run bị lỗi
4. Click vào job "Build APK"
5. Xem step nào bị lỗi

### Các lỗi có thể xảy ra:

#### Build timeout (>6 phút)
- Workflow sẽ bị cancel
- Thường do dependencies download chậm
- Giải pháp: Re-run workflow

#### Out of memory
- Lỗi: `Java heap space`
- Giải pháp: Đã thêm `--no-shrink` flag

#### Signing issues
- Lỗi: `Keystore not found`
- Hiện tại: Dùng debug signing (OK cho testing)
- Sản xuất: Cần upload keystore vào secrets

## 📋 Checklist trước khi build

- ✅ File `gradlew` có quyền execute
- ✅ File `gradle-wrapper.jar` tồn tại  
- ✅ `pubspec.yaml` không có dependency conflicts
- ✅ Dart code không có syntax errors
- ✅ Android permissions trong `AndroidManifest.xml`
- ✅ API keys được configure đúng

Workflow hiện tại đã được tối ưu để xử lý tất cả các vấn đề thường gặp! 🎯