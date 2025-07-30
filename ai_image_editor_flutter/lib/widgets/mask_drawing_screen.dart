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
      // Get canvas render boundary
      final RenderRepaintBoundary boundary = 
          _canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      
      // Capture the canvas as image
      final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        throw Exception('Không thể tạo mask');
      }

      // Convert to mask format (black and white only)
      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final img.Image? maskImage = img.decodePng(pngBytes);
      
      if (maskImage == null) {
        throw Exception('Không thể decode mask image');
      }

      // Convert to binary mask (0 = keep, 255 = remove)
      final img.Image binaryMask = img.Image(
        width: maskImage.width,
        height: maskImage.height,
        numChannels: 1,
      );

      for (int y = 0; y < maskImage.height; y++) {
        for (int x = 0; x < maskImage.width; x++) {
          final pixel = maskImage.getPixel(x, y);
          // If pixel is not transparent (alpha > 0), mark as remove (255)
          // Otherwise mark as keep (0)
          final alpha = img.getAlpha(pixel);
          final maskValue = alpha > 128 ? 255 : 0;
          binaryMask.setPixelRgba(x, y, maskValue, maskValue, maskValue, 255);
        }
      }

      // Save mask file
      final directory = await getTemporaryDirectory();
      final maskFile = File('${directory.path}/cleanup_mask_${DateTime.now().millisecondsSinceEpoch}.png');
      await maskFile.writeAsBytes(img.encodePng(binaryMask));

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