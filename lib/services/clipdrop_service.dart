import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ProcessingOperation {
  removeBackground,
  removeText, 
  cleanup,
  removeLogo,
  uncrop,
  imageUpscaling,
  reimagine,
  productPhotography,
  textToImage,
  replaceBackground,
}

class ClipDropService {
  // API endpoints (Updated to correct URLs from official documentation)
  static const String _removeBackgroundUrl = 'https://clipdrop-api.co/remove-background/v1';
  static const String _removeTextUrl = 'https://clipdrop-api.co/remove-text/v1';
  static const String _cleanupUrl = 'https://clipdrop-api.co/cleanup/v1'; // Fixed URL according to official docs
  static const String _uncropUrl = 'https://clipdrop-api.co/uncrop/v1';
  static const String _imageUpscalingUrl = 'https://clipdrop-api.co/image-upscaling/v1/upscale'; // Correct URL with /upscale
  static const String _reimagineUrl = 'https://clipdrop-api.co/reimagine/v1';
  static const String _productPhotographyUrl = 'https://clipdrop-api.co/product-photography/v1';
  static const String _textToImageUrl = 'https://clipdrop-api.co/text-to-image/v1';
  static const String _replaceBackgroundUrl = 'https://clipdrop-api.co/replace-background/v1';

  late Dio _dio;
  String _currentApiKey = '';
  String _primaryApiKey = '';
  String _backupApiKey = '';
  bool _usingBackupApi = false;

