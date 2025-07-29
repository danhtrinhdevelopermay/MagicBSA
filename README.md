# 🎨 AI Image Editor - Photo Magic (v2.0.0)

Ứng dụng chỉnh sửa ảnh bằng AI với đầy đủ tính năng Clipdrop API cho Android, được phát triển bởi **Bright Start Academy BSA**.

## ✨ Tính Năng Mới v2.0.0

### 🎨 Tạo Ảnh Từ Văn Bản (Text to Image)
- Tạo ảnh hoàn toàn mới từ mô tả văn bản
- Gợi ý prompt thông minh
- Hỗ trợ tiếng Việt và tiếng Anh

### 📐 Mở Rộng Ảnh (Uncrop)
- Tăng kích thước canvas thông minh
- Tùy chọn tỷ lệ khung hình (1:1, 16:9, 9:16, 4:3, 3:4)
- Điều chỉnh tỷ lệ mở rộng (1.1x - 3.0x)

### 🔍 Nâng Cấp Chất Lượng (Image Upscaling)
- Tăng độ phân giải ảnh lên đến 4K
- Cải thiện chất lượng với AI
- Tùy chỉnh kích thước đầu ra

### 🔄 Tái Tưởng Tượng (Reimagine)
- Tạo biến thể sáng tạo của ảnh gốc
- Giữ nguyên bố cục và chủ đề cơ bản
- Thay đổi phong cách và chi tiết

### 📦 Ảnh Sản Phẩm Chuyên Nghiệp (Product Photography)
- 8+ cảnh background khác nhau (forest, city, beach, mountain, studio, office, kitchen, bedroom)
- Chất lượng studio chuyên nghiệp
- Tối ưu cho thương mại điện tử

### 🌅 Thay Thế Background (Replace Background)
- Thay đổi nền bằng mô tả văn bản
- Upload ảnh nền tùy chỉnh
- Kết quả tự nhiên và chuyên nghiệp

## 🚀 Tính Năng Cơ Bản

- ✨ **Xóa Background**: Tự động loại bỏ background bằng AI
- 🎯 **Xóa Đối tượng**: Loại bỏ đối tượng không mong muốn với mask
- 📝 **Xóa Text**: Loại bỏ văn bản trên ảnh
- 📱 **Giao diện Mobile**: Tối ưu cho điện thoại
- 📸 **Chọn ảnh**: Từ thư viện hoặc camera
- 💾 **Lưu & Chia sẻ**: Lưu kết quả và chia sẻ
- ⚡ **Xử lý nhanh**: Kết quả trong vài giây

## Cài đặt

### Yêu cầu
- Flutter SDK 3.22.0 trở lên
- Android Studio hoặc VS Code
- Android device/emulator

### Setup
1. Clone repository và di chuyển vào thư mục dự án:
```bash
cd ai_image_editor_flutter
```

2. Cài đặt dependencies:
```bash
flutter pub get
```

3. **✅ API Key đã được cấu hình sẵn:**
   - App đã được cấu hình với API keys hợp lệ
   - Có thể sử dụng ngay mà không cần thêm cài đặt
   - Nếu cần thay đổi API key: Vào "Cài đặt API" từ menu
   - Xem hướng dẫn chi tiết: [API_CONFIGURATION_GUIDE.md](API_CONFIGURATION_GUIDE.md)

## Build APK

### Debug APK (Phát triển)
```bash
flutter build apk --debug
```

### Release APK (Sản xuất)
```bash
flutter build apk --release
```

### Split APK (Tối ưu kích thước)
```bash
flutter build apk --split-per-abi
```

APK sẽ được tạo trong: `build/app/outputs/flutter-apk/`

## Chạy ứng dụng

### Trên emulator/device
```bash
flutter run
```

### Chế độ release
```bash
flutter run --release
```

## Build với GitHub Actions

Tạo file `.github/workflows/build-apk.yml`:

```yaml
name: Build APK

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Java
      uses: actions/setup-java@v3
      with:
        distribution: 'zulu'
        java-version: '17'
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.22.0'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
      working-directory: ./ai_image_editor_flutter
    
    - name: Build APK
      run: flutter build apk --release
      working-directory: ./ai_image_editor_flutter
    
    - name: Upload APK
      uses: actions/upload-artifact@v3
      with:
        name: app-release.apk
        path: ai_image_editor_flutter/build/app/outputs/flutter-apk/app-release.apk
```

## Cấu trúc dự án

```
lib/
├── main.dart                 # Entry point
├── providers/
│   └── image_provider.dart   # State management
├── services/
│   └── clipdrop_service.dart # API service
├── screens/
│   └── home_screen.dart      # Main screen
└── widgets/
    ├── image_upload_widget.dart
    ├── image_editor_widget.dart
    ├── processing_widget.dart
    ├── result_widget.dart
    └── bottom_navigation_widget.dart
```

## API Configuration

### Clipdrop API
1. Đăng ký tại [ClipDrop APIs](https://clipdrop.co/apis)
2. Tạo API key
3. Cập nhật `_apiKey` trong `lib/services/clipdrop_service.dart`

### Supported Operations
- **Remove Background**: `/remove-background/v1`
- **Cleanup (Remove Objects)**: `/cleanup/v1`

## Quyền truy cập Android

Ứng dụng yêu cầu các quyền sau:
- `INTERNET`: Kết nối API
- `READ_EXTERNAL_STORAGE`: Đọc ảnh từ thư viện
- `WRITE_EXTERNAL_STORAGE`: Lưu ảnh đã chỉnh sửa
- `CAMERA`: Chụp ảnh mới

## Troubleshooting

### Lỗi thường gặp

1. **API Key không hợp lệ**
   - Kiểm tra API key trong `clipdrop_service.dart`
   - Đảm bảo key chưa hết hạn

2. **Permission denied**
   - Cấp quyền truy cập camera và thư viện ảnh
   - Kiểm tra AndroidManifest.xml

3. **Build failed**
   - Chạy `flutter clean && flutter pub get`
   - Kiểm tra phiên bản Flutter

### Debug commands
```bash
# Kiểm tra devices
flutter devices

# Kiểm tra doctor
flutter doctor

# Clean build
flutter clean

# Verbose logging
flutter run -v
```

## Phát triển thêm

### Thêm tính năng mới
1. Tạo service mới trong `services/`
2. Cập nhật provider trong `providers/`
3. Thêm UI widget trong `widgets/`

### Tích hợp API khác
- Mở rộng `ClipDropService` cho endpoints mới
- Thêm error handling phù hợp
- Cập nhật UI cho tính năng mới

## License

MIT License - Xem file LICENSE để biết thêm chi tiết.