import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class MaskDrawingScreen extends StatefulWidget {
  final File originalImage;
  final Function(File) onMaskCreated;

  const MaskDrawingScreen({
    super.key,
    required this.originalImage,
    required this.onMaskCreated,
  });

  @override
  State<MaskDrawingScreen> createState() => _MaskDrawingScreenState();
}

class _MaskDrawingScreenState extends State<MaskDrawingScreen> {
  final GlobalKey _canvasKey = GlobalKey();
  final List<Offset> _points = [];
  final List<Path> _paths = [];
  double _brushSize = 20.0;
  bool _isDrawing = false;
  Path _currentPath = Path();
  ui.Image? _backgroundImage;

  @override
  void initState() {
    super.initState();
    _loadBackgroundImage();
  }

  Future<void> _loadBackgroundImage() async {
    final bytes = await widget.originalImage.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    setState(() {
      _backgroundImage = frame.image;
    });
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDrawing = true;
      _currentPath = Path();
      _currentPath.moveTo(details.localPosition.dx, details.localPosition.dy);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isDrawing) {
      setState(() {
        _currentPath.lineTo(details.localPosition.dx, details.localPosition.dy);
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDrawing = false;
      _paths.add(Path.from(_currentPath));
    });
  }

  void _clearMask() {
    setState(() {
      _paths.clear();
      _currentPath = Path();
    });
  }

