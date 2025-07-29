import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/clipdrop_service.dart';

enum ProcessingState {
  idle,
  picking,
  processing,
  completed,
  error,
}

class ImageEditProvider extends ChangeNotifier {
  final ClipDropService _clipDropService = ClipDropService();
  final ImagePicker _picker = ImagePicker();
  
  File? _originalImage;
  Uint8List? _processedImage;
  ProcessingState _state = ProcessingState.idle;
  String _errorMessage = '';
  String _currentOperation = '';
  double _progress = 0.0;

  // Getters
  File? get originalImage => _originalImage;
  Uint8List? get processedImage => _processedImage;
  ProcessingState get state => _state;
  String get errorMessage => _errorMessage;
  String get currentOperation => _currentOperation;
  double get progress => _progress;

  // Pick image from gallery or camera
  Future<void> pickImage(ImageSource source) async {
    try {
      _setState(ProcessingState.picking);
      
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,  
        imageQuality: 85,
      );

      if (pickedFile != null) {
        _originalImage = File(pickedFile.path);
        _processedImage = null;
        _setState(ProcessingState.idle);
      } else {
        _setState(ProcessingState.idle);
      }
    } catch (e) {
      _setError('Lỗi khi chọn ảnh: $e');
    }
  }

  // Process image with specific operation
  Future<void> processImage(
    ProcessingOperation operation, {
    File? maskFile,
    File? backgroundFile,
    String? prompt,
    String? aspectRatio,
    String? scene,
    double? uncropExtendRatio,
    int? targetWidth,
    int? targetHeight,
  }) async {
    if (_originalImage == null && operation != ProcessingOperation.textToImage) return;
    
    try {
      String operationText;
      switch (operation) {
        case ProcessingOperation.removeBackground:
          operationText = 'Đang xóa background...';
          break;
        case ProcessingOperation.removeText:
          operationText = 'Đang xóa văn bản...';
          break;
        case ProcessingOperation.cleanup:
          operationText = 'Đang dọn dẹp đối tượng...';
          break;
        case ProcessingOperation.uncrop:
          operationText = 'Đang mở rộng ảnh...';
          break;
        case ProcessingOperation.reimagine:
          operationText = 'Đang tái tưởng tượng ảnh...';
          break;
        case ProcessingOperation.productPhotography:
          operationText = 'Đang tạo ảnh sản phẩm...';
          break;
        case ProcessingOperation.textToImage:
          operationText = 'Đang tạo ảnh từ văn bản...';
          break;
        case ProcessingOperation.replaceBackground:
          operationText = 'Đang thay thế background...';
          break;
      }
      
      _currentOperation = operationText;
      _setState(ProcessingState.processing);
      _startProgressAnimation();

      Uint8List result;
      if (operation == ProcessingOperation.textToImage) {
        // For text-to-image, use the dedicated method with just the prompt
        result = await _clipDropService.generateImageFromText(prompt!);
      } else {
        result = await _clipDropService.processImage(
          _originalImage!, 
          operation, 
          maskFile: maskFile,
          backgroundFile: backgroundFile,
          prompt: prompt,
          aspectRatio: aspectRatio,
          scene: scene,
          uncropExtendRatio: uncropExtendRatio,
          targetWidth: targetWidth,
          targetHeight: targetHeight,
        );
      }
      
      _processedImage = result;
      _setState(ProcessingState.completed);
      _progress = 1.0;
    } catch (e) {
      _setError('Lỗi khi xử lý ảnh: $e');
    }
  }

  // Convenience methods for backward compatibility
  Future<void> removeBackground() async {
    await processImage(ProcessingOperation.removeBackground);
  }

  Future<void> removeText() async {
    await processImage(ProcessingOperation.removeText);
  }

  Future<void> cleanup({File? maskFile}) async {
    await processImage(ProcessingOperation.cleanup, maskFile: maskFile);
  }

  // New ClipDrop API methods
  Future<void> uncrop({String? aspectRatio, double? extendRatio}) async {
    await processImage(
      ProcessingOperation.uncrop,
      aspectRatio: aspectRatio,
      uncropExtendRatio: extendRatio,
    );
  }

  Future<void> reimagine() async {
    await processImage(ProcessingOperation.reimagine);
  }

  Future<void> replaceBackground({File? backgroundFile, String? prompt}) async {
    await processImage(
      ProcessingOperation.replaceBackground,
      backgroundFile: backgroundFile,
      prompt: prompt,
    );
  }

  Future<void> productPhotography({String? scene}) async {
    await processImage(
      ProcessingOperation.productPhotography,
      scene: scene,
    );
  }

  Future<void> generateFromText(String prompt) async {
    try {
      _currentOperation = 'Đang tạo ảnh từ văn bản...';
      _setState(ProcessingState.processing);
      _startProgressAnimation();

      final result = await _clipDropService.generateImageFromText(prompt);
      
      _processedImage = result;
      _setState(ProcessingState.completed);
      _progress = 1.0;
    } catch (e) {
      _setError('Lỗi khi tạo ảnh từ văn bản: $e');
    }
  }

  // Clear processed image
  void clearProcessedImage() {
    _processedImage = null;
    _setState(ProcessingState.idle);
  }

  // Clear error
  void clearError() {
    _errorMessage = '';
    _setState(ProcessingState.idle);
  }

  // Reset all data - complete reset
  void reset() {
    _originalImage = null;
    _processedImage = null;
    _errorMessage = '';
    _currentOperation = '';
    _progress = 0.0;
    _setState(ProcessingState.idle);
  }

  void _setState(ProcessingState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _setState(ProcessingState.error);
  }

  void _startProgressAnimation() {
    _progress = 0.0;
    // Simulate progress animation
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_state == ProcessingState.processing) {
        _progress = 0.3;
        notifyListeners();
      }
    });
    
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (_state == ProcessingState.processing) {
        _progress = 0.6;
        notifyListeners();
      }
    });
    
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (_state == ProcessingState.processing) {
        _progress = 0.9;
        notifyListeners();
      }
    });
  }
}