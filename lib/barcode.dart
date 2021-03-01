@JS()
library barcode;

import 'package:js/js.dart';

@JS("detectBarcode")
external void detectBarcode(String dataUrl, BarcodeDetectionCallback callback);

typedef void BarcodeDetectionCallback(String result);
