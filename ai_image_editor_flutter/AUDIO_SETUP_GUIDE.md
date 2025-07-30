# 🎵 Hướng dẫn thiết lập nhạc nền cho TwinkBSA

## Cách thêm nhạc nền

1. **Tải nhạc nền mà bạn muốn sử dụng** (định dạng MP3)
   - Thời lượng khuyến nghị: 2-5 phút (sẽ lặp lại tự động)
   - Kích thước khuyến nghị: dưới 5MB để tối ưu hiệu suất app

2. **Đặt tên file là `background_music.mp3`**

3. **Copy file vào thư mục:**
   ```
   ai_image_editor_flutter/assets/audio/background_music.mp3
   ```

4. **Build lại APK để áp dụng thay đổi:**
   ```bash
   cd ai_image_editor_flutter
   flutter clean
   flutter pub get
   flutter build apk --release
   ```

## Nguồn nhạc miễn phí bản quyền

- **YouTube Audio Library**: https://studio.youtube.com/channel/UC.../music
- **Freesound.org**: https://freesound.org/
- **Pixabay Music**: https://pixabay.com/music/
- **Incompetech.com**: https://incompetech.com/music/
- **Zapsplat**: https://www.zapsplat.com/

## Điều khiển nhạc nền

- **Nút âm thanh**: Góc phải trên cùng màn hình splash và header chính
- **Tắt/bật âm**: Tap vào biểu tượng loa
- **Điều chỉnh âm lượng**: Kéo thanh trượt âm lượng
- **Lưu cài đặt**: Tự động lưu vào SharedPreferences

## Lưu ý kỹ thuật

- Nhạc nền sẽ tự động lặp lại
- Cài đặt âm thanh được lưu giữ giữa các lần mở app
- Nếu không có file nhạc, app vẫn hoạt động bình thường (không lỗi)
- Âm lượng mặc định: 30%