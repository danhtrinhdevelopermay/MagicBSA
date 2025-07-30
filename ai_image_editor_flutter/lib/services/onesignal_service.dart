import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service quản lý OneSignal push notifications cho TwinkBSA app
class OneSignalService {
  static const String _oneSignalAppId = "a503a5c7-6b11-404a-b0ea-8505fdaf59e8"; // OneSignal App ID
  static const String _userIdKey = "onesignal_user_id";
  
  static OneSignalService? _instance;
  static OneSignalService get instance => _instance ??= OneSignalService._();
  
  OneSignalService._();
  
  /// Khởi tạo OneSignal service
  static Future<void> initialize() async {
    try {
      // Debug mode - remove trong production
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      
      // Khởi tạo OneSignal với App ID
      OneSignal.initialize(_oneSignalAppId);
      
      // Yêu cầu permission cho notifications
      await OneSignal.Notifications.requestPermission(true);
      
      // Lắng nghe khi nhận notification trong foreground
      OneSignal.Notifications.addForegroundWillDisplayListener(_onForegroundWillDisplay);
      
      // Lắng nghe khi user click vào notification
      OneSignal.Notifications.addClickListener(_onNotificationClick);
      
      // Lắng nghe khi permission thay đổi
      OneSignal.Notifications.addPermissionObserver(_onPermissionChange);
      
      // Lưu User ID để sử dụng sau
      final userId = OneSignal.User.pushSubscription.id;
      if (userId != null) {
        await _saveUserId(userId);
      }
      
      print("OneSignal đã được khởi tạo thành công");
    } catch (e) {
      print("Lỗi khởi tạo OneSignal: $e");
    }
  }
  
  /// Xử lý notification khi app đang mở (foreground)
  static void _onForegroundWillDisplay(OSNotificationWillDisplayEvent event) {
    print("Nhận notification trong foreground: ${event.notification.body}");
    
    // Có thể tùy chỉnh notification trước khi hiển thị
    event.notification.display();
  }
  
  /// Xử lý khi user click vào notification
  static void _onNotificationClick(OSNotificationClickEvent event) {
    print("User click vào notification: ${event.notification.body}");
    
    // Xử lý navigation hoặc action dựa trên notification data
    final additionalData = event.notification.additionalData;
    if (additionalData != null) {
      if (additionalData.containsKey('screen')) {
        _navigateToScreen(additionalData['screen']);
      }
    }
  }
  
  /// Xử lý khi notification permission thay đổi
  static void _onPermissionChange(bool granted) {
    print("Notification permission: ${granted ? 'Cho phép' : 'Từ chối'}");
  }
  
  /// Navigation đến màn hình cụ thể từ notification
  static void _navigateToScreen(String screen) {
    switch (screen) {
      case 'history':
        // Navigate to history screen
        print("Chuyển đến màn hình Lịch sử");
        break;
      case 'premium':
        // Navigate to premium screen
        print("Chuyển đến màn hình Premium");
        break;
      case 'profile':
        // Navigate to profile screen
        print("Chuyển đến màn hình Hồ sơ");
        break;
      default:
        // Navigate to home screen
        print("Chuyển đến màn hình Trang chủ");
        break;
    }
  }
  
  /// Lưu OneSignal User ID vào SharedPreferences
  static Future<void> _saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    print("Đã lưu OneSignal User ID: $userId");
  }
  
  /// Lấy OneSignal User ID đã lưu
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }
  
  /// Đặt external user ID (ví dụ: user ID từ database)
  static Future<void> setExternalUserId(String externalId) async {
    try {
      OneSignal.login(externalId);
      print("Đã đặt External User ID: $externalId");
    } catch (e) {
      print("Lỗi đặt External User ID: $e");
    }
  }
  
  /// Gửi tag để phân loại user
  static Future<void> sendTags(Map<String, String> tags) async {
    try {
      OneSignal.User.addTags(tags);
      print("Đã gửi tags: $tags");
    } catch (e) {
      print("Lỗi gửi tags: $e");
    }
  }
  
  /// Gỡ tag
  static Future<void> removeTags(List<String> tagKeys) async {
    try {
      OneSignal.User.removeTags(tagKeys);
      print("Đã gỡ tags: $tagKeys");
    } catch (e) {
      print("Lỗi gỡ tags: $e");
    }
  }
  
  /// Bật/tắt push notifications
  static Future<void> setPushNotificationEnabled(bool enabled) async {
    try {
      OneSignal.User.pushSubscription.optIn();
      if (!enabled) {
        OneSignal.User.pushSubscription.optOut();
      }
      print("Push notifications: ${enabled ? 'Bật' : 'Tắt'}");
    } catch (e) {
      print("Lỗi thiết lập push notifications: $e");
    }
  }
  
  /// Kiểm tra trạng thái permission
  static Future<bool> hasNotificationPermission() async {
    try {
      final permission = await OneSignal.Notifications.permission;
      return permission;
    } catch (e) {
      print("Lỗi kiểm tra permission: $e");
      return false;
    }
  }
  
  /// Gửi notification test (chỉ dùng cho development)
  static Future<void> sendTestNotification() async {
    final userId = await getUserId();
    if (userId != null) {
      print("Gửi test notification đến User ID: $userId");
      // Thực tế cần sử dụng OneSignal REST API để gửi notification
    }
  }
}