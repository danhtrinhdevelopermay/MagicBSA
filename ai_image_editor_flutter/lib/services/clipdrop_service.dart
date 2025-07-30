import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ProcessingOperation {
  removeBackground,
  removeText, 
  cleanup,
  uncrop,
  reimagine,
  replaceBackground,
  textToImage,
  productPhotography,
}

class ClipDropService {
  // API endpoints
  static const String _removeBackgroundUrl = 'https://clipdrop-api.co/remove-background/v1';
  static const String _removeTextUrl = 'https://clipdrop-api.co/remove-text/v1';
  static const String _cleanupUrl = 'https://clipdrop-api.co/cleanup/v1';
  static const String _uncropUrl = 'https://clipdrop-api.co/uncrop/v1';
  static const String _reimagineUrl = 'https://clipdrop-api.co/reimagine/v1/reimagine';
  static const String _replaceBackgroundUrl = 'https://clipdrop-api.co/replace-background/v1';
  static const String _textToImageUrl = 'https://clipdrop-api.co/text-to-image/v1';
  static const String _productPhotoUrl = 'https://clipdrop-api.co/product-photography/v1';

  late Dio _dio;
  String _currentApiKey = '';
  String _primaryApiKey = '';
  String _backupApiKey = '';
  bool _usingBackupApi = false;

  ClipDropService() {
    _dio = Dio();
    _initializeApiKeys();
  }

  Future<void> _initializeApiKeys() async {
    await _loadApiKeys();
    _dio.options.headers['x-api-key'] = _currentApiKey;
  }

