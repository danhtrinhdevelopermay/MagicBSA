# Hướng dẫn cấu hình Firebase cho OneSignal - TwinkBSA

## ✅ Đã hoàn thành
- OneSignal App ID: `a503a5c7-6b11-404a-b0ea-8505fdaf59e8`
- Google Services plugin đã được thêm vào build.gradle
- Firebase dependencies đã được cấu hình

## 🔥 Cần làm tiếp: Cấu hình Firebase

### Bước 1: Tạo Firebase Project

1. **Truy cập Firebase Console**
   - Vào: https://console.firebase.google.com/
   - Đăng nhập với tài khoản Google

2. **Tạo Project mới**
   - Click "Create a project" (Tạo dự án)
   - Tên project: **TwinkBSA**
   - Chọn quốc gia: **Vietnam**
   - Click "Create project"

### Bước 2: Thêm Android App

1. **Trong Firebase project, click "Add app" > Android**
2. **Nhập thông tin:**
   - Android package name: `com.example.ai_image_editor_flutter`
   - App nickname: TwinkBSA
   - SHA-1: (có thể bỏ trống cho development)

3. **Download google-services.json**
   - Click "Download google-services.json"
   - **QUAN TRỌNG**: Copy file này vào thư mục: `ai_image_editor_flutter/android/app/`

### Bước 3: Cấu hình Cloud Messaging

1. **Trong Firebase Console:**
   - Vào **Project Settings** (bánh răng) > **Cloud Messaging**
   - Copy **Server Key** (dạng: AAAA...)
   - Copy **Sender ID** (dạng: 123456789)

2. **Cấu hình OneSignal:**
   - Vào OneSignal Dashboard: https://app.onesignal.com/
   - Chọn app TwinkBSA > **Settings** > **Platforms**
   - Click **Google Android (FCM)**
   - Nhập **Server Key** và **Sender ID** từ Firebase
   - Click "Save & Continue"

### Bước 4: Test Push Notification

1. **Build và cài đặt app trên điện thoại**
   ```bash
   cd ai_image_editor_flutter
   flutter build apk --release
   ```

2. **Test từ OneSignal Dashboard:**
   - Vào **Messages** > **New Push**
   - Nhập tiêu đề và nội dung
   - Chọn "Send to All Users"
   - Click "Send Message"

### Bước 5: Kiểm tra hoạt động

App sẽ tự động:
- Yêu cầu permission khi khởi động
- Hiển thị notification khi nhận được
- Lưu trữ User ID để gửi targeted notifications

---

## 🚨 Lưu ý quan trọng

- **File google-services.json phải được đặt trong thư mục**: `ai_image_editor_flutter/android/app/`
- **Không commit file google-services.json lên Git** (chứa thông tin nhạy cảm)
- **OneSignal App ID đã được cấu hình sẵn**: `a503a5c7-6b11-404a-b0ea-8505fdaf59e8`

## 📱 Sau khi hoàn thành

Push notifications sẽ hoạt động khi:
- User mở app lần đầu và cho phép notification
- App chạy trong background hoặc đã đóng
- Gửi từ OneSignal Dashboard hoặc API

**Hoàn thành bước này là app đã sẵn sàng nhận push notifications!**