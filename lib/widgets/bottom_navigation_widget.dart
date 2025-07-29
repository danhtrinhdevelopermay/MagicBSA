import 'package:flutter/material.dart';

class BottomNavigationWidget extends StatelessWidget {
  const BottomNavigationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFe2e8f0), width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.home,
              label: 'Trang chủ',
              isActive: true,
              onTap: () {},
            ),
            _buildNavItem(
              icon: Icons.history,
              label: 'Lịch sử',
              isActive: false,
              onTap: () {},
            ),
            _buildNavItem(
              icon: Icons.star,
              label: 'Premium',
              isActive: false,
              onTap: () {},
            ),
            _buildNavItem(
              icon: Icons.person,
              label: 'Hồ sơ',
              isActive: false,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF6366f1) : const Color(0xFF94a3b8),
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? const Color(0xFF6366f1) : const Color(0xFF94a3b8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}