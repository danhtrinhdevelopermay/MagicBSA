import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/clipdrop_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _primaryApiKeyController = TextEditingController();
  final _backupApiKeyController = TextEditingController();
  bool _isLoading = false;
  bool _isTesting = false;
  final ClipDropService _clipDropService = ClipDropService();

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
      
      setState(() {
        _primaryApiKeyController.text = primaryKey;
        _backupApiKeyController.text = backupKey;
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
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu API keys thành công!'),
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

  Future<void> _testApiEndpoints() async {
    setState(() {
      _isTesting = true;
    });

    try {
      // Save current keys first to test them
      await _saveApiKeys();
      
      // Test the endpoints
      final results = await _clipDropService.testApiEndpoints();
      
      if (mounted) {
        _showTestResults(results);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi test API: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  void _showTestResults(Map<String, dynamic> results) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kết quả kiểm tra API'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: results.length,
            itemBuilder: (context, index) {
              final entry = results.entries.elementAt(index);
              final key = entry.key;
              final value = entry.value;
              
              if (key == 'API Configuration') {
                return Card(
                  color: Colors.blue.shade50,
                  child: ListTile(
                    leading: const Icon(Icons.settings, color: Colors.blue),
                    title: Text(key),
                    subtitle: Text(
                      'Primary key: ${value['primary_key_set'] ? 'Set' : 'Not set'}\n'
                      'Backup key: ${value['backup_key_set'] ? 'Set' : 'Not set'}\n'
                      'Using backup: ${value['using_backup'] ? 'Yes' : 'No'}',
                    ),
                  ),
                );
              }
              
              final accessible = value['accessible'] ?? false;
              final status = value['status'];
              
              return Card(
                color: accessible ? Colors.green.shade50 : Colors.red.shade50,
                child: ListTile(
                  leading: Icon(
                    accessible ? Icons.check_circle : Icons.error,
                    color: accessible ? Colors.green : Colors.red,
                  ),
                  title: Text(key),
                  subtitle: Text(
                    'URL: ${value['url']}\n'
                    'Status: $status\n'
                    'Message: ${value['message']}',
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _primaryApiKeyController.dispose();
    _backupApiKeyController.dispose();
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
                    : const Text('Lưu cấu hình', style: TextStyle(fontSize: 16)),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Test API Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isTesting ? null : _testApiEndpoints,
                icon: _isTesting 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.wifi_protected_setup),
                label: Text(_isTesting ? 'Đang kiểm tra...' : 'Kiểm tra kết nối API'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
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