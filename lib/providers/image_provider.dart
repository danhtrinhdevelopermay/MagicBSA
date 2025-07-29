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
        case ProcessingOperation.removeLogo:
          operationText = 'Đang xóa logo...';
          break;
        case ProcessingOperation.uncrop:
          operationText = 'Đang mở rộng ảnh...';
          break;
        case ProcessingOperation.imageUpscaling:
          operationText = 'Đang nâng cấp chất lượng ảnh...';
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
      if (operation == ProcessingOperation.textToImage && prompt != null) {
        result = await _clipDropService.generateImageFromText(prompt);
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
      print('Error in processImage: $e');
      String errorMessage = 'Lỗi khi xử lý ảnh: ';
      
      if (e.toString().contains('quota') || e.toString().contains('credit')) {
        errorMessage += 'API đã hết credit/quota. Vui lòng thử lại sau hoặc liên hệ để nạp thêm credit.';
      } else if (e.toString().contains('401') || e.toString().contains('403')) {
        errorMessage += 'API key không hợp lệ. Vui lòng kiểm tra lại API key trong Cài đặt.';
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        errorMessage += 'Lỗi kết nối mạng. Vui lòng kiểm tra internet và thử lại.';
      } else if (e.toString().contains('timeout')) {
        errorMessage += 'Quá thời gian chờ. Vui lòng thử lại với ảnh nhỏ hơn.';
      } else {
        errorMessage += e.toString();
      }
      
      _setError(errorMessage);
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

  Future<void> removeLogo() async {
    await processImage(ProcessingOperation.removeLogo);
  }

  // Remove objects (backward compatibility - now uses cleanup)
  Future<void> removeObject() async {
    await cleanup();
  }

  // New API methods
  Future<void> uncrop({String? aspectRatio, double? extendRatio}) async {
    await processImage(
      ProcessingOperation.uncrop,
      aspectRatio: aspectRatio,
      uncropExtendRatio: extendRatio,
    );
  }

  Future<void> upscaleImage({int? targetWidth, int? targetHeight}) async {
    await processImage(
      ProcessingOperation.imageUpscaling,
      targetWidth: targetWidth,
      targetHeight: targetHeight,
    );
  }

  Future<void> reimagine() async {
    await processImage(ProcessingOperation.reimagine);
  }

  Future<void> productPhotography({String? scene}) async {
    await processImage(
      ProcessingOperation.productPhotography,
      scene: scene,
    );
  }

  Future<void> generateFromText(String prompt) async {
    await processImage(
      ProcessingOperation.textToImage,
      prompt: prompt,
    );
  }

  Future<void> replaceBackground({File? backgroundFile, String? prompt}) async {
    await processImage(
      ProcessingOperation.replaceBackground,
      backgroundFile: backgroundFile,
      prompt: prompt,
    );
  }

  // Reset to initial state
  void reset() {
    _originalImage = null;
    _processedImage = null;
    _setState(ProcessingState.idle);
    _errorMessage = '';
    _currentOperation = '';
    _progress = 0.0;
  }

  // Clear error
  void clearError() {
    _errorMessage = '';
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