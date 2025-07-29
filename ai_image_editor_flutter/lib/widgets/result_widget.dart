import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class ResultWidget extends StatefulWidget {
  final File originalImage;
  final Uint8List processedImage;
  final VoidCallback onStartOver;

  const ResultWidget({
    super.key,
    required this.originalImage,
    required this.processedImage,
    required this.onStartOver,
  });

  @override
  State<ResultWidget> createState() => _ResultWidgetState();
}

class _ResultWidgetState extends State<ResultWidget> {
  bool _showComparison = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 24),
          
          // Header with toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kết quả',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1e293b),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showComparison = !_showComparison;
                  });
                },
                icon: const Icon(Icons.compare_arrows),
                label: Text(_showComparison ? 'Chỉ kết quả' : 'So sánh'),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Image display
          Container(
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
              child: _showComparison
                  ? _buildComparisonView()
                  : _buildSingleView(),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Quality info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFf8fafc),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Điểm chất lượng',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748b),
                      ),
                    ),
                    const Text(
                      '98%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF10b981),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Thời gian xử lý',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748b),
                      ),
                    ),
                    const Text(
                      '3.2s',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6366f1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Column(
            children: [
              // Download button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFf59e0b),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download),
                      SizedBox(width: 8),
                      Text(
                        'Tải về',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Secondary actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _shareImage,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.share),
                          SizedBox(width: 4),
                          Text('Chia sẻ'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onStartOver,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 4),
                          Text('Chỉnh sửa thêm'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonView() {
    return Column(
      children: [
        // Labels
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Gốc',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748b),
                  ),
                ),
              ),
              Container(width: 1, height: 12, color: const Color(0xFFe2e8f0)),
              const Expanded(
                child: Text(
                  'Đã chỉnh sửa',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748b),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Images
        AspectRatio(
          aspectRatio: 2,
          child: Row(
            children: [
              Expanded(
                child: Image.file(
                  widget.originalImage,
                  fit: BoxFit.cover,
                ),
              ),
              Container(width: 1, color: const Color(0xFFe2e8f0)),
              Expanded(
                child: Image.memory(
                  widget.processedImage,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSingleView() {
    return AspectRatio(
      aspectRatio: 1,
      child: Image.memory(
        widget.processedImage,
        fit: BoxFit.cover,
      ),
    );
  }

  Future<void> _saveImage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/ai_edited_$timestamp.png');
      
      await file.writeAsBytes(widget.processedImage);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã lưu ảnh thành công'),
            backgroundColor: const Color(0xFF10b981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lưu ảnh: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Future<void> _shareImage() async {
    try {
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/ai_edited_$timestamp.png');
      
      await file.writeAsBytes(widget.processedImage);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Ảnh được chỉnh sửa bằng AI Image Editor',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chia sẻ: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }
}