  Future<void> _loadApiKeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _primaryApiKey = prefs.getString('clipdrop_primary_api_key') ?? '2f62a50ae0c0b965c1f54763e90bb44c101d8d1b84b5a670f4a6bd336954ec2c77f3c3b28ad0c1c9271fcfdfa2abc664';
      _backupApiKey = prefs.getString('clipdrop_backup_api_key') ?? '7ce6a169f98dc2fb224fc5ad1663c53716b1ee3332fc7a3903dc8a5092feb096731cf4a19f9989cb2901351e1c086ff2';
      _currentApiKey = _primaryApiKey;
      _usingBackupApi = false;
    } catch (e) {
      print('Lỗi khi tải API keys: $e');
    }
  }

  void _switchToBackupApi() {
    if (_backupApiKey.isNotEmpty) {
      _currentApiKey = _backupApiKey;
      _usingBackupApi = true;
      _dio.options.headers['x-api-key'] = _currentApiKey;
      print('Đã chuyển sang API dự phòng');
    }
  }

  void _resetToPrimaryApi() {
    if (_primaryApiKey.isNotEmpty) {
      _currentApiKey = _primaryApiKey;
      _usingBackupApi = false;
      _dio.options.headers['x-api-key'] = _currentApiKey;
      print('Đã reset về API chính');
    }
  }

  Future<T> _executeWithFailover<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on DioException catch (e) {
      // Enhanced logging for debugging
      print('DioException caught: ${e.response?.statusCode}');
      print('Error message: ${e.message}');
      print('Response data: ${e.response?.data}');
      print('Response headers: ${e.response?.headers}');
      
      // Check if it's a quota/credit related error
      final isQuotaError = e.response?.statusCode == 402 ||  // Payment Required (official Clipdrop credit error)
                         e.response?.statusCode == 400 ||    // Bad Request (might include quota info)
                         (e.response?.data != null && 
                          e.response!.data.toString().toLowerCase().contains('quota')) ||
                         (e.response?.data != null && 
                          e.response!.data.toString().toLowerCase().contains('credit')) ||
                         (e.response?.data != null && 
                          e.response!.data.toString().toLowerCase().contains('limit')) ||
                         (e.response?.data != null && 
                          e.response!.data.toString().toLowerCase().contains('exceeded'));
      
      if (isQuotaError && !_usingBackupApi) {
        print('API chính hết credit/quota (Status: ${e.response?.statusCode}), đang chuyển sang API dự phòng...');
        _switchToBackupApi();
        
        // Retry with backup API
        try {
          print('Đang thử lại với API dự phòng...');
          return await operation();
        } catch (retryError) {
          print('API dự phòng cũng gặp lỗi: $retryError');
          // If backup also fails, check if it's also quota error
          if (retryError is DioException && retryError.response?.statusCode == 402) {
            throw Exception('Cả hai API đều đã hết credit. Vui lòng mua thêm credit tại https://clipdrop.co/apis/pricing');
          }
          rethrow;
        }
      } else if (isQuotaError && _usingBackupApi) {
        // Both APIs exhausted
        throw Exception('Cả hai API đều đã hết credit. Vui lòng mua thêm credit tại https://clipdrop.co/apis/pricing');
      }
      
      // For non-quota errors, provide more specific error messages
      if (e.response?.statusCode == 401) {
        throw Exception('API key không hợp lệ. Vui lòng kiểm tra lại API key trong Cài đặt.');
      } else if (e.response?.statusCode == 429) {
        throw Exception('Quá nhiều request. Vui lòng thử lại sau ít phút.');
      } else if (e.response?.statusCode == 400) {
        final errorData = e.response?.data?.toString() ?? '';
        if (errorData.toLowerCase().contains('file') || errorData.toLowerCase().contains('image')) {
          throw Exception('Định dạng ảnh không hợp lệ. Vui lòng chọn ảnh PNG, JPEG hoặc WebP dưới 1024x1024 pixels.');
        }
        throw Exception('Yêu cầu không hợp lệ: $errorData');
      }
      
      rethrow;
    }
  }

  Future<Uint8List> processImage(
    File imageFile, 
    ProcessingOperation operation, {
    File? maskFile,
    File? backgroundFile,
    String? prompt,
    String? scene,
    int? extendLeft,
    int? extendRight,
    int? extendUp,
    int? extendDown,
    int? seed,
    int? targetWidth,
    int? targetHeight,
  }) async {
    // For text-to-image operation, use the dedicated method
    if (operation == ProcessingOperation.textToImage && prompt != null) {
      return await generateImageFromText(prompt);
    }
    
    // Validate image file before processing
    await _validateImageFile(imageFile, operation);
    
    // Reload API keys if not initialized
    if (_currentApiKey.isEmpty) {
      await _loadApiKeys();
      _dio.options.headers['x-api-key'] = _currentApiKey;
    }
    
    return await _executeWithFailover(() async {
      if (_currentApiKey.isEmpty) {
        throw Exception(
          'Vui lòng cấu hình API key Clipdrop trong màn hình Cài đặt.\n\n'
          'Để lấy API key:\n'
          '1. Truy cập https://clipdrop.co/apis\n'
          '2. Đăng ký hoặc đăng nhập\n'
          '3. Tạo API key mới\n'
          '4. Nhập vào màn hình Cài đặt của app'
        );
      }

      String apiUrl;
      switch (operation) {
        case ProcessingOperation.removeBackground:
          apiUrl = _removeBackgroundUrl;
          break;
        case ProcessingOperation.removeText:
          apiUrl = _removeTextUrl;
          break;
        case ProcessingOperation.cleanup:
          apiUrl = _cleanupUrl;
          break;
        case ProcessingOperation.uncrop:
          apiUrl = _uncropUrl;
          break;
        case ProcessingOperation.reimagine:
          apiUrl = _reimagineUrl;
          print('Using Reimagine API endpoint: $apiUrl');
          break;
        case ProcessingOperation.replaceBackground:
          apiUrl = _replaceBackgroundUrl;
          break;
        case ProcessingOperation.textToImage:
          apiUrl = _textToImageUrl;
          break;
        case ProcessingOperation.productPhotography:
          apiUrl = _productPhotoUrl;
          break;
      }

      final formData = FormData.fromMap({
        'image_file': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'image.${imageFile.path.split('.').last}',
        ),
      });

      // Add operation-specific parameters
      switch (operation) {
        case ProcessingOperation.cleanup:
          if (maskFile != null) {
            formData.files.add(MapEntry(
              'mask_file',
              await MultipartFile.fromFile(
                maskFile.path,
                filename: 'mask.png', // Force PNG extension for mask
              ),
            ));
            // Add mode parameter for better quality (fast or quality)
            formData.fields.add(MapEntry('mode', 'quality'));
            print('Cleanup API call with mask: ${maskFile.path}');
            print('Mode: quality (better results, slower processing)');
          } else {
            throw Exception('Cleanup operation requires a mask file');
          }
          break;
        
        case ProcessingOperation.uncrop:
          if (extendLeft != null && extendLeft > 0) {
            formData.fields.add(MapEntry('extend_left', extendLeft.toString()));
          }
          if (extendRight != null && extendRight > 0) {
            formData.fields.add(MapEntry('extend_right', extendRight.toString()));
          }
          if (extendUp != null && extendUp > 0) {
            formData.fields.add(MapEntry('extend_up', extendUp.toString()));
          }
          if (extendDown != null && extendDown > 0) {
            formData.fields.add(MapEntry('extend_down', extendDown.toString()));
          }
          if (seed != null) {
            formData.fields.add(MapEntry('seed', seed.toString()));
          }
          break;
          
        case ProcessingOperation.replaceBackground:
          if (backgroundFile != null) {
            formData.files.add(MapEntry(
              'background_file',
              await MultipartFile.fromFile(
                backgroundFile.path,
                filename: 'background.${backgroundFile.path.split('.').last}',
              ),
            ));
          } else if (prompt != null) {
            formData.fields.add(MapEntry('prompt', prompt));
          }
          break;
          
        case ProcessingOperation.productPhotography:
          if (scene != null) {
            formData.fields.add(MapEntry('scene', scene));
          }
          break;
        
        default:
          // No additional parameters needed
          break;
      }

      print('Calling Clipdrop API: $apiUrl');
      print('API Key: ${_currentApiKey.substring(0, 8)}...');
      print('Form data fields: ${formData.fields.map((e) => '${e.key}=${e.value}').join(', ')}');
      print('Form data files: ${formData.files.map((e) => e.key).join(', ')}');

      final response = await _dio.post(
        apiUrl,
        data: formData,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      print('API Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      
      if (response.statusCode == 200) {
        print('API call successful, image data size: ${response.data.length} bytes');
        
        // Log credit information from headers
        final remainingCredits = response.headers.value('x-remaining-credits');
        final consumedCredits = response.headers.value('x-credits-consumed');
        if (remainingCredits != null) {
          print('Credits remaining: $remainingCredits');
        }
        if (consumedCredits != null) {
          print('Credits consumed: $consumedCredits');
        }
        
        return Uint8List.fromList(response.data);
      } else {
        print('API error response: ${response.data}');
        throw Exception('API error: ${response.statusCode} - ${response.statusMessage}');
      }
    });
  }

  // Convenience methods for backward compatibility and easier usage
  Future<Uint8List> removeBackground(File imageFile) async {
    return processImage(imageFile, ProcessingOperation.removeBackground);
  }

  Future<Uint8List> removeText(File imageFile) async {
    return processImage(imageFile, ProcessingOperation.removeText);
  }

  Future<Uint8List> cleanup(File imageFile, File maskFile) async {
    return processImage(imageFile, ProcessingOperation.cleanup, maskFile: maskFile);
  }

  Future<Uint8List> removeLogo(File imageFile) async {
    return processImage(imageFile, ProcessingOperation.cleanup);
  }

  // New API methods
  Future<Uint8List> uncrop(File imageFile, {
    int? extendLeft,
    int? extendRight, 
    int? extendUp,
    int? extendDown,
    int? seed,
  }) async {
    return processImage(
      imageFile, 
      ProcessingOperation.uncrop,
      extendLeft: extendLeft,
      extendRight: extendRight,
      extendUp: extendUp,
      extendDown: extendDown,
      seed: seed,
    );
  }

  Future<Uint8List> upscaleImage(File imageFile, {int? targetWidth, int? targetHeight}) async {
    // ClipDrop doesn't have upscaling API, use reimagine as alternative
    return processImage(imageFile, ProcessingOperation.reimagine);
  }

  Future<Uint8List> reimagine(File imageFile) async {
    print('=== REIMAGINE DEBUG START ===');
    print('Input file: ${imageFile.path}');
    print('File exists: ${await imageFile.exists()}');
    
    try {
      final result = await processImage(imageFile, ProcessingOperation.reimagine);
      print('=== REIMAGINE SUCCESS ===');
      return result;
    } catch (e) {
      print('=== REIMAGINE ERROR ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');
      
      // Provide more specific error message for reimagine
      if (e.toString().toLowerCase().contains('402') || 
          e.toString().toLowerCase().contains('payment')) {
        throw Exception('API đã hết credit cho tính năng Reimagine. Vui lòng kiểm tra tài khoản Clipdrop hoặc mua thêm credit tại https://clipdrop.co/apis/pricing');
      } else if (e.toString().toLowerCase().contains('401')) {
        throw Exception('API key không hợp lệ cho tính năng Reimagine. Vui lòng kiểm tra API key trong Cài đặt.');
      } else if (e.toString().toLowerCase().contains('400')) {
        throw Exception('Ảnh không hợp lệ cho Reimagine. Vui lòng thử với ảnh khác (PNG/JPG/WebP, dưới 1024x1024px).');
      }
      
      rethrow;
    }
  }

  Future<Uint8List> productPhotography(File imageFile, {String? scene}) async {
    return processImage(
      imageFile, 
      ProcessingOperation.productPhotography,
      scene: scene,
    );
  }

  Future<Uint8List> replaceBackground(File imageFile, {File? backgroundFile, String? prompt}) async {
    return processImage(
      imageFile, 
      ProcessingOperation.replaceBackground,
      backgroundFile: backgroundFile,
      prompt: prompt,
    );
  }

  // Special method for text-to-image that doesn't require an input image
  Future<Uint8List> generateImageFromText(String prompt) async {
    // Reload API keys if not initialized
    if (_currentApiKey.isEmpty) {
      await _loadApiKeys();
      _dio.options.headers['x-api-key'] = _currentApiKey;
    }
    
    return await _executeWithFailover(() async {
      if (_currentApiKey.isEmpty) {
        throw Exception(
          'Vui lòng cấu hình API key Clipdrop trong màn hình Cài đặt.\n\n'
          'Để lấy API key:\n'
          '1. Truy cập https://clipdrop.co/apis\n'
          '2. Đăng ký hoặc đăng nhập\n'
          '3. Tạo API key mới\n'
          '4. Nhập vào màn hình Cài đặt của app'
        );
      }

      final formData = FormData.fromMap({
        'prompt': prompt,
      });

      final response = await _dio.post(
        _textToImageUrl,
        data: formData,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == 200) {
        return Uint8List.fromList(response.data);
      } else {
        throw Exception('API error: ${response.statusCode}');
      }
    });
  }

  // Utility methods to get API status
  bool get isUsingBackupApi => _usingBackupApi;
  String get currentApiStatus => _usingBackupApi ? 'API dự phòng' : 'API chính';
  
  // Method to manually reset to primary API (useful for testing/recovery)
  void resetToPrimaryApi() {
    _resetToPrimaryApi();
  }

  // Validate image file before API call
  Future<void> _validateImageFile(File imageFile, ProcessingOperation operation) async {
    // Check if file exists
    if (!await imageFile.exists()) {
      throw Exception('File ảnh không tồn tại. Vui lòng chọn ảnh khác.');
    }
    
    // Check file size (max 10MB for most APIs)
    final fileSize = await imageFile.length();
    const maxSize = 10 * 1024 * 1024; // 10MB
    if (fileSize > maxSize) {
      throw Exception('File ảnh quá lớn (${(fileSize / 1024 / 1024).toStringAsFixed(1)}MB). Tối đa 10MB.');
    }
    
    // Check file extension
    final extension = imageFile.path.toLowerCase().split('.').last;
    final validExtensions = ['jpg', 'jpeg', 'png', 'webp'];
    if (!validExtensions.contains(extension)) {
      throw Exception('Định dạng ảnh không hỗ trợ ($extension). Chỉ hỗ trợ: JPG, PNG, WebP.');
    }
    
    // Special validation for Reimagine API (max 1024x1024)
    if (operation == ProcessingOperation.reimagine) {
      // For Reimagine, we need to check image dimensions more strictly
      print('Applying Reimagine-specific validation (max 1024x1024px)');
      // Note: Actual image dimension check would require image package
      // For now, we rely on file size as a proxy
      if (fileSize > 5 * 1024 * 1024) { // 5MB for Reimagine is conservative
        throw Exception('Ảnh quá lớn cho Reimagine (${(fileSize / 1024 / 1024).toStringAsFixed(1)}MB). Vui lòng resize xuống dưới 1024x1024px và dưới 5MB.');
      }
    }
    
    print('Image validation passed: ${imageFile.path}');
    print('File size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB');
    print('Extension: $extension');
    print('Operation: $operation');
  }

  // Method to check API credits status
  Future<Map<String, dynamic>> checkCreditsStatus() async {
    if (_currentApiKey.isEmpty) {
      await _loadApiKeys();
      _dio.options.headers['x-api-key'] = _currentApiKey;
    }

    try {
      // Use a simple API call to check credits (remove background is cheapest)
      final tempFile = File('temp_check.jpg');
      // Create a small temp image for testing
      await tempFile.writeAsBytes([
        0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01,
        0x01, 0x01, 0x00, 0x48, 0x00, 0x48, 0x00, 0x00, 0xFF, 0xDB, 0x00, 0x43
      ]); // Minimal JPEG header

      final formData = FormData.fromMap({
        'image_file': await MultipartFile.fromFile(tempFile.path, filename: 'test.jpg'),
      });

      final response = await _dio.post(
        _removeBackgroundUrl,
        data: formData,
        options: Options(responseType: ResponseType.bytes),
      );

      // Clean up temp file
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      final remainingCredits = response.headers.value('x-remaining-credits');
      final consumedCredits = response.headers.value('x-credits-consumed');

      return {
        'success': true,
        'remainingCredits': remainingCredits ?? 'unknown',
        'consumedCredits': consumedCredits ?? 'unknown',
        'apiStatus': currentApiStatus,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'apiStatus': currentApiStatus,
      };
    }
  }
}