  Future<void> _createMask() async {
    try {
      // Get original image dimensions first
      final originalImageBytes = await widget.originalImage.readAsBytes();
      final img.Image? originalImg = img.decodeImage(originalImageBytes);
      if (originalImg == null) {
        throw Exception('Không thể đọc ảnh gốc');
      }

      // Get canvas render boundary
      final RenderRepaintBoundary boundary = 
          _canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      
      // Capture the canvas as image
      final ui.Image canvasImage = await boundary.toImage(pixelRatio: 1.0);
      final ByteData? byteData = await canvasImage.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        throw Exception('Không thể tạo mask từ canvas');
      }

      // Convert canvas to mask format
      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final img.Image? canvasMask = img.decodePng(pngBytes);
      
      if (canvasMask == null) {
        throw Exception('Không thể decode canvas mask');
      }

      // Resize canvas mask to match original image dimensions
      final img.Image resizedCanvasMask = img.copyResize(
        canvasMask,
        width: originalImg.width,
        height: originalImg.height,
        interpolation: img.Interpolation.nearest,
      );

      // Create binary mask with same dimensions as original image
      final img.Image binaryMask = img.Image(
        width: originalImg.width,
        height: originalImg.height,
        numChannels: 1, // Grayscale for better performance and compatibility
      );

      // Fill with black background (0 = keep as per Clipdrop API)
      img.fill(binaryMask, color: img.ColorUint8.gray(0));

      // Count pixels to validate mask
      int whitePixelCount = 0;
      int totalPixels = originalImg.width * originalImg.height;

      // Convert drawn areas to white (255 = remove as per Clipdrop API)
      for (int y = 0; y < originalImg.height; y++) {
        for (int x = 0; x < originalImg.width; x++) {
          final pixel = resizedCanvasMask.getPixel(x, y);
          final alpha = pixel.a;
          // If alpha > threshold, mark as area to remove (white = 255)
          // Use lower threshold for better detection of drawn strokes
          if (alpha > 10) { // Very low threshold to catch even light strokes
            binaryMask.setPixelGray(x, y, 255); // White = remove
            whitePixelCount++;
          }
          // Black areas (alpha <= 10) remain black = keep (already filled with black)
        }
      }

      // Validate mask quality
      double whitePercentage = (whitePixelCount / totalPixels) * 100;
      print('Mask created: ${originalImg.width}x${originalImg.height} pixels');
      print('White pixels (remove): $whitePixelCount (${whitePercentage.toStringAsFixed(1)}%)');
      print('Black pixels (keep): ${totalPixels - whitePixelCount} (${(100 - whitePercentage).toStringAsFixed(1)}%)');
      
      // Safety check - if more than 50% is white, something is wrong
      if (whitePercentage > 50.0) {
        print('WARNING: Mask có thể bị lỗi - quá nhiều vùng được đánh dấu xóa');
        throw Exception('Mask không hợp lệ: ${whitePercentage.toStringAsFixed(1)}% ảnh sẽ bị xóa. Vui lòng vẽ lại chính xác hơn.');
      }
      
      if (whitePixelCount == 0) {
        throw Exception('Không phát hiện vùng vẽ. Vui lòng vẽ trên những vùng cần xóa.');
      }

      // Save mask file as PNG
      final directory = await getTemporaryDirectory();
      final maskFile = File('${directory.path}/cleanup_mask_${DateTime.now().millisecondsSinceEpoch}.png');
      final pngBytes = img.encodePng(binaryMask);
      await maskFile.writeAsBytes(pngBytes);

      print('Mask file saved: ${maskFile.path}');
      print('Mask file size: ${pngBytes.length} bytes');
      
      // Validate saved mask file
      final savedMask = img.decodePng(pngBytes);
      if (savedMask == null) {
        throw Exception('Lỗi: Không thể tạo file mask PNG hợp lệ');
      }
      
      print('Mask validation successful: ${savedMask.width}x${savedMask.height}');

      // Return the mask file
      widget.onMaskCreated(maskFile);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tạo mask: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Vẽ vùng cần xóa',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _clearMask,
            icon: const Icon(Icons.clear_all),
            tooltip: 'Xóa tất cả',
          ),
          IconButton(
            onPressed: _paths.isNotEmpty ? _createMask : null,
            icon: const Icon(Icons.check),
            tooltip: 'Hoàn thành',
          ),
        ],
      ),
      body: Column(
        children: [
          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Vẽ trên những vùng bạn muốn xóa khỏi ảnh. Vùng được vẽ sẽ bị loại bỏ.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Drawing Canvas
          Expanded(
            child: Center(
              child: RepaintBoundary(
                key: _canvasKey,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: GestureDetector(
                    onPanStart: _onPanStart,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    child: CustomPaint(
                      size: Size(
                        MediaQuery.of(context).size.width - 32,
                        MediaQuery.of(context).size.width - 32,
                      ),
                      painter: MaskPainter(
                        backgroundImage: _backgroundImage,
                        paths: _paths,
                        currentPath: _isDrawing ? _currentPath : null,
                        brushSize: _brushSize,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Brush Size Controls
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Kích thước cọ: ${_brushSize.round()}px',
                  style: const TextStyle(color: Colors.white),
                ),
                Slider(
                  value: _brushSize,
                  min: 5,
                  max: 50,
                  divisions: 9,
                  activeColor: Colors.blue,
                  onChanged: (value) {
                    setState(() {
                      _brushSize = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MaskPainter extends CustomPainter {
  final ui.Image? backgroundImage;
  final List<Path> paths;
  final Path? currentPath;
  final double brushSize;

  MaskPainter({
    this.backgroundImage,
    required this.paths,
    this.currentPath,
    required this.brushSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background image
    if (backgroundImage != null) {
      final paint = Paint();
      canvas.drawImageRect(
        backgroundImage!,
        Rect.fromLTWH(0, 0, backgroundImage!.width.toDouble(), backgroundImage!.height.toDouble()),
        Rect.fromLTWH(0, 0, size.width, size.height),
        paint,
      );
      
      // Add semi-transparent overlay
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.black.withOpacity(0.3),
      );
    }

    // Draw mask paths
    final maskPaint = Paint()
      ..color = Colors.red.withOpacity(0.7)
      ..strokeWidth = brushSize
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw completed paths
    for (final path in paths) {
      canvas.drawPath(path, maskPaint);
    }

    // Draw current path being drawn
    if (currentPath != null) {
      canvas.drawPath(currentPath!, maskPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}