import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // debugPrint
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController _controller = MobileScannerController(
    torchEnabled: false,
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    debugPrint('[ScanScreen] initState');
  }

  @override
  void dispose() {
    debugPrint('[ScanScreen] dispose -> controller.dispose()');
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[ScanScreen] build()');
    return Scaffold(
        appBar: AppBar(title: const Text('Skanuj')),
    body: Column(
    children: [
    Expanded(
    flex: 4,
    child: Stack(
    fit: StackFit.expand,
    children: [
    MobileScanner(
    controller: _controller,
    onDetect: (capture) async {
    if (_handled) return;
    final barcodes = capture.barcodes;
    debugPrint('[ScanScreen] onDetect: count=${barcodes.length}');
    if (barcodes.isEmpty) return;
    final value = barcodes.first.rawValue;
    debugPrint('[ScanScreen] onDetect: value="$value"');
    if (value == null || value.trim().isEmpty) return;
    _handled = true;
    await _controller.stop();
    if (!mounted) return;
    context.pop(value.trim());
    },
    ),
    Center(
    child: Container(
    width: MediaQuery.of(context).size.width * 0.7,
    height: MediaQuery.of(context).size.width * 0.7,
    decoration: BoxDecoration(
    border: Border.all(width: 3),
    borderRadius: BorderRadius.circular(16),
    ),
    ),
    ),
    ],
    ),
    ),
      Expanded(
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  debugPrint('[ScanScreen] toggleTorch');
                  _controller.toggleTorch();
                },
                icon: const Icon(Icons.flash_on),
                label: const Text('Latarka'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {
                  debugPrint('[ScanScreen] switchCamera');
                  _controller.switchCamera();
                },
                icon: const Icon(Icons.cameraswitch),
                label: const Text('Zmień kamerę'),
              ),
            ],
          ),
        ),
      ),
    ],
    ),
    );
  }
}