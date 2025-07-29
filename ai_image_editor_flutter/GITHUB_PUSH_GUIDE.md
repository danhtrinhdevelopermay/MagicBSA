# Hướng dẫn Push Code và Sửa GitHub Actions

## 🔧 Sửa lỗi GitHub Actions Build APK

GitHub Actions đang gặp lỗi vì workflow vẫn đang tìm thư mục con `ai_image_editor_flutter`, nhưng code hiện tại đã ở root repository.

### ✅ Đã sửa trong file `.github/workflows/build-apk.yml`:

**Thay đổi đã thực hiện:**
- Xóa tất cả `cd ai_image_editor_flutter` 
- Sửa đường dẫn từ `ai_image_editor_flutter/build/...` thành `build/...`
- Workflow giờ sẽ chạy đúng với cấu trúc thư mục hiện tại

## 🚀 Cách Push Code lên GitHub

Vì gặp vấn đề với git locks, bạn cần tự thực hiện:

### Bước 1: Xóa Git Locks (nếu có)
```bash
cd ai_image_editor_flutter
rm -f .git/index.lock .git/config.lock
```

### Bước 2: Add và Commit Changes
```bash
git add .
git commit -m "Fix GitHub Actions workflow paths and integrate free API alternatives"
```

### Bước 3: Push với Token mới (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)

**Thực hiện các lệnh sau trong terminal:**

```bash
cd ai_image_editor_flutter

# Xóa git locks
rm -f .git/index.lock .git/config.lock .git/refs/heads/main.lock

# Add và commit changes
git add .
git commit -m "Fix GitHub Actions workflow and integrate free APIs"

# Set remote với token mới
git remote set-url origin https://danhtrinhdevelopermay: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@github.com/danhtrinhdevelopermay/MagicBSA.git

# Push force
git push origin main --force
```

**Nếu vẫn gặp lỗi git lock:**
```bash
# Xóa toàn bộ git và init lại
rm -rf .git
git init
git add .
git commit -m "Updated Flutter app with free API alternatives"
git branch -M main
git remote add origin https://danhtrinhdevelopermay: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@github.com/danhtrinhdevelopermay/MagicBSA.git
git push -u origin main --force
```

## 📱 Những gì đã được cập nhật

### ✅ Tích hợp API Miễn Phí:
1. **Hugging Face API** - Tạo ảnh từ văn bản (MIỄN PHÍ)
2. **Real-ESRGAN via Replicate** - Nâng cấp độ phân giải (~$0.002/ảnh) 
3. **Cleanup.pictures API** - Xóa vật thể (MIỄN PHÍ với 720p)

### ✅ Files đã được tạo/cập nhật:
- `lib/services/alternative_ai_service.dart` - Service mới cho API thay thế
- `lib/services/clipdrop_service.dart` - Giữ lại tính năng được hỗ trợ
- `lib/widgets/enhanced_editor_widget.dart` - UI cập nhật với phân loại API
- `lib/providers/image_provider.dart` - Provider với methods mới
- `lib/screens/settings_screen.dart` - Cài đặt riêng cho từng API
- `.github/workflows/build-apk.yml` - Sửa đường dẫn workflow

### ✅ Giao diện đã cập nhật:
- Phân loại rõ ràng: ClipDrop (có phí) vs API miễn phí
- Cài đặt riêng biệt cho từng loại API
- Thông tin chi phí minh bạch
- Hướng dẫn lấy token/API key

## 🎯 Sau khi Push thành công:

1. **GitHub Actions sẽ tự động chạy** và build APK
2. **APK sẽ được upload** trong Releases 
3. **Ứng dụng hoạt động** với cả API trả phí và miễn phí

## 📋 Kiểm tra hoạt động:

1. Sau khi push, kiểm tra GitHub Actions tại: https://github.com/danhtrinhdevelopermay/MagicBSA/actions
2. APK build thành công sẽ xuất hiện trong Releases
3. Tải APK và test các tính năng mới

## 🔍 Troubleshooting:

**Nếu GitHub Actions vẫn lỗi:**
- Kiểm tra file `.github/workflows/build-apk.yml` đã được cập nhật
- Đảm bảo không còn đường dẫn `ai_image_editor_flutter/` nào

**Nếu Git push vẫn lỗi:**
- Tạo token GitHub mới
- Hoặc clone repository mới và copy code vào

Chúc bạn thành công! 🚀