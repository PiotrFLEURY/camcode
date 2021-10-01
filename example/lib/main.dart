import 'package:camcode/cam_code_scanner.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      routes: {
        '/': (context) => MyApp(),
      },
      initialRoute: '/',
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String barcodeValue = 'Press button to scan a barcode';

  // Create a controller to send instructions to scanner
  final CamCodeScannerController _controller = CamCodeScannerController();

  @override
  Widget build(BuildContext context) {
    barcodeValue = ModalRoute.of(context)?.settings.arguments as String? ??
        'Press button to scan a barcode';
    return MaterialApp(
      home: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.scanner),
          onPressed: () => openScanner(context),
        ),
        appBar: AppBar(
          title: const Text('CamCode example app'),
        ),
        body: Center(
          child: Text(barcodeValue),
        ),
      ),
    );
  }

  void openScanner(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Stack(
        children: [
          CamCodeScanner(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            refreshDelayMillis: 800,
            onBarcodeResult: (barcode) {
              Navigator.of(context).pushNamed('/', arguments: barcode);
            },
            controller: _controller,
          ),
          Positioned(
            bottom: 48.0,
            left: MediaQuery.of(context).size.width / 2,
            child: ElevatedButton(
              onPressed: () {
                _controller.releaseResources();
              },
              child: Text('Release resources'),
            ),
          ),
        ],
      ),
    );
  }
}
