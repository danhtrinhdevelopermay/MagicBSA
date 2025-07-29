import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

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
              child: _buildHistoryContent(),
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
              Icons.history,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Lịch sử chỉnh sửa',
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

  Widget _buildHistoryContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Filter tabs
          _buildFilterTabs(),
          const SizedBox(height: 16),
          
          // History list
          Expanded(
            child: _buildHistoryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildFilterTab('Tất cả', true),
          _buildFilterTab('Hôm nay', false),
          _buildFilterTab('Tuần này', false),
          _buildFilterTab('Tháng này', false),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String title, bool isActive) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isActive ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ] : null,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? const Color(0xFF6366f1) : const Color(0xFF64748b),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    // Sample history data
    final historyItems = [
      {
        'title': 'Xóa nền ảnh chân dung',
        'time': '2 phút trước',
        'type': 'background_removal',
        'thumbnail': 'https://via.placeholder.com/60x60/6366f1/ffffff?text=BG',
      },
      {
        'title': 'Chỉnh sửa ảnh sản phẩm',
        'time': '15 phút trước',
        'type': 'cleanup',
        'thumbnail': 'https://via.placeholder.com/60x60/8b5cf6/ffffff?text=CL',
      },
      {
        'title': 'Tạo ảnh từ văn bản',
        'time': '1 giờ trước',
        'type': 'text_to_image',
        'thumbnail': 'https://via.placeholder.com/60x60/ec4899/ffffff?text=TI',
      },
      {
        'title': 'Mở rộng ảnh',
        'time': 'Hôm qua',
        'type': 'uncrop',
        'thumbnail': 'https://via.placeholder.com/60x60/10b981/ffffff?text=UC',
      },
    ];

    if (historyItems.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: historyItems.length,
      itemBuilder: (context, index) {
        final item = historyItems[index];
        return _buildHistoryItem(item);
      },
    );
  }

  Widget _buildHistoryItem(Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: _getGradientForType(item['type']!),
            ),
            child: Icon(
              _getIconForType(item['type']!),
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title']!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1e293b),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['time']!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748b),
                  ),
                ),
              ],
            ),
          ),
          
          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.download_outlined,
                  size: 20,
                  color: Color(0xFF64748b),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.share_outlined,
                  size: 20,
                  color: Color(0xFF64748b),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.history,
              size: 40,
              color: Color(0xFF94a3b8),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có lịch sử chỉnh sửa',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748b),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Các ảnh bạn đã chỉnh sửa sẽ xuất hiện ở đây',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF94a3b8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  LinearGradient _getGradientForType(String type) {
    switch (type) {
      case 'background_removal':
        return const LinearGradient(
          colors: [Color(0xFF6366f1), Color(0xFF8b5cf6)],
        );
      case 'cleanup':
        return const LinearGradient(
          colors: [Color(0xFF8b5cf6), Color(0xFFec4899)],
        );
      case 'text_to_image':
        return const LinearGradient(
          colors: [Color(0xFFec4899), Color(0xFFf97316)],
        );
      case 'uncrop':
        return const LinearGradient(
          colors: [Color(0xFF10b981), Color(0xFF3b82f6)],
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF6366f1), Color(0xFF8b5cf6)],
        );
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'background_removal':
        return Icons.layers_clear;
      case 'cleanup':
        return Icons.cleaning_services;
      case 'text_to_image':
        return Icons.text_fields;
      case 'uncrop':
        return Icons.crop_free;
      default:
        return Icons.image;
    }
  }
}