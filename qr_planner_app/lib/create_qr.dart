import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CreateQR extends StatefulWidget {
  const CreateQR({Key? key}) : super(key: key);

  @override
  _CreateQRState createState() => _CreateQRState();
}

class _CreateQRState extends State<CreateQR> {
  final dataController = TextEditingController();
  final titleController = TextEditingController();

  void _saveQR() {
    final qrData = dataController.text;
    final qrTitle = titleController.text;
    FirebaseFirestore.instance
        .collection('QR Codes')
        .add({"qrTitle": qrTitle, "qrData": qrData});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create QR Code'),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
            MediaQuery.of(context).size.height * 0.1,
            MediaQuery.of(context).size.height * 0.03,
            MediaQuery.of(context).size.height * 0.1,
            MediaQuery.of(context).size.height * 0.03),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            QrImage(
              data: dataController.text,
              size: 200,
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(10),
              // embeddedImage: AssetImage('assets/images/my_embedded_image.png'),
              // embeddedImageStyle: QrEmbeddedImageStyle(
              // size: Size(80, 80),)
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            buildTitle(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            buildData(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            ClipRRect(
              child: TextButton(
                  child: const Text('Generate'),
                  onPressed: () => setState(() {
                        _saveQR();
                      }),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                  )),
            )
          ],
        ),
      ),
    );
  }

  Widget buildData() => TextField(
        controller: dataController,
        decoration: InputDecoration(
            labelText: 'QR Data',
            hintText: 'Turn Right',
            border: OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => dataController.clear(),
            )),
        keyboardType: TextInputType.name,
        textInputAction: TextInputAction.done,
      );

  Widget buildTitle() => TextField(
        controller: titleController,
        decoration: InputDecoration(
            labelText: 'QR Title',
            hintText: 'Main Lobby QR',
            border: OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => titleController.clear(),
            )),
        keyboardType: TextInputType.name,
        textInputAction: TextInputAction.done,
      );
}
