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
      builder: (context) => CamCodeScannerPage(_onResult),
    );
  }
}

class CamCodeScannerPage extends StatefulWidget {
  final Function(String) onResult;

  CamCodeScannerPage(this.onResult);

  @override
  _CamCodeScannerPageState createState() => _CamCodeScannerPageState();
}

class _CamCodeScannerPageState extends State<CamCodeScannerPage> {
  /// Create a controller to send instructions to scanner
  final CamCodeScannerController _controller = CamCodeScannerController();

  /// List of availables cameras
  final List<String> cameraNames = [];

  /// currently selected camera
  late String _selectedCamera;

  @override
  void initState() {
    super.initState();
    _fetchDeviceList();
  }

  void _fetchDeviceList() async {
    /// Get list of available cameras
    final cameras = await _controller.fetchDeviceList();
    setState(() {
      cameraNames.addAll(cameras);
      _selectedCamera = cameras.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CamCodeScanner(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            refreshDelayMillis: 16,
            onBarcodeResult: (barcode) {
              Navigator.of(context).pop();
              widget.onResult(barcode);
            },
            controller: _controller,
            showDebugFrames: true,
          ),
          Positioned(
            bottom: 48.0,
            left: 48.0,
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    _controller.releaseResources();
                  },
                  child: Text('Release resources'),
                ),
                cameraNames.isEmpty
                    ? Container()
                    : DropdownButton(
                        items: cameraNames
                            .map(
                              (name) => DropdownMenuItem(
                                child: Text(name),
                                value: name,
                              ),
                            )
                            .toList(),
                        onChanged: (String? value) {
                          if (value != null) {
                            _controller.selectDevice(value);
                            setState(() {
                              _selectedCamera = value;
                            });
                          }
                        },
                        value: _selectedCamera,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
