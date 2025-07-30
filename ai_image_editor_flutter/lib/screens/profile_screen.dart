import 'package:flutter/material.dart';
import '../services/onesignal_service.dart';
import 'package:flutter/services.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
    ));
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Main content
            Expanded(
              child: _buildProfileContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                colors: [Color(0xFF6366f1), Color(0xFF8b5cf6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Hồ sơ cá nhân',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1e293b),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile card
          _buildProfileCard(),
          const SizedBox(height: 24),
          
          // Stats section
          _buildStatsSection(),
          const SizedBox(height: 24),
          
          // Menu items
          _buildMenuItems(context),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6366f1),
            Color(0xFF8b5cf6),
            Color(0xFFec4899),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366f1).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          // Name
          const Text(
            'Người dùng',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          
          // Subscription status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Gói miễn phí',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thống kê sử dụng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1e293b),
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              _buildStatItem(
                icon: Icons.image,
                label: 'Ảnh đã chỉnh sửa',
                value: '12',
                color: const Color(0xFF6366f1),
              ),
              const SizedBox(width: 20),
              _buildStatItem(
                icon: Icons.timer,
                label: 'Thời gian tiết kiệm',
                value: '2.5h',
                color: const Color(0xFF10b981),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              _buildStatItem(
                icon: Icons.download,
                label: 'Ảnh đã tải về',
                value: '8',
                color: const Color(0xFF8b5cf6),
              ),
              const SizedBox(width: 20),
              _buildStatItem(
                icon: Icons.share,
                label: 'Ảnh đã chia sẻ',
                value: '5',
                color: const Color(0xFFf59e0b),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748b),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final menuItems = [
      {
        'icon': Icons.account_circle_outlined,
        'title': 'Thông tin tài khoản',
        'subtitle': 'Quản lý thông tin cá nhân',
        'onTap': () {},
      },
      {
        'icon': Icons.notifications_outlined,
        'title': 'Thông báo',
        'subtitle': 'Cài đặt thông báo đẩy và cảnh báo',
        'onTap': () => _showNotificationSettings(context),
      },
      {
        'icon': Icons.security_outlined,
        'title': 'Bảo mật & Quyền riêng tư',
        'subtitle': 'Quản lý mật khẩu và quyền riêng tư',
        'onTap': () {},
      },
      {
        'icon': Icons.cloud_outlined,
        'title': 'Sao lưu & Đồng bộ',
        'subtitle': 'Quản lý dữ liệu trên đám mây',
        'onTap': () {},
      },
      {
        'icon': Icons.settings_outlined,
        'title': 'Cài đặt ứng dụng',
        'subtitle': 'Cấu hình API và tùy chọn khác',
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SettingsScreen(),
            ),
          );
        },
      },
      {
        'icon': Icons.notifications_outlined,
        'title': 'Thông báo',
        'subtitle': 'Cài đặt thông báo đẩy',
        'onTap': () => _showNotificationSettings(context),
      },
      {
        'icon': Icons.help_outline,
        'title': 'Trợ giúp & Hỗ trợ',
        'subtitle': 'FAQ và liên hệ hỗ trợ',
        'onTap': () {},
      },
      {
        'icon': Icons.star_outline,
        'title': 'Đánh giá ứng dụng',
        'subtitle': 'Chia sẻ trải nghiệm của bạn',
        'onTap': () {},
      },
      {
        'icon': Icons.info_outline,
        'title': 'Giới thiệu',
        'subtitle': 'Phiên bản 1.0.0',
        'onTap': () => _showAboutDialog(context),
      },
    ];

    return Column(
      children: menuItems.map((item) => _buildMenuItem(
        icon: item['icon'] as IconData,
        title: item['title'] as String,
        subtitle: item['subtitle'] as String,
        onTap: item['onTap'] as VoidCallback,
      )).toList(),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF6366f1),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1e293b),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748b),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF94a3b8),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _NotificationSettingsDialog(),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366f1), Color(0xFF8b5cf6)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.auto_fix_high,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Photo Magic'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ứng dụng chỉnh sửa ảnh AI mạnh mẽ với công nghệ Clipdrop.',
            ),
            SizedBox(height: 16),
            Text('Phiên bản: 1.0.0'),
            Text('Được phát triển với ❤️'),
            SizedBox(height: 16),
            Text(
              '© 2025 Photo Magic. Tất cả quyền được bảo lưu.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF64748b),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}

class _NotificationSettingsDialog extends StatefulWidget {
  @override
  _NotificationSettingsDialogState createState() => _NotificationSettingsDialogState();
}

class _NotificationSettingsDialogState extends State<_NotificationSettingsDialog> {
  bool _pushNotificationsEnabled = true;
  bool _processingNotifications = true;
  bool _promotionalNotifications = false;
  bool _newsUpdates = true;
  String? _oneSignalUserId;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    // Load OneSignal User ID
    final userId = await OneSignalService.getUserId();
    final hasPermission = await OneSignalService.hasNotificationPermission();
    
    setState(() {
      _oneSignalUserId = userId;
      _pushNotificationsEnabled = hasPermission;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF6366f1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF6366f1),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text('Cài đặt thông báo'),
        ],
      ),
      content: Container(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // OneSignal Status
            if (_oneSignalUserId != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'OneSignal đã được kích hoạt',
                        style: TextStyle(
                          color: const Color(0xFF065F46),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            
            // Push Notifications Toggle
            _buildNotificationToggle(
              title: 'Thông báo đẩy',
              subtitle: 'Nhận thông báo từ ứng dụng',
              value: _pushNotificationsEnabled,
              onChanged: (value) async {
                await OneSignalService.setPushNotificationEnabled(value);
                setState(() {
                  _pushNotificationsEnabled = value;
                });
              },
            ),
            
            const Divider(height: 24),
            
            // Processing Notifications
            _buildNotificationToggle(
              title: 'Thông báo xử lý ảnh',
              subtitle: 'Thông báo khi ảnh được xử lý xong',
              value: _processingNotifications,
              onChanged: (value) {
                setState(() {
                  _processingNotifications = value;
                });
                _updateTags();
              },
            ),
            
            // Promotional Notifications
            _buildNotificationToggle(
              title: 'Thông báo khuyến mãi',
              subtitle: 'Nhận thông báo về ưu đãi đặc biệt',
              value: _promotionalNotifications,
              onChanged: (value) {
                setState(() {
                  _promotionalNotifications = value;
                });
                _updateTags();
              },
            ),
            
            // News Updates
            _buildNotificationToggle(
              title: 'Tin tức cập nhật',
              subtitle: 'Thông báo về tính năng mới',
              value: _newsUpdates,
              onChanged: (value) {
                setState(() {
                  _newsUpdates = value;
                });
                _updateTags();
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Đóng'),
        ),
        ElevatedButton(
          onPressed: () async {
            // Send test notification
            await OneSignalService.sendTestNotification();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã gửi thông báo thử nghiệm'),
                backgroundColor: Color(0xFF10B981),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366f1),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Thử nghiệm'),
        ),
      ],
    );
  }

  Widget _buildNotificationToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1e293b),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748b),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF6366f1),
          ),
        ],
      ),
    );
  }

  void _updateTags() {
    final tags = <String, String>{};
    
    if (_processingNotifications) {
      tags['processing_notifications'] = 'true';
    }
    if (_promotionalNotifications) {
      tags['promotional_notifications'] = 'true';
    }
    if (_newsUpdates) {
      tags['news_updates'] = 'true';
    }
    
    OneSignalService.sendTags(tags);
  }
}