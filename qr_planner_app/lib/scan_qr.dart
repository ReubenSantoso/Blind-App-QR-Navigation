import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanQR extends StatefulWidget {
  const ScanQR({Key? key}) : super(key: key);

  @override
  _ScanQRState createState() => _ScanQRState();
}

class _ScanQRState extends State<ScanQR> {
  final qrKey = GlobalKey(debugLabel: 'QR');

  Barcode? barcode;
  QRViewController? controller; //qr scanner controller

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override //to fix hot reload
  void reassemble() async {
    super.reassemble();

    if (Platform.isAndroid) {
      await controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Name'),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // buildQRView(context),
          Positioned(
              bottom: 10,
              child: buildResult()), //to display data in text at the bottom
          Positioned(
            top: 10,
            child: buildControlButtons(),
          )
        ],
      ),
    );
  }

  Widget buildControlButtons() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8), //frame of scanning
          color: Colors.white60,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.flash_off), //see 9:09
              onPressed: () async {
                await controller?.toggleFlash();
                setState(() {});
              },
            ),
            IconButton(
                icon: Icon(Icons.switch_camera),
                onPressed: () async {
                  await controller?.flipCamera();
                  setState(() {});
                }),
          ],
        ),
      );

  Widget buildResult() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white60,
        ),
        child: Text(
          barcode != null ? 'Result : ${barcode!.code}' : 'Start Scanning',
          maxLines: 3,
        ),
      );

  // Widget buildQRView(BuildContext context) => QRView(
  //       key: qrKey,
  //       onQRViewCreated: onQRViewCreated,
  //       overlay: QrScannerOverlayShape(
  //         borderLength: 20,
  //         borderWidth: 10,
  //         cutOutSize: MediaQuery.of(context).size.width * 0.8, //80% of screen
  //       ),
  //     );

  // void onQRViewCreated(QRViewController controller) {
  //   setState(() => this.controller = controller);

  //   controller.scannedDataStream //listen to scanned data
  //       .listen((barcode) => setState(() => this.barcode = barcode));
  // }
}
