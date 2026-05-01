import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../core/theme.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );

  bool _scanned = false;
  bool _torchOn = false;

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    _scanned = true;
    HapticFeedback.mediumImpact();
    _controller.stop();

    Navigator.pop(context, barcode!.rawValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera feed
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Dimmed overlay with scan window cutout
          CustomPaint(
            painter: _OverlayPainter(),
            child: const SizedBox.expand(),
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _circleBtn(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Scan Barcode',
                      style: TayyibText.headline(color: Colors.white),
                    ),
                  ),
                  _circleBtn(
                    icon: _torchOn
                        ? Icons.flash_on_rounded
                        : Icons.flash_off_rounded,
                    filled: _torchOn,
                    onTap: () {
                      _controller.toggleTorch();
                      setState(() => _torchOn = !_torchOn);
                    },
                  ),
                ],
              ),
            ),
          ),

          // Bottom hint
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 52),
                child: Text(
                  'Point at any barcode or QR code',
                  style: TayyibText.callout(color: Colors.white70),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn({
    required IconData icon,
    required VoidCallback onTap,
    bool filled = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: filled
              ? Colors.white.withOpacity(0.9)
              : Colors.black.withOpacity(0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: filled ? Colors.black : Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

// Dimmed overlay with a transparent scan window and corner brackets
class _OverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const windowW = 260.0;
    const windowH = 200.0;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: windowW,
      height: windowH,
    );

    // Dim surrounding area
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, Paint()..color = Colors.black.withOpacity(0.55));

    // Corner brackets
    const cLen = 24.0;
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Top-left
    canvas.drawLine(
        Offset(rect.left, rect.top + cLen), Offset(rect.left, rect.top), p);
    canvas.drawLine(
        Offset(rect.left, rect.top), Offset(rect.left + cLen, rect.top), p);
    // Top-right
    canvas.drawLine(
        Offset(rect.right - cLen, rect.top), Offset(rect.right, rect.top), p);
    canvas.drawLine(
        Offset(rect.right, rect.top), Offset(rect.right, rect.top + cLen), p);
    // Bottom-left
    canvas.drawLine(Offset(rect.left, rect.bottom - cLen),
        Offset(rect.left, rect.bottom), p);
    canvas.drawLine(Offset(rect.left, rect.bottom),
        Offset(rect.left + cLen, rect.bottom), p);
    // Bottom-right
    canvas.drawLine(Offset(rect.right - cLen, rect.bottom),
        Offset(rect.right, rect.bottom), p);
    canvas.drawLine(Offset(rect.right, rect.bottom),
        Offset(rect.right, rect.bottom - cLen), p);
  }

  @override
  bool shouldRepaint(_) => false;
}
