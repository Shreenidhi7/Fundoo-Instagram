import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:insta_clone/pages/home.dart';

void main() {
  // Firestore.instance.settings(timestampsInSnapshotsEnabled: true).then((_){
  //   print("Timestamp enabled in snapshots\n");
  // },onError: (_){
  //   print("Error enabling Timestamps in snapshots\n");
  // });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterShare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,  // gives different shades
        accentColor: Colors.teal
      ),
      home: Home(),
    );
  }
}
