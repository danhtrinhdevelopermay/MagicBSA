import 'dart:io';
import 'package:flutter/material.dart';

class ImageEditorWidget extends StatelessWidget {
  final File imageFile;
  final VoidCallback onRemoveBackground;
  final VoidCallback onRemoveText;
  final VoidCallback onCleanup;
  final VoidCallback onRemoveLogo;
  final bool isProcessing;

  const ImageEditorWidget({
    super.key,
    required this.imageFile,
    required this.onRemoveBackground,
    required this.onRemoveText,
    required this.onCleanup,
    required this.onRemoveLogo,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 24),
          
          // Image preview
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.file(
                  imageFile,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Action buttons in grid layout
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildCompactActionButton(
                onPressed: isProcessing ? null : onRemoveBackground,
                icon: Icons.content_cut,
                title: 'Xóa Background',
                color: const Color(0xFF2563eb),
                isLoading: isProcessing,
              ),
              _buildCompactActionButton(
                onPressed: isProcessing ? null : onRemoveText,
                icon: Icons.text_format,
                title: 'Xóa Văn Bản',
                color: const Color(0xFF16a34a),
                isLoading: isProcessing,
              ),
              _buildCompactActionButton(
                onPressed: isProcessing ? null : onCleanup,
                icon: Icons.auto_fix_high,
                title: 'Dọn Dẹp',
                color: const Color(0xFF9333ea),
                isLoading: isProcessing,
              ),
              _buildCompactActionButton(
                onPressed: isProcessing ? null : onRemoveLogo,
                icon: Icons.shield_outlined,
                title: 'Xóa Logo',
                color: const Color(0xFFdc2626),
                isLoading: isProcessing,
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Tips section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF6366f1).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF6366f1).withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: const Color(0xFF6366f1),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Mẹo sử dụng',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1e293b),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Xóa Background: Tự động loại bỏ nền ảnh\n'
                  '• Xóa Văn Bản: Phát hiện và xóa text trong ảnh\n'
                  '• Dọn Dẹp: Xóa đối tượng không mong muốn\n'
                  '• Xóa Logo: Loại bỏ logo hoặc watermark',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748b),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactActionButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String title,
    required Color color,
    bool isLoading = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: onPressed != null ? const Color(0xFF1e293b) : const Color(0xFF94a3b8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required bool isLoading,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: onPressed != null ? gradient : null,
            color: onPressed == null ? Colors.grey.shade300 : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                if (isLoading && onPressed == null)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}