import 'package:flutter/material.dart';
import 'package:spektrum_app/tensorflow_image.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: tensorflow_image(),
    );
  }
}


