# camcode

A camera barcode scan library for Flutter Web

## Getting Started

```
import 'package:camcode/CamCodeScanner.dart';

showDialog(
    context: context,
    builder: (context) => CamCodeScanner(
    width: MediaQuery.of(context).size.width,
    height: MediaQuery.of(context).size.height,
    refreshDelayMillis: 200,
    onBarcodeResult: (barcode) {
        Navigator.of(context).pushNamed("/", arguments: barcode);
    },
    ),
);
```
