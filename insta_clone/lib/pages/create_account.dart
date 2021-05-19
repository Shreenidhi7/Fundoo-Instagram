import 'dart:async';

import 'package:flutter/material.dart';

import 'package:insta_clone/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();

   final _formKey  = GlobalKey<FormState>();

  String userName;

  submit(){
    final form =_formKey.currentState;

    if(form.validate()){
      form.save();
      
      SnackBar snackBar = SnackBar(content: Text("Welcome $userName!"));

      _scaffoldKey.currentState.showSnackBar(snackBar);
      
      Timer(Duration(seconds: 2),(){
        Navigator.pop(context, userName);
      });
      
      //Navigator.pop(context, userName);
    }


  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context,titleText: "Set Up Your Profile" ,removeBackButton: true),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(padding: EdgeInsets.only(top: 25),
                  child: Center(
                    child: Text("Create a UserName",
                    style: TextStyle(
                      fontSize: 25
                    ),),
                  ),
                ),

                Padding(padding: EdgeInsets.all(16.0),
                child: Container(
                  child: Form(
                    key: _formKey,
                      child: TextFormField(
                        autovalidate: true,
                        validator: (val) {
                          if(val.trim().length < 3 || val.isEmpty){
                            return "UserName Too Short";
                          } else if( val.trim().length > 12){
                            return "UserName Too Long";
                          }else{
                            return null;
                          }
                        },
                        onSaved: (val) => userName = val,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "UserName",
                        labelStyle: TextStyle(
                          fontSize: 15
                        ),
                        hintText: "Must be atleast 3 Characters",
                      ),
                  )),
                ),
                ),

                GestureDetector(
                  onTap: submit,
                  child: Container(
                    height: 50.0,
                    width: 200.0,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: Center(
                      child: Text("Submit",style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold
                      ),),
                    ),
                  ),
                ),


              ],
            ),
          )
        ],
      ),
    );
  }
}
