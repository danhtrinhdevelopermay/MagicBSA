import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
    ));
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6366f1),
              Color(0xFF8b5cf6),
              Color(0xFFec4899),
            ],
          ),
        ),
        child: SafeArea(
          top: true,
          bottom: false,
          child: Column(
            children: [
              // Header
              _buildHeader(context),
              
              // Main content
              Expanded(
                child: _buildPremiumContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.star,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Photo Magic Premium',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Hero section
          _buildHeroSection(),
          const SizedBox(height: 32),
          
          // Features
          _buildFeatures(),
          const SizedBox(height: 32),
          
          // Pricing plans
          _buildPricingPlans(),
          const SizedBox(height: 32),
          
          // CTA Button
          _buildCTAButton(),
          const SizedBox(height: 16),
          
          // Terms
          _buildTerms(),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(
            Icons.auto_awesome,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Nâng cấp trải nghiệm',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Mở khóa tất cả tính năng cao cấp và chỉnh sửa không giới hạn',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeatures() {
    final features = [
      {
        'icon': Icons.all_inclusive,
        'title': 'Chỉnh sửa không giới hạn',
        'description': 'Không có giới hạn số lượng ảnh chỉnh sửa mỗi ngày',
      },
      {
        'icon': Icons.hd,
        'title': 'Chất lượng cao cấp',
        'description': 'Xuất ảnh với độ phân giải và chất lượng tối đa',
      },
      {
        'icon': Icons.speed,
        'title': 'Xử lý nhanh hơn',
        'description': 'Ưu tiên xử lý, giảm thời gian chờ đợi',
      },
      {
        'icon': Icons.auto_awesome,
        'title': 'Tính năng AI mới nhất',
        'description': 'Truy cập sớm các tính năng AI mới và cải tiến',
      },
      {
        'icon': Icons.cloud_sync,
        'title': 'Đồng bộ đám mây',
        'description': 'Lưu trữ và đồng bộ ảnh trên nhiều thiết bị',
      },
      {
        'icon': Icons.support_agent,
        'title': 'Hỗ trợ ưu tiên',
        'description': 'Nhận hỗ trợ kỹ thuật nhanh chóng và ưu tiên',
      },
    ];

    return Column(
      children: features.map((feature) => _buildFeatureItem(feature)).toList(),
    );
  }

  Widget _buildFeatureItem(Map<String, dynamic> feature) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              feature['icon'],
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingPlans() {
    return Column(
      children: [
        const Text(
          'Chọn gói phù hợp',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        
        // Monthly plan
        _buildPricingCard(
          title: 'Gói tháng',
          price: '99.000₫',
          period: '/tháng',
          features: [
            'Tất cả tính năng Premium',
            'Chỉnh sửa không giới hạn',
            'Chất lượng cao cấp',
            'Hỗ trợ ưu tiên',
          ],
          isPopular: false,
        ),
        
        const SizedBox(height: 16),
        
        // Yearly plan
        _buildPricingCard(
          title: 'Gói năm',
          price: '990.000₫',
          period: '/năm',
          originalPrice: '1.188.000₫',
          discount: 'Tiết kiệm 17%',
          features: [
            'Tất cả tính năng Premium',
            'Chỉnh sửa không giới hạn',
            'Chất lượng cao cấp',
            'Hỗ trợ ưu tiên',
            'Tính năng AI mới nhất',
            'Đồng bộ đám mây',
          ],
          isPopular: true,
        ),
      ],
    );
  }

  Widget _buildPricingCard({
    required String title,
    required String price,
    required String period,
    String? originalPrice,
    String? discount,
    required List<String> features,
    required bool isPopular,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPopular ? Colors.white : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular ? Colors.transparent : Colors.white.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          if (isPopular) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF6366f1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'PHỔ BIẾN NHẤT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isPopular ? const Color(0xFF1e293b) : Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isPopular ? const Color(0xFF6366f1) : Colors.white,
                ),
              ),
              Text(
                period,
                style: TextStyle(
                  fontSize: 16,
                  color: isPopular ? const Color(0xFF64748b) : Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
          
          if (originalPrice != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  originalPrice,
                  style: TextStyle(
                    fontSize: 14,
                    decoration: TextDecoration.lineThrough,
                    color: isPopular ? const Color(0xFF94a3b8) : Colors.white.withOpacity(0.6),
                  ),
                ),
                const SizedBox(width: 8),
                if (discount != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10b981),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      discount,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ],
          
          const SizedBox(height: 20),
          
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 20,
                  color: isPopular ? const Color(0xFF10b981) : Colors.white,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    feature,
                    style: TextStyle(
                      fontSize: 14,
                      color: isPopular ? const Color(0xFF64748b) : Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildCTAButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Implement premium purchase
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF6366f1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Bắt đầu dùng thử miễn phí 7 ngày',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTerms() {
    return Column(
      children: [
        Text(
          'Dùng thử miễn phí 7 ngày, sau đó sẽ tự động gia hạn.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {},
              child: Text(
                'Điều khoản sử dụng',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.9),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(width: 16),
            TextButton(
              onPressed: () {},
              child: Text(
                'Chính sách bảo mật',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.9),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}