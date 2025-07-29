# Photo Magic - AI Image Editor

## Deployment Guide

### Build APK với GitHub Actions

1. Push code lên GitHub repository
2. GitHub Actions sẽ tự động:
   - Setup Flutter và Java 17
   - Build APK release  
   - Upload artifacts
   - Create GitHub release

### Features

- Background removal (Xóa background)
- Object cleanup (Xóa đối tượng)
- Text removal (Xóa text)
- Image uncrop (Mở rộng ảnh)
- Image upscaling (Nâng cấp chất lượng)
- Reimagine (Tái tưởng tượng)
- Product photography (Ảnh sản phẩm)
- Background replacement (Thay background)
- Text-to-image (Tạo ảnh từ text)

### API Configuration

The app uses Clipdrop API for AI image processing. API keys are configured in the Settings screen.

### Build Requirements

- Flutter 3.22.0+
- Java 17
- Android SDK 34
- Gradle 8.4+

### GitHub Actions Workflow

The workflow automatically:
- Creates missing gradlew files
- Downloads gradle-wrapper.jar if needed
- Handles build dependencies
- Generates release APK
- Creates GitHub releases with APK attachments