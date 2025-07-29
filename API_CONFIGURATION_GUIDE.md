# Hướng dẫn cấu hình API Clipdroph

## Tổng quan
Ứng dụng Photo Magic sử dụng Clipdrop API để thực hiện các tính năng chỉnh sửa ảnh bằng AI. Để sử dụng app, bạn cần có API key từ Clipdrop.

## Cách lấy API Key

### Bước 1: Truy cập Clipdrop
1. Mở trình duyệt và truy cập: https://clipdrop.co/apis
2. Đăng ký tài khoản mới hoặc đăng nhập nếu đã có tài khoản

### Bước 2: Tạo API Key
1. Sau khi đăng nhập, vào dashboard
2. Chọn "API Keys" hoặc "Create API Key"
3. Đặt tên cho API key (ví dụ: "Photo Magic App")
4. Sao chép API key vừa tạo

### Bước 3: Cấu hình trong App
1. Mở ứng dụng Photo Magic
2. Chạm vào icon menu (3 gạch) ở góc phải màn hình chính
3. Chọn "Cài đặt API"
4. Dán API key vào trường "API Key chính"
5. (Tùy chọn) Thêm API key dự phòng để tăng độ tin cậy
6. Chạm "Lưu cấu hình"

## Tính năng API dự phòng
- App hỗ trợ 2 API keys để tăng độ tin cậy
- Khi API chính hết credit hoặc gặp lỗi, app sẽ tự động chuyển sang API dự phòng
- Điều này giúp app hoạt động liên tục ngay cả khi một API key gặp vấn đề

## Các lỗi thường gặp

### Lỗi 403 - Không có quyền truy cập
- **Nguyên nhân**: API key không hợp lệ hoặc đã hết hạn
- **Giải pháp**: Kiểm tra lại API key, tạo API key mới nếu cần

### Lỗi 402 - Hết credit
- **Nguyên nhân**: Tài khoản Clipdrop đã hết credit
- **Giải pháp**: Nạp thêm credit vào tài khoản Clipdrop

### Lỗi 429 - Vượt quá giới hạn
- **Nguyên nhân**: Đã sử dụng quá nhiều request trong khoảng thời gian ngắn
- **Giải pháp**: Đợi một lúc rồi thử lại, hoặc nâng cấp gói dịch vụ

## Bảo mật
- API key được lưu trữ an toàn trên thiết bị của bạn
- Không chia sẻ API key với người khác
- App không gửi API key của bạn đến bất kỳ server nào khác ngoài Clipdrop

## Hỗ trợ
Nếu gặp vấn đề với API key hoặc cần hỗ trợ thêm:
1. Kiểm tra tài khoản Clipdrop của bạn
2. Đảm bảo có đủ credit
3. Thử tạo API key mới
4. Kiểm tra kết nối internet
