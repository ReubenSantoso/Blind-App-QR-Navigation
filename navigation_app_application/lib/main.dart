import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ScanQR(),
    );
  }
}

class ScanQR extends StatefulWidget {
  const ScanQR({Key? key}) : super(key: key);

  @override
  _ScanQRState createState() => _ScanQRState();
}

class _ScanQRState extends State<ScanQR> {
  final qrKey = GlobalKey(debugLabel: 'QR');

  Barcode? result;
  QRViewController? controller;

  String? get text => null; //qr scanner controller

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
    TextButton;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blind App Scanner'),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          buildQRView(context),
          Positioned(
            bottom: 10,
            child: buildResult(), //to display data in text at the bottom
          ),
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

  Widget buildResult() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white60,
      ),
      child: Text(
        result != null ? result!.code.toString() : 'Start Scanning',
        //if result not empty either print qr content in string or 'start scanning'
        maxLines: 3,
        style: TextStyle(fontSize: 15),
      ),
    );
  }

  Widget buildQRView(BuildContext context) => QRView(
        key: qrKey,
        onQRViewCreated: onQRViewCreated,
        // overlay: QrScannerOverlayShape(
        //   borderLength: 20,
        //   borderWidth: 10,
        //   cutOutSize: MediaQuery.of(context).size.width * 0.8, //80% of screen
        // ),
      );

  void onQRViewCreated(QRViewController controller) {
    this.controller = controller;

    controller.scannedDataStream //listen to scanned data
        //the barcode the camera has scanned, then grab the barcode, then store that barcode inside the state
        .listen((barcode) async {
      setState(() {
        result = barcode;
      });
      controller.pauseCamera();
      await _speakResult(result!.code.toString());
      controller.resumeCamera();
    });
  }

  Future _speakResult(String text) async {
    FlutterTts flutterTts = FlutterTts();
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.setSharedInstance(true);
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.ambient,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers
        ],
        IosTextToSpeechAudioMode.voicePrompt);
    await flutterTts.setVolume(5);
    await flutterTts.setLanguage("en-US");
    await flutterTts.speak(text);
  }
}
