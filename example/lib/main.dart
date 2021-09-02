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
      builder: (context) => CamCodeScanner(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        refreshDelayMillis: 100,
        showOverlay: true,
        overlayColor: Colors.blue,
        onBarcodeResult: (barcode) {
          Navigator.of(context).pushNamed('/', arguments: barcode);
        },
      ),
    );
  }
}
