import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _primaryApiKeyController = TextEditingController();
  final _backupApiKeyController = TextEditingController();
  final _huggingFaceTokenController = TextEditingController();
  final _replicateTokenController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadApiKeys();
  }

  Future<void> _loadApiKeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final primaryKey = prefs.getString('clipdrop_primary_api_key') ?? '2f62a50ae0c0b965c1f54763e90bb44c101d8d1b84b5a670f4a6bd336954ec2c77f3c3b28ad0c1c9271fcfdfa2abc664';
      final backupKey = prefs.getString('clipdrop_backup_api_key') ?? '7ce6a169f98dc2fb224fc5ad1663c53716b1ee3332fc7a3903dc8a5092feb096731cf4a19f9989cb2901351e1c086ff2';
      final huggingFaceToken = prefs.getString('huggingface_token') ?? '';
      final replicateToken = prefs.getString('replicate_token') ?? '';
      
      setState(() {
        _primaryApiKeyController.text = primaryKey;
        _backupApiKeyController.text = backupKey;
        _huggingFaceTokenController.text = huggingFaceToken;
        _replicateTokenController.text = replicateToken;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải cấu hình: $e')),
        );
      }
    }
  }

  Future<void> _saveApiKeys() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('clipdrop_primary_api_key', _primaryApiKeyController.text.trim());
      await prefs.setString('clipdrop_backup_api_key', _backupApiKeyController.text.trim());
      await prefs.setString('huggingface_token', _huggingFaceTokenController.text.trim());
      await prefs.setString('replicate_token', _replicateTokenController.text.trim());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu tất cả API keys thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi lưu API keys: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _primaryApiKeyController.dispose();
    _backupApiKeyController.dispose();
    _huggingFaceTokenController.dispose();
    _replicateTokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt API'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue, size: 24),
                    const SizedBox(height: 8),
                    const Text(
                      'Hướng dẫn lấy API Key',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'ClipDrop API (Có phí):\n'
                      '1. Truy cập https://clipdrop.co/apis\n'
                      '2. Đăng ký tài khoản hoặc đăng nhập\n'
                      '3. Tạo API key mới trong dashboard\n'
                      '4. Sao chép và dán API key vào form bên dưới\n'
                      '5. API dự phòng là tùy chọn để tăng độ tin cậy',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            TextField(
              controller: _primaryApiKeyController,
              decoration: const InputDecoration(
                labelText: 'API Key chính *',
                hintText: 'Nhập ClipDrop API key chính',
                prefixIcon: Icon(Icons.key),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _backupApiKeyController,
              decoration: const InputDecoration(
                labelText: 'API Key dự phòng (tùy chọn)',
                hintText: 'Nhập ClipDrop API key dự phòng',
                prefixIcon: Icon(Icons.backup),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 32),
            
            // Alternative AI Services Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.psychology, color: Colors.purple, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'API Miễn Phí Thay Thế',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Cấu hình các API miễn phí cho:\n'
                      '• Tạo ảnh từ văn bản (Hugging Face)\n'
                      '• Nâng cấp độ phân giải (Real-ESRGAN)\n'
                      '• Xóa vật thể (Cleanup API)',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: _huggingFaceTokenController,
                      decoration: const InputDecoration(
                        labelText: 'Hugging Face Token (miễn phí)',
                        hintText: 'hf_xxxxxxxxxxxxxxxxxxxxxxxxx',
                        prefixIcon: Icon(Icons.face),
                        border: OutlineInputBorder(),
                        helperText: 'Lấy tại: https://huggingface.co/settings/tokens',
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: _replicateTokenController,
                      decoration: const InputDecoration(
                        labelText: 'Replicate Token (chi phí thấp ~\$0.002/ảnh)',
                        hintText: 'r8_xxxxxxxxxxxxxxxxxxxxxxxxx',
                        prefixIcon: Icon(Icons.repeat),
                        border: OutlineInputBorder(),
                        helperText: 'Lấy tại: https://replicate.com/account/api-tokens',
                      ),
                      obscureText: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveApiKeys,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Lưu tất cả cấu hình', style: TextStyle(fontSize: 16)),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Lưu ý quan trọng',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• API key của bạn được lưu trữ an toàn trên thiết bị\n'
                      '• Không chia sẻ API key với người khác\n'
                      '• Mỗi API key có giới hạn số lần sử dụng theo gói đăng ký\n'
                      '• Nếu gặp lỗi 403, hãy kiểm tra lại API key hoặc credit còn lại',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}