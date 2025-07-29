# 🎵 Hướng dẫn thêm nhạc nền cho TwinkBSA

## 📁 Cấu trúc thư mục audio

```
assets/
  audio/
    background_music.mp3     # Nhạc nền chính
    click_sound.mp3          # Âm thanh click
    processing_sound.mp3     # Âm thanh khi xử lý
    success_sound.mp3        # Âm thanh thành công
```

## 🎶 Cách thêm nhạc nền

### Bước 1: Chuẩn bị file nhạc
- **Format:** MP3, WAV, AAC (khuyến nghị MP3)
- **Chất lượng:** 128-320 kbps
- **Thời lượng:** 2-5 phút (sẽ lặp lại tự động)
- **Kích thước:** < 5MB để ứng dụng không quá nặng

### Bước 2: Thêm file vào project
1. Copy file nhạc vào thư mục `assets/audio/`
2. Đổi tên thành `background_music.mp3`
3. Hoặc cập nhật tên file trong `audio_service.dart`

### Bước 3: Cập nhật AudioService
Mở file `lib/services/audio_service.dart` và tìm dòng:

```dart
// await _audioPlayer.play(AssetSource('audio/background_music.mp3'));
```

Bỏ comment (xóa //) để kích hoạt:

```dart
await _audioPlayer.play(AssetSource('audio/background_music.mp3'));
```

### Bước 4: Thêm permission cho Android
File `android/app/src/main/AndroidManifest.xml` đã có permission:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

## 🎛️ Tính năng Audio hiện tại

### ✅ Đã triển khai:
- **Audio Service**: Quản lý toàn bộ âm thanh ứng dụng
- **Background Music**: Nhạc nền lặp lại liên tục
- **Volume Control**: Điều chỉnh âm lượng (0-100%)
- **Mute/Unmute**: Tắt/bật âm thanh
- **Sound Effects**: Click, Processing, Success sounds
- **Settings Storage**: Lưu trữ tùy chọn âm thanh

### 🎵 Audio Controls:
- **Tap**: Tắt/bật âm thanh
- **Long Press**: Hiển thị thanh điều chỉnh âm lượng
- **Slider**: Điều chỉnh âm lượng từ 0-100%

## 📱 Vị trí Audio Controls

### Splash Screen:
- **Vị trí**: Góc trên-phải
- **Màu**: Trắng với nền trong suốt
- **Tự động**: Bắt đầu phát nhạc khi mở app

### Main Screen:
- **Tích hợp**: Trong header hoặc settings
- **Kiểm soát**: Pause/Resume khi chuyển tab

## 🔧 Tùy chỉnh nâng cao

### Thay đổi âm lượng mặc định:
```dart
double _volume = 0.5; // 50% thay vì 30%
```

### Thêm fade in/out effect:
```dart
await _audioPlayer.setVolume(0.0);
await _audioPlayer.play(AssetSource('audio/background_music.mp3'));
// Gradually increase volume
for (double vol = 0.0; vol <= _volume; vol += 0.1) {
  await _audioPlayer.setVolume(vol);
  await Future.delayed(Duration(milliseconds: 100));
}
```

### Thay đổi chế độ phát:
```dart
await _audioPlayer.setReleaseMode(ReleaseMode.stop); // Phát 1 lần
await _audioPlayer.setReleaseMode(ReleaseMode.loop); // Lặp lại
```

## 🎯 Gợi ý nhạc nền phù hợp

### Thể loại phù hợp:
- **Lo-fi Hip Hop**: Thư giãn, không gây phân tâm
- **Ambient**: Nhẹ nhàng, tạo không khí
- **Instrumental**: Tập trung vào công việc
- **Chillwave**: Hiện đại, phù hợp UI gradient

### Tránh:
- **Vocals**: Có thể gây phân tâm
- **Beat mạnh**: Không phù hợp với workflow editing
- **Âm lượng thay đổi đột ngột**: Gây khó chịu

## 📝 Lưu ý bản quyền

- **Sử dụng nhạc không bản quyền** (Creative Commons, Royalty-free)
- **Mua license** cho nhạc thương mại
- **Tự sản xuất** hoặc thuê nhạc sĩ
- **Credit**: Ghi rõ nguồn nhạc trong app

## 🔧 Debug Audio

### Kiểm tra console logs:
```
🎵 Background music would play here
📁 Add your music file to: assets/audio/background_music.mp3
🔊 Click sound effect
```

### Common issues:
1. **File không tìm thấy**: Kiểm tra đường dẫn trong pubspec.yaml
2. **Format không hỗ trợ**: Chuyển sang MP3
3. **File quá lớn**: Nén xuống < 5MB
4. **Permission denied**: Kiểm tra AndroidManifest.xml

## 🚀 Build & Deploy

Sau khi thêm nhạc:
```bash
flutter clean
flutter pub get
flutter build apk --release
```

Audio sẽ được đóng gói vào APK và hoạt động offline.