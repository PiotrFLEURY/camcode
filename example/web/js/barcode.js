function detectBarcode(dataUrl, callback) {
    const hints = new Map();
    hints.set('TRY_HARDER', true);
    const codeReader = new ZXingBrowser.BrowserMultiFormatReader(hints);
    console.log('ZXing code reader initialized');
    codeReader.decodeFromImageUrl(dataUrl).then((result) => {
        console.log(result);
        callback(result.text);
    }).catch((err) => {
        //console.error(err);
    })
    console.log(`Started decode for image from ${dataUrl.src}`);
}