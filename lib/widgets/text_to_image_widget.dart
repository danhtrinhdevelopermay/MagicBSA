import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/image_provider.dart';

class TextToImageWidget extends StatefulWidget {
  const TextToImageWidget({super.key});

  @override
  State<TextToImageWidget> createState() => _TextToImageWidgetState();
}

class _TextToImageWidgetState extends State<TextToImageWidget> {
  final TextEditingController _promptController = TextEditingController();
  bool _isExpanded = false;

  final List<String> _samplePrompts = [
    'tropical beach with palm trees and clear blue water',
    'modern office space with plants and natural lighting',
    'cozy living room with fireplace and warm lighting',
    'mountain landscape with snow peaks and green valley',
    'abstract geometric patterns in vibrant colors',
    'cute cartoon cat sitting on a cloud',
    'futuristic city skyline at sunset',
    'beautiful flower garden with butterflies',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366f1), Color(0xFF8b5cf6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366f1).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tạo ảnh từ văn bản',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Mô tả ý tưởng của bạn bằng lời',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white,
                    ),
                  ],
                ),
                
                // Expanded content
                if (_isExpanded) ...[
                  const SizedBox(height: 20),
                  
                  // Text input
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _promptController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Mô tả ảnh bạn muốn tạo...\nVí dụ: "tropical beach with palm trees"',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Sample prompts
                  const Text(
                    'Gợi ý:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _samplePrompts.length,
                      itemBuilder: (context, index) => _buildSamplePrompt(_samplePrompts[index]),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Generate button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _promptController.text.trim().isEmpty
                          ? null
                          : () => _generateImage(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF6366f1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.create),
                          SizedBox(width: 8),
                          Text(
                            'Tạo ảnh',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSamplePrompt(String prompt) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => setState(() => _promptController.text = prompt),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              prompt.length > 30 ? '${prompt.substring(0, 30)}...' : prompt,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _generateImage() {
    if (_promptController.text.trim().isEmpty) return;
    
    final provider = Provider.of<ImageEditProvider>(context, listen: false);
    provider.generateFromText(_promptController.text.trim());
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
}