import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class tensorflow_image extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return tensorflow_state();
  }
}

class tensorflow_state extends State<tensorflow_image> {
  File pickedImage;
  var text = '';
  bool _busy = false;
  bool imageLoaded = false;
  List _recognitions;

  Future pickImage() async {
    var awaitImage = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      pickedImage = awaitImage;
      imageLoaded = true;
      _busy = true;
    });

    if (pickedImage != null) {
      recognizeImage(pickedImage);
    }
  }

  Future recognizeImage(File image) async {
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.092,
      imageMean: 0,
      imageStd: 255,
    );
    setState(() {
      _recognitions = recognitions;
    });

    for (int i = 0; i < _recognitions.length; i++) {
      final double confidence = _recognitions[i]["confidence"];
      setState(() {
        text = text +
            _recognitions[i]['label'] +
            "     " +
            confidence.toStringAsFixed(2) +
            ' \n';
      });
    }
  }

  Future loadModel() async {
    Tflite.close();
    try {
      String res = await Tflite.loadModel(
        model: "assets/new_mobile_model.tflite",
        labels: "assets/class_labels.txt",
      );
      print(res);
    } on PlatformException {
      print('Failed to load model.');
    }
  }

  @override
  void initState() {
    super.initState();
    loadModel().then((val) {
      setState(() {
        _busy = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: Container(
          margin: EdgeInsets.only(bottom: 20),
          child: GestureDetector(
            onTap: () {
              text = '';
              pickImage();
            },
            child: Image.asset(
              "assets/ic_scan.png",
              height: 120,
            ),
          )),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsetsDirectional.only(top: 20, start: 14, end: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Image.asset(
                    'assets/ic_icon.png',
                    width: 150,
                  )
                ],
              ),
            ),
            Container(
                margin: EdgeInsets.only(top: 80, left: 14, right: 14),
                child: DottedBorder(
                  borderType: BorderType.RRect,
                  dashPattern: [6, 4, 6, 4],
                  radius: Radius.circular(10),
                  padding: EdgeInsets.all(1),
                  strokeWidth: 1,
                  color: Colors.white,
                  strokeCap: StrokeCap.butt,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    child: Container(
                        height: 250,
                        child: imageLoaded
                            ? Center(
                                child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  /*  boxShadow: const [
                                    BoxShadow(blurRadius: 20),
                                  ],*/
                                ),
                                margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                height: 250,
                                child: pickedImage != null
                                    ? Image.file(
                                        pickedImage,
                                        fit: BoxFit.cover,
                                      )
                                    : Text(""),
                              ))
                            : Container()),
                  ),
                )),
            text == ''
                ? Container(
                    margin: EdgeInsets.only(
                      top: 10,
                    ),
                    child: Text(
                      'Results will display here', // You must convert all outputs from model
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  )
                : Expanded(
                    child: Container(
                        margin: EdgeInsets.only(top: 10, bottom: 10),
                        child: SingleChildScrollView(
                          child: Text(
                            text,
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        )),
                  ),
          ],
        ),
      ),
    );
  }
}
