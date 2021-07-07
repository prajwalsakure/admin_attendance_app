import 'dart:io';
import 'dart:typed_data';

import 'package:attendance_app/database.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class CreateQR extends StatefulWidget {
  @override
  _CreateQRState createState() => _CreateQRState();
}

class _CreateQRState extends State<CreateQR> {
  String finalQR = "";
  String qrStr;
  String subject = '';
  getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    String lat = position.latitude.toStringAsPrecision(7);
    String long = position.longitude.toStringAsPrecision(7);
    qrStr = lat + " & " + long + " & ";
    print(qrStr + subject);
    Database().setSubject(subject);
    setState(() {
      finalQR = qrStr + subject;
    });
  }

  ScreenshotController controller = ScreenshotController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create QR for class"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Screenshot(
              controller: controller,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: BarcodeWidget(
                      color: Colors.teal,
                      data: finalQR,
                      height: 250,
                      width: 250,
                      barcode: Barcode.qrCode(),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    getLocation();
                  },
                  child: Text('Create QR'),
                ),
                ElevatedButton(
                    onPressed: () {
                      controller
                          .capture(delay: Duration(milliseconds: 10))
                          .then((capturedImage) async {
                        // shareImage(capturedImage);
                        showCapturedWidget(context, capturedImage);
                      }).catchError((onError) {
                        print(onError);
                      });
                    },
                    child: Text("Take ScreenShot")),
                ElevatedButton(
                    onPressed: () {
                      controller
                          .captureFromWidget(Container(
                        color: Colors.white,
                        height: 290,
                        width: 290,
                        child: Column(
                          children: [
                            Text(
                              "This is the Qr Code for : " + subject,
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: BarcodeWidget(
                                backgroundColor: Colors.white,
                                color: Colors.teal,
                                data: finalQR,
                                height: 200,
                                width: 200,
                                barcode: Barcode.qrCode(),
                              ),
                            ),
                          ],
                        ),
                      ))
                          .then((capturedImage) async {
                        shareImage(capturedImage);
                      }).catchError((onError) {
                        print(onError);
                      });
                    },
                    child: Text("send QR")),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextField(
                onSubmitted: (val) {
                  setState(() {
                    subject = val;
                    print(subject);
                  });
                },
                decoration: InputDecoration(
                    hintText: "Enter your subject name",
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2))),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
            )
          ],
        ),
      ),
    );
  }

  Future shareImage(Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final image = File('${directory.path}/$subject.png');
    image.writeAsBytesSync(bytes);
    await Share.shareFiles([image.path], text: subject);
  }

  Future<dynamic> showCapturedWidget(
      BuildContext context, Uint8List capturedImage) {
    return showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text("Captured widget screenshot"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Center(
              child: capturedImage != null
                  ? Image.memory(capturedImage)
                  : Container()),
        ),
      ),
    );
  }
}
