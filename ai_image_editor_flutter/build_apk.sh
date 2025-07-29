#!/bin/bash

# Script tự động build APK cho AI Image Editor
# Chạy: bash build_apk.sh

echo "🚀 Bắt đầu build APK cho AI Image Editor..."

# Kiểm tra Flutter
echo "📋 Kiểm tra Flutter..."
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter chưa được cài đặt. Vui lòng cài Flutter trước."
    exit 1
fi

echo "✅ Flutter đã sẵn sàng"
flutter --version

# Kiểm tra thư mục dự án
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Không tìm thấy file pubspec.yaml. Vui lòng chạy script trong thư mục ai_image_editor_flutter"
    exit 1
fi

# Kiểm tra API key
echo "🔑 Kiểm tra API key..."
if grep -q "YOUR_CLIPDROP_API_KEY" lib/services/clipdrop_service.dart; then
    echo "⚠️  CẢNH BÁO: API key chưa được cấu hình!"
    echo "   Vui lòng thay 'YOUR_CLIPDROP_API_KEY' trong lib/services/clipdrop_service.dart"
    echo "   Lấy API key tại: https://clipdrop.co/apis"
    read -p "Bạn có muốn tiếp tục build APK không? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Clean project
echo "🧹 Dọn dẹp project..."
flutter clean

# Cài đặt dependencies
echo "📦 Cài đặt dependencies..."
flutter pub get

# Chạy analyze để kiểm tra lỗi
echo "🔍 Kiểm tra lỗi code..."
flutter analyze --no-fatal-infos

# Chạy tests
echo "🧪 Chạy tests..."
flutter test

# Hỏi loại APK muốn build
echo "📱 Chọn loại APK muốn build:"
echo "1. Debug APK (để test, kích thước lớn)"
echo "2. Release APK (để phát hành, tối ưu)"
echo "3. Split APK (tối ưu kích thước, nhiều file)"
read -p "Nhập lựa chọn (1-3): " choice

case $choice in
    1)
        echo "🔨 Build Debug APK..."
        flutter build apk --debug
        apk_path="build/app/outputs/flutter-apk/app-debug.apk"
        ;;
    2)
        echo "🔨 Build Release APK..."
        flutter build apk --release
        apk_path="build/app/outputs/flutter-apk/app-release.apk"
        ;;
    3)
        echo "🔨 Build Split APK..."
        flutter build apk --release --split-per-abi
        apk_path="build/app/outputs/flutter-apk/"
        ;;
    *)
        echo "❌ Lựa chọn không hợp lệ"
        exit 1
        ;;
esac

# Kiểm tra kết quả
if [ $choice -eq 3 ]; then
    if [ -d "$apk_path" ] && [ "$(ls -A $apk_path)" ]; then
        echo "✅ Build thành công!"
        echo "📁 APK files được tạo tại: $apk_path"
        ls -la "$apk_path"*.apk 2>/dev/null || echo "Files: $(ls $apk_path*.apk 2>/dev/null | wc -l) APK files"
    else
        echo "❌ Build thất bại!"
        exit 1
    fi
else
    if [ -f "$apk_path" ]; then
        echo "✅ Build thành công!"
        echo "📁 APK file: $apk_path"
        echo "📊 Kích thước: $(du -h "$apk_path" | cut -f1)"
    else
        echo "❌ Build thất bại!"
        exit 1
    fi
fi

# Hướng dẫn cài đặt
echo ""
echo "📲 Hướng dẫn cài đặt:"
echo "1. Copy APK file vào điện thoại Android"
echo "2. Bật 'Unknown sources' trong Settings > Security"
echo "3. Tap vào APK file để cài đặt"
echo ""
echo "🔧 Hoặc cài qua USB:"
echo "   flutter install"
echo ""
echo "🎉 Hoàn thành!"