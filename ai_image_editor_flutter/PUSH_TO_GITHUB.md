# 🚀 Hướng Dẫn Push Lên GitHub Và Build APK

## 🎯 Mục tiêu
Push code từ Replit lên GitHub và dùng GitHub Actions để build APK miễn phí.

---

## 📋 Bước 1: Tạo GitHub Repository

### 1.1 Truy cập GitHub
- Vào https://github.com
- Đăng nhập tài khoản

### 1.2 Tạo Repository mới
- Click nút **"New"** (màu xanh)
- **Repository name**: `ai-image-editor-flutter`
- **Description**: `AI Image Editor - Flutter Android App with Background/Object Removal`
- Chọn **Public** (để dùng GitHub Actions miễn phí)
- **KHÔNG** tick "Add a README file" (vì đã có sẵn)
- Click **"Create repository"**

---

## 📤 Bước 2: Push Code Lên GitHub

### 2.1 Trong Replit Terminal, chạy lệnh:

```bash
# Di chuyển vào thư mục dự án (nếu chưa)
cd ai_image_editor_flutter

# Thêm remote repository (thay YOUR_USERNAME bằng username GitHub của bạn)
git remote add origin https://github.com/YOUR_USERNAME/ai-image-editor-flutter.git

# Push code lên GitHub
git push -u origin main
```

### 2.2 Nhập GitHub credentials khi được hỏi:
- **Username**: username GitHub của bạn
- **Password**: Personal Access Token (không phải password)

### 2.3 Tạo Personal Access Token (nếu cần):
1. GitHub > Settings > Developer settings > Personal access tokens > Tokens (classic)
2. Generate new token > Classic
3. Chọn: `repo`, `workflow`, `write:packages`
4. Copy token và dùng làm password

---

## 🔧 Bước 3: Build APK Với GitHub Actions

### 3.1 Kiểm tra workflow đã được push:
- Vào GitHub repository
- Check có folder `.github/workflows/build-apk.yml`

### 3.2 Chạy build thủ công:
1. Vào tab **"Actions"** trong GitHub repo
2. Click **"Build Android APK"** ở bên trái
3. Click **"Run workflow"** (nút màu xanh)
4. Click **"Run workflow"** một lần nữa để confirm

### 3.3 Theo dõi quá trình build:
- Build sẽ mất khoảng 5-10 phút
- Có thể xem log real-time
- Đợi đến khi hiện **✅ All checks passed**

---

## 📱 Bước 4: Tải APK

### 4.1 Từ Artifacts (build từng lần):
1. Click vào build đã hoàn thành
2. Scroll xuống phần **"Artifacts"**
3. Tải `release-apk` (APK single file ~20MB)
4. Tải `split-apks` (Multiple APKs ~15MB mỗi file)

### 4.2 Từ Releases (tự động):
1. Vào tab **"Releases"** trong repo
2. Tải APK từ release mới nhất
3. Chọn file phù hợp:
   - `app-arm64-v8a-release.apk` (cho hầu hết điện thoại)
   - `app-armeabi-v7a-release.apk` (cho điện thoại cũ)
   - `app-release.apk` (universal, kích thước lớn hơn)

---

## 🔑 Bước 5: Cấu Hình API Key (Quan Trọng!)

### 5.1 Trước khi build, sửa file:
`lib/services/clipdrop_service.dart`

### 5.2 Thay đổi:
```dart
// TÌM DÒNG NÀY:
static const String _apiKey = 'YOUR_CLIPDROP_API_KEY';

// THAY BẰNG:
static const String _apiKey = 'sk-xxxxxxxxxxxxxxx'; // API key thật
```

### 5.3 Lấy API key miễn phí:
1. Vào https://clipdrop.co/apis
2. Đăng ký tài khoản
3. Tạo API key
4. Copy và paste vào code

### 5.4 Push lại sau khi sửa:
```bash
git add lib/services/clipdrop_service.dart
git commit -m "Update Clipdrop API key"
git push
```

---

## 🚦 Tự Động Build Khi Push Code

Sau khi setup xong, mỗi lần push code mới:

```bash
# Sửa code trong Replit
# Sau đó:
git add .
git commit -m "Update features"
git push

# GitHub sẽ tự động build APK mới!
```

---

## 📋 Checklist Hoàn Thành

- [ ] Tạo GitHub repository thành công
- [ ] Push code từ Replit lên GitHub
- [ ] File `.github/workflows/build-apk.yml` có trong repo
- [ ] Chạy GitHub Actions thành công
- [ ] Tải được APK file
- [ ] Cấu hình Clipdrop API key
- [ ] Test APK trên điện thoại Android

---

## 🎉 Kết Quả

Sau khi hoàn thành:
- ✅ APK được build tự động mỗi khi push code
- ✅ Nhiều loại APK: universal, split-per-abi
- ✅ Release tự động với version number
- ✅ Miễn phí 100% với GitHub Actions
- ✅ Có thể chia sẻ link tải APK cho người khác

---

## 🆘 Khắc Phục Lỗi

### ❌ Build failed
1. Xem log chi tiết trong Actions
2. Kiểm tra `pubspec.yaml` có đúng dependencies
3. Chạy `flutter analyze` trong Replit trước khi push

### ❌ Cannot push to GitHub
1. Kiểm tra internet connection
2. Dùng Personal Access Token thay vì password
3. Kiểm tra repository name đúng

### ❌ API key không hoạt động
1. Kiểm tra API key có hợp lệ
2. Đảm bảo đã push code sau khi update API key
3. Test API key trên Clipdrop website trước

---

## 💡 Tips

1. **Repository Public**: Để dùng GitHub Actions miễn phí
2. **Branch Protection**: Có thể setup để chỉ build từ main branch
3. **Scheduled Builds**: Có thể setup build tự động hàng ngày
4. **Multiple Versions**: GitHub giữ lại APK của các version cũ
5. **Direct Download**: Có thể tạo direct download link cho APK

**Link direct download APK:** 
`https://github.com/YOUR_USERNAME/ai-image-editor-flutter/releases/latest/download/app-arm64-v8a-release.apk`