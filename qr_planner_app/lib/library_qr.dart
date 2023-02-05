import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class LibraryQR extends StatefulWidget {
  const LibraryQR({Key? key}) : super(key: key);

  @override
  _LibraryQRState createState() => _LibraryQRState();
}

class _LibraryQRState extends State<LibraryQR> {
  final Stream<QuerySnapshot> qr_codes =
      FirebaseFirestore.instance.collection('QR Codes').snapshots();
  GlobalKey globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: qr_codes,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                  "Start Making Your First QR Code"), //if no data play this child
            );
          }

          return ListView(
              children: snapshot.data!.docs.map((document) {
            return Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      showQRFunc(context, document,
                          snapshot); //ontap to more specific QR data
                    },
                    child: Card(
                        margin:
                            const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                        child: Column(
                          children: [
                            QrImage(
                              data: document['qrData'],
                              size: 200,
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.all(10),
                            ),
                            Text(document['qrTitle']),
                          ],
                        )),
                  )
                ],
              ),
            );
          }).toList());
        },
      ),
    );
  }

  showQRFunc(context, document, snapshot) async {
    return showDialog(
        context: context,
        builder: (context) {
          return Center(
              child: Material(
            type: MaterialType.transparency,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              padding: EdgeInsets.all(15),
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.width * 0.7,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    ClipRRect(
                      //QR image
                      borderRadius: BorderRadius.circular(5),
                      child: QrImage(
                        data: document['qrData'],
                        size: 200,
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.all(10),
                      ),
                    ),
                    Text(
                      document['qrTitle'], //QR title name
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 15),
                    Center(
                      child: Text(
                        document['qrData'], //full QR data
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(children: [
                            //delete buttoon
                            Align(
                              alignment: Alignment.bottomRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  deleteQR(document.id);
                                },
                                child: const Icon(Icons.delete_forever_sharp,
                                    color: Colors.white),
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(20),
                                  primary: Colors.blue, // <-- Button color
                                  onPrimary: Colors.red, // <-- Splash color
                                ),
                              ),
                            ),
                          ]),
                          Row(children: [
                            Align(
                              //share button
                              alignment: Alignment.bottomRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  // _captureAndSharePng();
                                },
                                child: const Icon(Icons.share,
                                    color: Colors.white),
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(20),
                                  primary: Colors.blue, // <-- Button color
                                  onPrimary: Colors.green, // <-- Splash color
                                ),
                              ),
                            ),
                          ]),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ));
        });
  }

  Future<void> _captureAndSharePng() async {
    final RenderRepaintBoundary? boundary =
        globalKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary!.toImage();
    final ByteData? byteData =
        await image.toByteData(format: ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/image.png').create();
    await file.writeAsBytes(pngBytes);

    const channel = MethodChannel('channel:me.alfian.share/share');
    channel.invokeMethod('shareFile', 'image.png');
  }

  Future<void> deleteQR(documentID) async {
    await FirebaseFirestore.instance
        .collection("QR Codes")
        .doc(documentID)
        .delete();
  }
}
