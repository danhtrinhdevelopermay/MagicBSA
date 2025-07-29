import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/image_provider.dart';
import '../services/clipdrop_service.dart';

class EnhancedEditorWidget extends StatefulWidget {
  final File originalImage;

  const EnhancedEditorWidget({
    super.key,
    required this.originalImage,
  });

  @override
  State<EnhancedEditorWidget> createState() => _EnhancedEditorWidgetState();
}

class _EnhancedEditorWidgetState extends State<EnhancedEditorWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _sceneController = TextEditingController();
  String _selectedAspectRatio = '1:1';
  String _selectedScene = 'forest';
  int _targetWidth = 1024;
  int _targetHeight = 1024;
  double _uncropExtendRatio = 1.5;

  final List<String> _aspectRatios = ['1:1', '16:9', '9:16', '4:3', '3:4'];
  final List<String> _scenes = [
    'forest',
    'city',
    'beach',
    'mountain',
    'studio',
    'office',
    'kitchen',
    'bedroom',
  ];

  final List<FeatureCategory> _categories = [
    FeatureCategory(
      title: 'Chỉnh sửa cơ bản',
      icon: Icons.edit,
      color: Colors.blue,
      features: [
        Feature(
          operation: ProcessingOperation.removeBackground,
          title: 'Xóa Background',
          subtitle: 'Loại bỏ nền ảnh tự động',
          icon: Icons.layers_clear,
          needsInput: false,
        ),
        Feature(
          operation: ProcessingOperation.cleanup,
          title: 'Dọn dẹp đối tượng',
          subtitle: 'Xóa các đối tượng không mong muốn',
          icon: Icons.cleaning_services,
          needsInput: true,
          inputType: InputType.mask,
        ),
        Feature(
          operation: ProcessingOperation.removeText,
          title: 'Xóa văn bản',
          subtitle: 'Loại bỏ chữ viết trên ảnh',
          icon: Icons.text_fields_outlined,
          needsInput: false,
        ),
        Feature(
          operation: ProcessingOperation.removeLogo,
          title: 'Xóa logo',
          subtitle: 'Loại bỏ logo/watermark trên ảnh',
          icon: Icons.branding_watermark_outlined,
          needsInput: false,
        ),
      ],
    ),
    FeatureCategory(
      title: 'Nâng cao chất lượng',
      icon: Icons.high_quality,
      color: Colors.green,
      features: [
        Feature(
          operation: ProcessingOperation.imageUpscaling,
          title: 'Nâng cấp độ phân giải',
          subtitle: 'Tăng chất lượng và kích thước ảnh',
          icon: Icons.zoom_in,
          needsInput: true,
          inputType: InputType.dimensions,
        ),
        Feature(
          operation: ProcessingOperation.uncrop,
          title: 'Mở rộng ảnh',
          subtitle: 'Tăng kích thước canvas của ảnh',
          icon: Icons.crop_free,
          needsInput: true,
          inputType: InputType.aspectRatio,
        ),
      ],
    ),
    FeatureCategory(
      title: 'Tạo ảnh sáng tạo',
      icon: Icons.palette,
      color: Colors.purple,
      features: [
        Feature(
          operation: ProcessingOperation.reimagine,
          title: 'Tái tưởng tượng',
          subtitle: 'Tạo phiên bản mới của ảnh',
          icon: Icons.auto_fix_high,
          needsInput: false,
        ),
        Feature(
          operation: ProcessingOperation.productPhotography,
          title: 'Ảnh sản phẩm',
          subtitle: 'Tạo ảnh sản phẩm chuyên nghiệp',
          icon: Icons.shopping_bag,
          needsInput: true,
          inputType: InputType.scene,
        ),
        Feature(
          operation: ProcessingOperation.replaceBackground,
          title: 'Thay thế nền',
          subtitle: 'Đổi background bằng mô tả',
          icon: Icons.landscape,
          needsInput: true,
          inputType: InputType.prompt,
        ),
      ],
    ),
    FeatureCategory(
      title: 'Tạo từ văn bản',
      icon: Icons.create,
      color: Colors.orange,
      features: [
        Feature(
          operation: ProcessingOperation.textToImage,
          title: 'Tạo ảnh từ mô tả',
          subtitle: 'Tạo ảnh mới từ văn bản mô tả',
          icon: Icons.image,
          needsInput: true,
          inputType: InputType.prompt,
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image preview
          _buildImagePreview(),
          const SizedBox(height: 24),
          
          // Feature categories
          const Text(
            'Chọn tính năng chỉnh sửa',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1e293b),
            ),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: _categories.length,
              itemBuilder: (context, index) => _buildCategoryPage(_categories[index]),
            ),
          ),
          
          // Page indicator
          _buildPageIndicator(),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          widget.originalImage,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildCategoryPage(FeatureCategory category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                category.icon,
                color: category.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              category.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: category.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Features grid
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: 4,
              mainAxisSpacing: 12,
            ),
            itemCount: category.features.length,
            itemBuilder: (context, index) => _buildFeatureCard(category.features[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(Feature feature) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _handleFeatureTap(feature),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366f1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  feature.icon,
                  color: const Color(0xFF6366f1),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      feature.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1e293b),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      feature.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748b),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF94a3b8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _categories.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: _currentPage == index ? 24 : 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? const Color(0xFF6366f1)
                : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  void _handleFeatureTap(Feature feature) {
    if (feature.needsInput) {
      _showInputDialog(feature);
    } else {
      _executeFeature(feature);
    }
  }

  void _showInputDialog(Feature feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature.title),
        content: _buildInputWidget(feature),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _executeFeature(feature);
            },
            child: const Text('Áp dụng'),
          ),
        ],
      ),
    );
  }

  Widget _buildInputWidget(Feature feature) {
    switch (feature.inputType) {
      case InputType.prompt:
        return TextField(
          controller: _promptController,
          decoration: const InputDecoration(
            labelText: 'Nhập mô tả',
            hintText: 'Ví dụ: tropical beach with palm trees',
          ),
          maxLines: 3,
        );
      
      case InputType.scene:
        return DropdownButtonFormField<String>(
          value: _selectedScene,
          decoration: const InputDecoration(labelText: 'Chọn cảnh'),
          items: _scenes.map((scene) => DropdownMenuItem(
            value: scene,
            child: Text(scene),
          )).toList(),
          onChanged: (value) => setState(() => _selectedScene = value!),
        );
      
      case InputType.aspectRatio:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedAspectRatio,
              decoration: const InputDecoration(labelText: 'Tỷ lệ khung hình'),
              items: _aspectRatios.map((ratio) => DropdownMenuItem(
                value: ratio,
                child: Text(ratio),
              )).toList(),
              onChanged: (value) => setState(() => _selectedAspectRatio = value!),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Tỷ lệ mở rộng: '),
                Expanded(
                  child: Slider(
                    value: _uncropExtendRatio,
                    min: 1.1,
                    max: 3.0,
                    divisions: 19,
                    label: _uncropExtendRatio.toStringAsFixed(1),
                    onChanged: (value) => setState(() => _uncropExtendRatio = value),
                  ),
                ),
              ],
            ),
          ],
        );
      
      case InputType.dimensions:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Chiều rộng'),
              keyboardType: TextInputType.number,
              onChanged: (value) => _targetWidth = int.tryParse(value) ?? 1024,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Chiều cao'),
              keyboardType: TextInputType.number,
              onChanged: (value) => _targetHeight = int.tryParse(value) ?? 1024,
            ),
          ],
        );
      
      case InputType.mask:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Chức năng này cần ảnh mask để xác định vùng cần xóa.'),
            const SizedBox(height: 8),
            const Text(
              'Hiện tại chức năng này chưa được hỗ trợ đầy đủ. Vui lòng sử dụng các tính năng khác.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        );
      
      case null:
      default:
        return const SizedBox();
    }
  }

  void _executeFeature(Feature feature) {
    final provider = Provider.of<ImageEditProvider>(context, listen: false);
    
    print('Executing feature: ${feature.title} (${feature.operation})');
    
    try {
      switch (feature.operation) {
        case ProcessingOperation.removeBackground:
          provider.removeBackground();
          break;
          
        case ProcessingOperation.removeText:
          provider.removeText();
          break;
          
        case ProcessingOperation.cleanup:
          // For cleanup, we would need mask selection UI - skip for now
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tính năng dọn dẹp đối tượng cần chọn vùng cụ thể. Chức năng này đang được phát triển.'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
          
        case ProcessingOperation.uncrop:
          provider.uncrop(
            aspectRatio: _selectedAspectRatio,
            extendRatio: _uncropExtendRatio,
          );
          break;
          
        case ProcessingOperation.imageUpscaling:
          provider.upscaleImage(
            targetWidth: _targetWidth,
            targetHeight: _targetHeight,
          );
          break;
          
        case ProcessingOperation.reimagine:
          provider.reimagine();
          break;
          
        case ProcessingOperation.productPhotography:
          provider.productPhotography(scene: _selectedScene);
          break;
          
        case ProcessingOperation.textToImage:
          if (_promptController.text.isNotEmpty) {
            provider.generateFromText(_promptController.text);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Vui lòng nhập mô tả để tạo ảnh'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          break;
          
        case ProcessingOperation.replaceBackground:
          if (_promptController.text.isNotEmpty) {
            provider.replaceBackground(prompt: _promptController.text);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Vui lòng nhập mô tả background mới'),
                backgroundColor: Colors.red,  
              ),
            );
            return;
          }
          break;
          
        case ProcessingOperation.removeLogo:
          provider.removeLogo();
          break;
          
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tính năng này chưa được hỗ trợ'),
              backgroundColor: Colors.grey,
            ),
          );
          break;
      }
      
      print('Feature execution started successfully');
    } catch (e) {
      print('Error executing feature: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi thực hiện: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _promptController.dispose();
    _sceneController.dispose();
    super.dispose();
  }
}

// Data models
class FeatureCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<Feature> features;

  FeatureCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.features,
  });
}

class Feature {
  final ProcessingOperation operation;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool needsInput;
  final InputType? inputType;

  Feature({
    required this.operation,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.needsInput,
    this.inputType,
  });
}

enum InputType {
  prompt,
  scene,
  aspectRatio,
  dimensions,
  mask,
}