  ClipDropService() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
    ));
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
      print('DioException caught: ${e.response?.statusCode} - ${e.message}');
      print('Response data: ${e.response?.data}');
      
      // Check if it's a quota/credit related error
      final isQuotaError = e.response?.statusCode == 400 ||
                         e.response?.statusCode == 402 ||
                         e.response?.statusCode == 429 ||
                         (e.response?.data != null && 
                          e.response!.data.toString().toLowerCase().contains('quota')) ||
                         (e.response?.data != null && 
                          e.response!.data.toString().toLowerCase().contains('credit')) ||
                         (e.response?.data != null && 
                          e.response!.data.toString().toLowerCase().contains('limit'));
      
      final isAuthError = e.response?.statusCode == 401 || e.response?.statusCode == 403;
      
      if (isQuotaError && !_usingBackupApi) {
        print('API chính hết credit/quota, đang chuyển sang API dự phòng...');
        _switchToBackupApi();
        
        // Retry with backup API
        try {
          return await operation();
        } catch (retryError) {
          print('Backup API cũng thất bại: $retryError');
          // If backup also fails, throw original error
          rethrow;
        }
      } else if (isQuotaError && _usingBackupApi) {
        // Both APIs exhausted
        throw Exception('Cả hai API đều đã hết credit/quota. Vui lòng thử lại sau hoặc liên hệ để nạp thêm credit.');
      } else if (isAuthError) {
        throw Exception('API key không hợp lệ (${e.response?.statusCode}). Vui lòng kiểm tra lại API key trong Cài đặt.');
      }
      
      // Re-throw the original exception for other types of errors
      throw Exception('API error (${e.response?.statusCode}): ${e.response?.statusMessage ?? e.message}');
    } catch (e) {
      print('Non-DioException caught: $e');
      rethrow;
    }
  }

  Future<Uint8List> processImage(
    File imageFile, 
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
        case ProcessingOperation.removeLogo:
          apiUrl = _removeTextUrl; // Logo removal uses same endpoint as text removal
          break;
        case ProcessingOperation.uncrop:
          apiUrl = _uncropUrl;
          break;
        case ProcessingOperation.imageUpscaling:
          apiUrl = _imageUpscalingUrl;
          break;
        case ProcessingOperation.reimagine:
          apiUrl = _reimagineUrl;
          break;
        case ProcessingOperation.productPhotography:
          apiUrl = _productPhotographyUrl;
          break;
        case ProcessingOperation.textToImage:
          apiUrl = _textToImageUrl;
          break;
        case ProcessingOperation.replaceBackground:
          apiUrl = _replaceBackgroundUrl;
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
                filename: 'mask.png', // Force PNG extension as required by API
              ),
            ));
            // Add mode parameter for quality control (quality for better results)
            formData.fields.add(MapEntry('mode', 'quality'));
          } else {
            throw Exception('Cleanup operation requires a mask file');
          }
          break;
        
        case ProcessingOperation.uncrop:
          // Set default values if not provided
          final ratio = aspectRatio ?? '1:1';
          final extend = uncropExtendRatio ?? 1.5;
          formData.fields.add(MapEntry('aspect_ratio', ratio));
          formData.fields.add(MapEntry('extend_ratio', extend.toString()));
          break;
        
        case ProcessingOperation.imageUpscaling:
          // Set default values if not provided (Max 4096 per official documentation)
          final width = targetWidth ?? 2048;
          final height = targetHeight ?? 2048;
          // Validate dimensions according to API limits
          if (width < 1 || width > 4096 || height < 1 || height > 4096) {
            throw Exception('Image upscaling dimensions must be between 1 and 4096 pixels');
          }
          formData.fields.add(MapEntry('target_width', width.toString()));
          formData.fields.add(MapEntry('target_height', height.toString()));
          break;
        
        case ProcessingOperation.productPhotography:
          // Set default scene if not provided
          final selectedScene = scene ?? 'forest';
          formData.fields.add(MapEntry('scene', selectedScene));
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
          } else if (prompt != null && prompt.isNotEmpty) {
            formData.fields.add(MapEntry('prompt', prompt));
          } else {
            throw Exception('Replace background operation requires either a background image or a text prompt');
          }
          break;
        
        case ProcessingOperation.removeText:
        case ProcessingOperation.removeLogo:
        case ProcessingOperation.removeBackground:
        case ProcessingOperation.reimagine:
          // These operations don't need additional parameters
          break;
        
        default:
          // No additional parameters needed
          break;
      }

      print('Đang gọi API: $apiUrl');
      print('Sử dụng API key: ${_currentApiKey.substring(0, 8)}...');
      print('Operation: $operation');
      
      final response = await _dio.post(
        apiUrl,
        data: formData,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'x-api-key': _currentApiKey,
          },
        ),
      );

      print('Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('API call successful, returning image data (${response.data.length} bytes)');
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
    return processImage(imageFile, ProcessingOperation.removeLogo);
  }

  // New API methods
  Future<Uint8List> uncrop(File imageFile, {String? aspectRatio, double? extendRatio}) async {
    return processImage(
      imageFile, 
      ProcessingOperation.uncrop,
      aspectRatio: aspectRatio,
      uncropExtendRatio: extendRatio,
    );
  }

  Future<Uint8List> upscaleImage(File imageFile, {int? targetWidth, int? targetHeight}) async {
    return processImage(
      imageFile, 
      ProcessingOperation.imageUpscaling,
      targetWidth: targetWidth,
      targetHeight: targetHeight,
    );
  }

  Future<Uint8List> reimagine(File imageFile) async {
    return processImage(imageFile, ProcessingOperation.reimagine);
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

      print('Đang gọi text-to-image API: $_textToImageUrl');
      print('Prompt: $prompt');
      print('Sử dụng API key: ${_currentApiKey.substring(0, 8)}...');
      
      final response = await _dio.post(
        _textToImageUrl,
        data: formData,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'x-api-key': _currentApiKey,
          },
        ),
      );

      print('Text-to-image response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('Text-to-image API call successful, returning image data (${response.data.length} bytes)');
        return Uint8List.fromList(response.data);
      } else {
        print('Text-to-image API error response: ${response.data}');
        throw Exception('API error: ${response.statusCode} - ${response.statusMessage}');
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

  // Test method to check API connectivity and configuration
  Future<Map<String, dynamic>> testApiEndpoints() async {
    final results = <String, dynamic>{};
    
    // Test endpoints that don't require images
    final testEndpoints = {
      'Remove Background': _removeBackgroundUrl,
      'Text to Image': _textToImageUrl,
      'Remove Text': _removeTextUrl,
      'Cleanup': _cleanupUrl,
      'Uncrop': _uncropUrl,
      'Image Upscaling': _imageUpscalingUrl,
      'Reimagine': _reimagineUrl,
      'Product Photography': _productPhotographyUrl,
      'Replace Background': _replaceBackgroundUrl,
    };

    for (final entry in testEndpoints.entries) {
      try {
        // Make a HEAD request to check if endpoint exists
        final response = await _dio.head(
          entry.value,
          options: Options(
            headers: {'x-api-key': _currentApiKey},
            validateStatus: (status) => status != null && status < 500,
          ),
        );
        
        results[entry.key] = {
          'url': entry.value,
          'status': response.statusCode,
          'accessible': response.statusCode != 404,
          'message': response.statusCode == 404 
              ? 'Endpoint not found' 
              : response.statusCode == 401 || response.statusCode == 403
                  ? 'Authentication failed'
                  : 'Endpoint accessible'
        };
      } catch (e) {
        results[entry.key] = {
          'url': entry.value,
          'status': 'error',
          'accessible': false,
          'message': e.toString(),
        };
      }
    }

    // Add API key status
    results['API Configuration'] = {
      'primary_key_set': _primaryApiKey.isNotEmpty,
      'backup_key_set': _backupApiKey.isNotEmpty,
      'current_key_length': _currentApiKey.length,
      'using_backup': _usingBackupApi,
    };

    return results;
  }
}