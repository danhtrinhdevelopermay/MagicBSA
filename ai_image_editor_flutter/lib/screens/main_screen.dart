import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/image_provider.dart';
import '../widgets/image_upload_widget.dart';
import '../widgets/enhanced_editor_widget.dart';

import '../widgets/result_widget.dart';
import '../widgets/loading_overlay_widget.dart';
import 'history_screen.dart';
import 'premium_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style for main screen
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
    ));
    
    return Consumer<ImageEditProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          extendBodyBehindAppBar: true,
          extendBody: true,
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              // Main content with PageView
              PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: [
                  _buildHomeScreen(),
                  const HistoryScreen(),
                  const PremiumScreen(),
                  const ProfileScreen(),
                ],
              ),
              
              // Bottom Navigation
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomNavigation(),
              ),
              
              // Full-screen loading overlay
              if (provider.state == ProcessingState.processing)
                Positioned.fill(
                  child: LoadingOverlayWidget(
                    message: 'Đang xử lý...',
                    isVisible: provider.state == ProcessingState.processing,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHomeScreen() {
    return Consumer<ImageEditProvider>(
      builder: (context, provider, child) {
        return SafeArea(
          top: true,
          bottom: false,
          child: Column(
            children: [
              // Header
              _buildHeader(context),
              
              // Main content
              Expanded(
                child: _buildMainContent(context, provider),
              ),
              
              // Bottom padding for navigation
              const SizedBox(height: 90),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/app_icon.png',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6366f1), Color(0xFF8b5cf6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_fix_high,
                      color: Colors.white,
                      size: 16,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'TwinkBSA',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1e293b),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.settings_outlined,
              color: Color(0xFF64748b),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, ImageEditProvider provider) {
    // Check if an image is selected but not yet processing
    if (provider.originalImage != null && provider.state == ProcessingState.idle) {
      return EnhancedEditorWidget(
        originalImage: provider.originalImage!,
      );
    }
    
    switch (provider.state) {
      case ProcessingState.idle:
        return const ImageUploadWidget();
      case ProcessingState.picking:
        return const ImageUploadWidget();
      case ProcessingState.processing:
        return const ImageUploadWidget(); // Show upload widget since overlay handles processing UI
      case ProcessingState.completed:
        return ResultWidget(
          originalImage: provider.originalImage,
          processedImage: provider.processedImage!,
          onStartOver: () => provider.reset(),
        );
      case ProcessingState.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Color(0xFFef4444),
              ),
              const SizedBox(height: 16),
              Text(
                provider.errorMessage.isNotEmpty ? provider.errorMessage : 'Đã xảy ra lỗi',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF64748b),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => provider.reset(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366f1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFe2e8f0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Trang chủ',
                isActive: _currentIndex == 0,
                onTap: () => _onTabTapped(0),
              ),
              _buildNavItem(
                icon: Icons.history_outlined,
                activeIcon: Icons.history,
                label: 'Lịch sử',
                isActive: _currentIndex == 1,
                onTap: () => _onTabTapped(1),
              ),
              _buildNavItem(
                icon: Icons.star_border,
                activeIcon: Icons.star,
                label: 'Premium',
                isActive: _currentIndex == 2,
                onTap: () => _onTabTapped(2),
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Hồ sơ',
                isActive: _currentIndex == 3,
                onTap: () => _onTabTapped(3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF6366f1).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey(isActive),
                color: isActive ? const Color(0xFF6366f1) : const Color(0xFF94a3b8),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? const Color(0xFF6366f1) : const Color(0xFF64748b),
              ),
              child: Text(label),
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 2),
                height: 2,
                width: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366f1),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
          ],
        ),
      ),
    );
  }
}