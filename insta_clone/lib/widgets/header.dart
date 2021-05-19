import 'package:flutter/material.dart';

AppBar header(context,{bool isAppTitle = false , String titleText , removeBackButton = false}  ) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
    title: Text( isAppTitle ? "FlutterShare" : titleText,
      style: TextStyle(
      fontSize: isAppTitle ? 50 : 22,
        fontFamily: isAppTitle  ? "Signatra" : "",
    ),),
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
  );
}
