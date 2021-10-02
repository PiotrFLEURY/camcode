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
    return MaterialApp(
      home: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.scanner),
          onPressed: () => openScanner(context, _onResult),
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

  void _onResult(String result) {
    setState(() {
      barcodeValue = result;
    });
  }

  void openScanner(BuildContext context, Function(String) onResult) {
    showDialog(
      context: context,
      builder: (context) => Stack(
        children: [
          CamCodeScanner(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            refreshDelayMillis: 200,
            onBarcodeResult: (barcode) {
              Navigator.of(context).pop();
              onResult(barcode);
            },
            controller: _controller,
            showDebugFrames: true,
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
