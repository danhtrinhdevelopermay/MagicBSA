# 🔧 Giải Quyết Lỗi "No Android SDK" Trên Replit

## ❌ Vấn đề
Khi chạy `flutter build apk` trên Replit, gặp lỗi:
```
No Android SDK found. Try setting the ANDROID_SDK_ROOT environment variable.
```

## ✅ Giải pháp

### Phương án 1: Sử dụng GitHub Actions (Khuyến nghị)

#### Bước 1: Tạo GitHub Repository
1. Tạo repo mới trên GitHub
2. Push code từ Replit lên GitHub:

```bash
# Trong Replit, mở Terminal
git init
git add .
git commit -m "Initial commit - Flutter AI Image Editor"
git branch -M main
git remote add origin https://github.com/USERNAME/REPO_NAME.git
git push -u origin main
```

#### Bước 2: Tạo GitHub Actions Workflow

Tạo file `.github/workflows/build-apk.yml`:

```yaml
name: Build Android APK

on:
  push:
    branches: [ main ]
  workflow_dispatch:  # Cho phép chạy thủ công

jobs:
  build:
    name: Build APK
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout repository
      uses: actions/checkout@v4
    
    - name: Setup Java JDK
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
    
    - name: Install dependencies
      run: |
        cd ai_image_editor_flutter
        flutter pub get
    
    - name: Analyze project
      run: |
        cd ai_image_editor_flutter
        flutter analyze --no-fatal-infos
    
    - name: Run tests
      run: |
        cd ai_image_editor_flutter
        flutter test
    
    - name: Build Release APK
      run: |
        cd ai_image_editor_flutter
        flutter build apk --release
    
    - name: Build Split APKs
      run: |
        cd ai_image_editor_flutter
        flutter build apk --release --split-per-abi
    
    - name: Upload Release APK
      uses: actions/upload-artifact@v4
      with:
        name: release-apk
        path: ai_image_editor_flutter/build/app/outputs/flutter-apk/app-release.apk
    
    - name: Upload Split APKs
      uses: actions/upload-artifact@v4
      with:
        name: split-apks
        path: |
          ai_image_editor_flutter/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
          ai_image_editor_flutter/build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
          ai_image_editor_flutter/build/app/outputs/flutter-apk/app-x86_64-release.apk
    
    - name: Create Release
      if: github.ref == 'refs/heads/main'
      uses: softprops/action-gh-release@v1
      with:
        tag_name: v${{ github.run_number }}
        name: Release v${{ github.run_number }}
        body: |
          AI Image Editor APK
          - Background removal with Clipdrop AI
          - Object removal functionality
          - Vietnamese interface
          - Android 5.0+ compatible
        files: |
          ai_image_editor_flutter/build/app/outputs/flutter-apk/*.apk
        draft: false
        prerelease: false
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

#### Bước 3: Chạy Build Trên GitHub
1. Push file workflow lên GitHub
2. Vào tab "Actions" trong repo
3. Click "Build Android APK"
4. Click "Run workflow"
5. Chờ build hoàn thành (khoảng 5-10 phút)
6. Tải APK từ "Artifacts" hoặc "Releases"

### Phương án 2: Cài Android SDK Trên Replit (Phức tạp)

```bash
# Cài Java
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java 17.0.7-zulu

# Tải Android Command Line Tools
cd $HOME
wget https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip
unzip commandlinetools-linux-10406996_latest.zip
mkdir -p android-sdk/cmdline-tools
mv cmdline-tools android-sdk/cmdline-tools/latest

# Set environment variables
export ANDROID_SDK_ROOT=$HOME/android-sdk
export PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools

# Cài Android SDK components
yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"

# Configure Flutter
flutter config --android-sdk $ANDROID_SDK_ROOT
flutter doctor --android-licenses
```

### Phương án 3: Build Local Trên Máy Tính

#### Bước 1: Tải code về máy
```bash
# Clone repo từ Replit
git clone https://replit.com/@USERNAME/PROJECT_NAME.git

# Hoặc tải ZIP từ Replit
```

#### Bước 2: Build trên máy có Android Studio
```bash
cd ai_image_editor_flutter
flutter pub get
flutter build apk --release
```

### Phương án 4: Sử dụng Cloud Build Services

#### 4.1 Codemagic (Miễn phí)
1. Đăng ký tại https://codemagic.io
2. Connect GitHub repository
3. Cấu hình build settings cho Flutter
4. Chạy build và tải APK

#### 4.2 GitHub Codespaces
1. Tạo Codespace từ GitHub repo
2. Cài Android SDK trong Codespace
3. Build APK trong cloud environment

## 🎯 Khuyến nghị

**Dùng GitHub Actions** (Phương án 1) vì:
- ✅ Miễn phí và đáng tin cậy
- ✅ Tự động build khi push code
- ✅ Không cần cài đặt gì thêm
- ✅ Có thể tạo release tự động
- ✅ Build được nhiều loại APK cùng lúc

## 📝 Các bước thực hiện nhanh

```bash
# 1. Tạo repo GitHub và push code
git init
git add .
git commit -m "Flutter AI Image Editor"
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin main

# 2. Tạo workflow file (copy nội dung ở trên)
mkdir -p .github/workflows
# Paste nội dung vào .github/workflows/build-apk.yml

# 3. Push workflow
git add .github/
git commit -m "Add GitHub Actions workflow"
git push

# 4. Vào GitHub > Actions > Run workflow
# 5. Chờ build xong và tải APK
```

## ⚠️ Lưu ý quan trọng

1. **API Key**: Nhớ cấu hình Clipdrop API key trước khi build
2. **Repository**: Đặt repo là public để dùng GitHub Actions miễn phí
3. **Build time**: GitHub Actions build mất 5-10 phút
4. **File size**: APK sẽ khoảng 15-20MB

## 🆘 Nếu vẫn gặp vấn đề

1. **Kiểm tra workflow logs** trong GitHub Actions
2. **Đảm bảo pubspec.yaml** có đúng dependencies
3. **Kiểm tra AndroidManifest.xml** có đầy đủ permissions
4. **Test code** trước khi push: `flutter analyze && flutter test`

Việc build APK trên Replit khó khăn do thiếu Android SDK, nhưng GitHub Actions là giải pháp tốt nhất!