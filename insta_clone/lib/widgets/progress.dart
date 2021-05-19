import 'package:flutter/material.dart';

Container circularProgress() {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 10),
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
    ),
  );
}

Container linearProgress() {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 10),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
    ),
  );
}
