# Hướng Dẫn Build APK Chi Tiết

## Bước 1: Chuẩn bị môi trường

### 1.1 Cài đặt Flutter
```bash
# Kiểm tra Flutter đã cài chưa
flutter --version

# Nếu chưa có, tải từ: https://flutter.dev/docs/get-started/install
```

### 1.2 Kiểm tra môi trường
```bash
flutter doctor
```

Đảm bảo có ít nhất:
- ✅ Flutter (Channel stable, 3.22.0 trở lên)
- ✅ Android toolchain
- ✅ Android Studio (tùy chọn)

## Bước 2: Chuẩn bị dự án

### 2.1 Di chuyển vào thư mục Flutter
```bash
cd ai_image_editor_flutter
```

### 2.2 Cài đặt dependencies
```bash
# Tải tất cả packages cần thiết
flutter pub get
```

### 2.3 Cấu hình API Key (BẮT BUỘC)

**Mở file:** `lib/services/clipdrop_service.dart`

**Tìm dòng:**
```dart
static const String _apiKey = 'YOUR_CLIPDROP_API_KEY';
```

**Thay bằng API key thật của bạn:**
```dart
static const String _apiKey = 'your-actual-clipdrop-api-key-here';
```

**Lấy API key tại:** https://clipdrop.co/apis

## Bước 3: Build APK

### 3.1 Build Debug APK (để test)
```bash
flutter build apk --debug
```

**Kết quả:** `build/app/outputs/flutter-apk/app-debug.apk` (kích thước lớn, chậm)

### 3.2 Build Release APK (để phát hành)
```bash
flutter build apk --release
```

**Kết quả:** `build/app/outputs/flutter-apk/app-release.apk` (tối ưu, nhanh)

### 3.3 Build Split APK (tối ưu kích thước)
```bash
flutter build apk --split-per-abi
```

**Kết quả:** Nhiều file APK cho từng kiến trúc CPU:
- `app-arm64-v8a-release.apk` (cho hầu hết điện thoại hiện tại)
- `app-armeabi-v7a-release.apk` (cho điện thoại cũ)
- `app-x86_64-release.apk` (cho emulator)

## Bước 4: Kiểm tra APK

### 4.1 Xem thông tin APK
```bash
flutter build apk --release --analyze-size
```

### 4.2 Test trước khi build
```bash
# Chạy test
flutter test

# Kiểm tra lỗi code
flutter analyze
```

## Bước 5: Cài đặt APK lên điện thoại

### 5.1 Bật Developer Options
1. Vào **Settings** > **About phone**
2. Tap **Build number** 7 lần
3. Quay lại **Settings** > **Developer options**
4. Bật **USB debugging**

### 5.2 Cài APK qua USB
```bash
# Kết nối điện thoại và kiểm tra
flutter devices

# Cài APK
flutter install
```

### 5.3 Cài APK thủ công
1. Copy file APK vào điện thoại
2. Mở file manager, tap vào APK
3. Cho phép cài app từ nguồn không xác định
4. Tap **Install**

## Bước 6: Troubleshooting

### Lỗi thường gặp:

#### 6.1 "Gradle build failed"
```bash
# Clean project
flutter clean
flutter pub get
flutter build apk --release
```

#### 6.2 "SDK not found"
```bash
# Kiểm tra Android SDK
flutter doctor --android-licenses
```

#### 6.3 "API key error"
- Kiểm tra API key trong `clipdrop_service.dart`
- Đảm bảo key chưa hết hạn
- Test API key trên Clipdrop website

#### 6.4 "Permission denied"
- Kiểm tra AndroidManifest.xml có đầy đủ permissions
- Cấp quyền camera, storage cho app

## Bước 7: Build tự động với GitHub

### 7.1 Tạo file workflow

**Tạo thư mục:** `.github/workflows/`

**Tạo file:** `build-apk.yml`

```yaml
name: Build Android APK

on:
  push:
    branches: [ main, master ]
  pull_request:
    branches: [ main, master ]

jobs:
  build:
    name: Build APK
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
    
    - name: Setup Java
      uses: actions/setup-java@v4
      with:
        distribution: 'zulu'
        java-version: '17'
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.22.0'
        channel: 'stable'
        cache: true
    
    - name: Get dependencies
      run: flutter pub get
      working-directory: ./ai_image_editor_flutter
    
    - name: Analyze code
      run: flutter analyze
      working-directory: ./ai_image_editor_flutter
    
    - name: Run tests
      run: flutter test
      working-directory: ./ai_image_editor_flutter
    
    - name: Build APK
      run: flutter build apk --release --split-per-abi
      working-directory: ./ai_image_editor_flutter
    
    - name: Upload APK artifacts
      uses: actions/upload-artifact@v4
      with:
        name: android-apk
        path: |
          ai_image_editor_flutter/build/app/outputs/flutter-apk/*.apk
```

### 7.2 Push code lên GitHub
```bash
git add .
git commit -m "Add Flutter APK build workflow"
git push origin main
```

### 7.3 Tải APK từ GitHub
1. Vào **Actions** tab trong GitHub repo
2. Click vào build thành công
3. Tải **android-apk** artifact
4. Giải nén và cài APK

## Bước 8: Tối ưu APK

### 8.1 Giảm kích thước APK
```bash
# Build với obfuscation
flutter build apk --release --obfuscate --split-debug-info=build/debug-info

# Build với compression
flutter build apk --release --target-platform android-arm64
```

### 8.2 Signing APK cho Play Store

**Tạo keystore:**
```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Cấu hình signing:** Tạo `android/key.properties`
```
storePassword=your-password
keyPassword=your-password
keyAlias=upload
storeFile=../upload-keystore.jks
```

**Update `android/app/build.gradle`:**
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

## Tóm tắt lệnh quan trọng

```bash
# Chuẩn bị
cd ai_image_editor_flutter
flutter pub get

# Build APK release
flutter build apk --release

# Build APK tối ưu
flutter build apk --release --split-per-abi

# Kiểm tra và cài đặt
flutter install

# Clean khi có lỗi
flutter clean && flutter pub get
```

## Lưu ý quan trọng

1. **API Key bắt buộc:** Phải có Clipdrop API key để app hoạt động
2. **Permissions:** App cần quyền Camera, Storage, Internet
3. **Testing:** Luôn test trên thiết bị thật trước khi phát hành
4. **File size:** Split APK giúp giảm kích thước tải xuống
5. **Security:** Không commit API key lên GitHub public repo

Nếu gặp khó khăn ở bước nào, hãy hỏi tôi cụ thể!