
import 'package:firebase_dart/core.dart';
import 'package:firebase_dart/implementation/pure_dart.dart';
import 'package:flutter/material.dart';
import 'package:piggery/pages/home.dart';

var app;
void main() async{
  var options = FirebaseOptions(
      appId: '1:169152263001:android:6804573d9b75699ba75248',
      apiKey: 'AIzaSyBQPuWvhB7ATHmF4yOKHTDhC-DYLj2sPKo',
      projectId: 'esp32cam-41b21',
      messagingSenderId: 'ignore',
      authDomain: 'esp32cam-41b21.firebaseapp.com',
      storageBucket: 'esp32cam-41b21.appspot.com'
  );
  FirebaseDart.setup();
  app = await Firebase.initializeApp(options: options);
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

