# Hướng Dẫn Hệ Thống API Failover

## Tổng Quan
Ứng dụng Photo Magic đã được tích hợp hệ thống failover tự động cho Clipdrop API để đảm bảo dịch vụ hoạt động liên tục kể cả khi API chính hết credit/quota.

## Cách Hoạt Động

### API Chính và Dự Phòng
- **API Chính**: `2f62a50ae0c0b965c1f54763e90bb44c101d8d1b84b5a670f4a6bd336954ec2c77f3c3b28ad0c1c9271fcfdfa2abc664`
- **API Dự Phòng**: `7ce6a169f98dc2fb224fc5ad1663c53716b1ee3332fc7a3903dc8a5092feb096731cf4a19f9989cb2901351e1c086ff2`

### Quá Trình Tự Động Chuyển Đổi
1. **Bình Thường**: Ứng dụng sử dụng API chính
2. **Phát Hiện Lỗi**: Khi API chính trả về lỗi quota/credit (HTTP 429, 402)
3. **Chuyển Đổi**: Tự động chuyển sang API dự phòng
4. **Thử Lại**: Thực hiện lại request với API dự phòng
5. **Thông Báo**: Hiển thị thông báo cho user về việc chuyển đổi

### Các Loại Lỗi Được Xử Lý
- **HTTP 429**: Too Many Requests (vượt quá giới hạn)
- **HTTP 402**: Payment Required (hết credit)
- **Quota Messages**: Thông báo chứa từ khóa "quota" hoặc "credit"

## Tính Năng Nâng Cao

### Theo Dõi Trạng Thái API
```dart
// Kiểm tra API nào đang được sử dụng
bool usingBackup = ClipDropService().isUsingBackupApi;

// Lấy tên API hiện tại
String apiStatus = ClipDropService().currentApiStatus;

// Reset về API chính (nếu cần)
ClipDropService().resetToPrimaryApi();
```

### Thông Báo Lỗi Chi Tiết
Tất cả thông báo lỗi sẽ hiển thị API nào đang được sử dụng:
- `"API key không hợp lệ - API chính"`
- `"Đã vượt quá giới hạn API - API dự phòng"`
- `"Lỗi kết nối: [chi tiết] - API chính"`

## Các Tình Huống Xử Lý

### Tình Huống 1: API Chính Hết Credit
1. User thực hiện tác vụ chỉnh sửa ảnh
2. API chính trả về lỗi 429/402
3. Hệ thống tự động chuyển sang API dự phòng
4. Thực hiện lại tác vụ với API dự phòng
5. Trả về kết quả thành công cho user

### Tình Huống 2: Cả Hai API Đều Hết Credit
1. API chính đã chuyển sang dự phòng trước đó
2. API dự phòng cũng trả về lỗi quota
3. Hiển thị thông báo: "Cả hai API đều đã hết credit/quota. Vui lòng thử lại sau hoặc liên hệ để nạp thêm credit."

### Tình Huống 3: Lỗi Không Liên Quan Đến Quota
- Lỗi mạng, lỗi xác thực, v.v. sẽ không trigger failover
- Hiển thị thông báo lỗi cụ thể với thông tin API đang sử dụng

## Lợi Ích

### Cho User
- **Trải nghiệm liên tục**: Không bị gián đoạn khi API hết credit
- **Minh bạch**: Biết được API nào đang được sử dụng
- **Tin cậy**: Giảm thiểu downtime

### Cho Developer
- **Tự động hóa**: Không cần can thiệp thủ công
- **Monitoring**: Dễ dàng theo dõi trạng thái API
- **Scalability**: Có thể mở rộng thêm nhiều API backup

## Implementation Details

### File Chính: `lib/services/clipdrop_service.dart`

#### Các Method Quan Trọng:
- `_executeWithFailover()`: Wrapper thực hiện failover
- `_switchToBackupApi()`: Chuyển sang API dự phòng
- `_resetToPrimaryApi()`: Reset về API chính
- `isUsingBackupApi`: Getter kiểm tra trạng thái
- `currentApiStatus`: Getter lấy tên API hiện tại

#### Tất Cả Tính Năng Có Failover:
- Background removal
- Object cleanup
- Text/logo removal
- Image uncropping
- Image upscaling
- Image reimagining
- Product photography
- Text-to-image generation
- Background replacement

## Testing

### Cách Test Failover
1. Temporary modify primary API key thành key không hợp lệ
2. Thực hiện tác vụ chỉnh sửa ảnh
3. Verify app tự động chuyển sang backup API
4. Restore primary API key
5. Test reset functionality

### Log Messages
- `"Đã chuyển sang API dự phòng do API chính hết credit"`
- `"API chính hết credit/quota, đang chuyển sang API dự phòng..."`
- `"Đã reset về API chính"`

## Maintenance

### Thêm API Backup Mới
1. Khai báo API key mới trong constants
2. Modify `_switchToBackupApi()` để support multiple backup APIs
3. Update failover logic để thử từng API theo thứ tự

### Monitoring & Analytics
- Log API usage để track credit consumption
- Monitor failover frequency
- Alert khi cả hai API gần hết credit

---

*Tài liệu này mô tả hệ thống failover tự động được implement vào ngày 27/07/2025 để nâng cao độ tin cậy của ứng dụng Photo Magic.*