function detectBarcode(dataUrl, callback) {
    Quagga.decodeSingle({
        decoder: {
            readers: [
                "code_128_reader",
                "ean_reader",
                "ean_8_reader",
                "code_39_reader",
                "code_39_vin_reader",
                "code_93_reader"
            ] // List of active readers
        },
        locate: true, // try to locate the barcode in the image
        src: dataUrl // or 'data:image/jpg;base64,' + data
    }, function (result) {
        if (result && result.codeResult) {
            console.log("result", result.codeResult.code);
            callback(result.codeResult.code);
        } else {
            console.log("not detected");
        }
    });
}