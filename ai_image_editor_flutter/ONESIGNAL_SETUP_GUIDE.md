# Hướng dẫn cấu hình OneSignal Push Notifications cho TwinkBSA

## Bước 1: Tạo tài khoản OneSignal

1. Truy cập [OneSignal Dashboard](https://onesignal.com/)
2. Đăng ký tài khoản miễn phí hoặc đăng nhập
3. Click "New App/Website" để tạo ứng dụng mới
4. Chọn tên app: "TwinkBSA" và click "Create"

## Bước 2: Cấu hình Android Platform

1. Trong OneSignal Dashboard, chọn **Settings** > **Platforms**
2. Click **Google Android (FCM)** 
3. Cần có **Server Key** và **Sender ID** từ Firebase:

### Tạo Firebase Project:
1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" và tạo project tên "TwinkBSA"
3. Vào **Project Settings** > **Cloud Messaging**
4. Copy **Server Key** và **Sender ID**

### Cấu hình FCM trong OneSignal:
1. Paste **Server Key** vào ô "Server Key"
2. Paste **Sender ID** vào ô "Sender ID" 
3. Click "Save & Continue"

## Bước 3: Lấy OneSignal App ID

1. Trong OneSignal Dashboard, vào **Settings** > **Keys & IDs**
2. Copy **OneSignal App ID** (dạng: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)

## Bước 4: Cập nhật mã nguồn

Mở file `ai_image_editor_flutter/lib/services/onesignal_service.dart` - **ĐÃ ĐƯỢC CẤU HÌNH**:

```dart
static const String _oneSignalAppId = "a503a5c7-6b11-404a-b0ea-8505fdaf59e8"; // OneSignal App ID
```

✅ **OneSignal App ID đã được cấu hình sẵn trong dự án.**

## Bước 5: Cấu hình Firebase (Android)

1. Trong Firebase Console, vào **Project Settings**
2. Scroll xuống phần "Your apps" và click **Add app** > **Android**
3. Nhập **Android package name**: `com.example.ai_image_editor_flutter`
4. Download file `google-services.json`
5. Copy file `google-services.json` vào thư mục: `ai_image_editor_flutter/android/app/`

## Bước 6: Cập nhật build.gradle

Thêm vào `ai_image_editor_flutter/android/build.gradle` (project-level):

```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
}
```

Thêm vào `ai_image_editor_flutter/android/app/build.gradle` (app-level):

```gradle
apply plugin: 'com.google.gms.google-services'

dependencies {
    implementation 'com.google.firebase:firebase-messaging:23.1.2'
}
```

## Bước 7: Test thông báo

1. Build và chạy app trên thiết bị Android thật
2. Mở **Profile** > **Thông báo** trong app
3. Click **Thử nghiệm** để test notification
4. Hoặc gửi thông báo từ OneSignal Dashboard > **Messages** > **New Push**

## Bước 8: Gửi thông báo từ Dashboard

1. Vào OneSignal Dashboard > **Messages**
2. Click **New Push**
3. Nhập tiêu đề và nội dung thông báo
4. Chọn audience hoặc gửi đến tất cả user
5. Click **Send Message**

## Tính năng đã tích hợp:

✅ **Thông báo xử lý ảnh**: Thông báo khi ảnh được xử lý xong
✅ **Thông báo khuyến mãi**: Nhận thông báo về ưu đãi đặc biệt  
✅ **Tin tức cập nhật**: Thông báo về tính năng mới
✅ **Deep linking**: Navigation đến màn hình cụ thể từ notification
✅ **User tagging**: Phân loại user theo sở thích
✅ **Permission management**: Bật/tắt notifications trong app

## Lưu ý quan trọng:

- **OneSignal App ID** phải được cập nhật trong code trước khi build APK
- Test trên thiết bị thật, không phải emulator
- Cần internet connection để nhận thông báo
- User cần cấp permission notifications lần đầu sử dụng
- Miễn phí cho 30,000 web push subscribers và unlimited mobile push

## Gửi thông báo theo tags:

```json
{
  "app_id": "your-onesignal-app-id",
  "filters": [
    {"field": "tag", "key": "processing_notifications", "relation": "=", "value": "true"}
  ],
  "contents": {
    "en": "Your image has been processed!",
    "vi": "Ảnh của bạn đã được xử lý xong!"
  },
  "data": {
    "screen": "history"
  }
}
```

Hệ thống OneSignal đã được tích hợp hoàn chỉnh và sẵn sàng sử dụng!