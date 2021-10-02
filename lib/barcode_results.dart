class BarcodeResults {
  // list of barcode results
  final Map<String, int> _barcodeResults = {};

  void clear() {
    _barcodeResults.clear();
  }

  // return the actual barcode results count
  int get resultCount => _barcodeResults.values.reduce((a, b) => a + b);

  // Consider that we have a barcode result once enough identic results are found
  bool get gotResult =>
      resultCount > 2 &&
      _barcodeResults.values.any(
        (singleBarcodeCount) => singleBarcodeCount > 2,
      );

  // adds a new barcode result
  void add(String barcode) {
    final _currentBarcodeCount = _barcodeResults[barcode] ?? 0;
    _barcodeResults[barcode] = _currentBarcodeCount + 1;
  }

  // returns the count of a barcode
  int countOf(String barcode) => _barcodeResults[barcode] ?? 0;

  // returns the barcode with the most results
  String get mostFrequentBarcode => _barcodeResults.keys.reduce(
        (a, b) => countOf(a) > countOf(b) ? a : b,
      );
}
