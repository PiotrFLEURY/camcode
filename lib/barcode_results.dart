/// Store and count every potential result
/// Once a barcode was identified minimalResultCount times, it is considered as a valid result
class BarcodeResults {
  /// Set to true if you want to get the first scanned value
  /// with no concordance check
  bool singleShot;

  /// Number of identic scanned value to get before consider getting result
  int minimalResultCount;

  /// list of barcode results
  final Map<String, int> _barcodeResults = {};

  BarcodeResults({
    this.singleShot = false,
    this.minimalResultCount = 2,
  });

  /// clears all barcode results
  void clear() {
    _barcodeResults.clear();
  }

  /// return the actual barcode results count
  int get resultCount => _barcodeResults.values.reduce((a, b) => a + b);

  /// Consider that we have a barcode result once enough identic results are found
  bool get gotResult => _containsSingleShotResult || _containesConcordance;

  /// return true if singleShot mode is enabled and resultCount is positive
  bool get _containsSingleShotResult => singleShot && resultCount > 0;

  /// return true if results contains at least minimalResultCount
  /// of the same barcode
  bool get _containesConcordance =>
      resultCount >= 2 &&
      _barcodeResults.values.any(
        (singleBarcodeCount) => singleBarcodeCount >= minimalResultCount,
      );

  /// adds a new barcode result
  void add(String barcode) {
    final _currentBarcodeCount = _barcodeResults[barcode] ?? 0;
    _barcodeResults[barcode] = _currentBarcodeCount + 1;
  }

  /// returns the count of a barcode
  int countOf(String barcode) => _barcodeResults[barcode] ?? 0;

  /// returns the barcode with the most results
  String get mostFrequentBarcode => _barcodeResults.keys.reduce(
        (a, b) => countOf(a) > countOf(b) ? a : b,
      );
}
