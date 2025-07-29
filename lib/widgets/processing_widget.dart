import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ProcessingWidget extends StatelessWidget {
  final String operation;
  final double progress;

  const ProcessingWidget({
    super.key,
    required this.operation,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366f1), Color(0xFF8b5cf6)],
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Center(
              child: SpinKitWave(
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Title
          const Text(
            'AI đang xử lý...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1e293b),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Operation description
          Text(
            operation,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748b),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Progress bar
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFe2e8f0),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366f1), Color(0xFF8b5cf6)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Progress percentage
          Text(
            '${(progress * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6366f1),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Processing info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFf8fafc),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFe2e8f0),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: const Color(0xFF6366f1),
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Vui lòng không thoát ứng dụng trong khi xử lý',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748b),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}