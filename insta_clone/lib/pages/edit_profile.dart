import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";

import 'package:insta_clone/pages/home.dart';
import 'package:insta_clone/models/user.dart';
import 'package:insta_clone/widgets/progress.dart';

class EditProfile extends StatefulWidget {

  final String currentUserId;

  EditProfile({this.currentUserId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoading = false;
  User user;

  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  bool _displayNameValid = true;
  bool _bioValid = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }

  getUser()async{
    setState(() {
      isLoading = true;
    });

  DocumentSnapshot doc =await usersRef.document(widget.currentUserId).get();
  //deserialize
   user =  User.fromDocument(doc);
    displayNameController.text = user.displayName;
    bioController.text = user.bio;
     setState(() {
       isLoading = false;
     });
  }

 Column buildDisplayNameField(){
    return Column(
       //mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(padding: EdgeInsets.only(top: 12),
        child: Text("DisplayName",style: TextStyle(
          color: Colors.grey
        ),),
        ),

        TextField(
          controller: displayNameController,
          decoration: InputDecoration(
            hintText: "Update Display Name",
            errorText: _displayNameValid ? null : "Display Name too short"
          ),
        )


      ],
    );
  }

  buildBioField(){
    return Column(
      //mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(padding: EdgeInsets.only(top: 12),
          child: Text("Bio",style: TextStyle(
              color: Colors.grey
          ),),
        ),

        TextField(
          controller: bioController,
          decoration: InputDecoration(
              hintText: "Update BIO",
            errorText: _bioValid ? null : "Bio is too long..make it short and sweet"
          ),
        ),


      ],
    );
  }


  updateProfileData(){
    setState(() {
      displayNameController.text.trim().length < 3 || displayNameController.text.isEmpty ? _displayNameValid = false : _displayNameValid = true ;
      bioController.text.trim().length > 20 ? _bioValid = false : _bioValid = true ;
    });

    if(_displayNameValid && _bioValid){
      usersRef.document(widget.currentUserId).updateData({
        "displayName" : displayNameController.text,
        "bio" : bioController.text,
      });
    }

   SnackBar snackbar = SnackBar(content: Text("Profile Updated"),);
    _scaffoldKey.currentState.showSnackBar(snackbar);

  }

  logout() async{
      await googleSignIn.signOut();
      Navigator.push(context, MaterialPageRoute(builder: (context)=> Home() ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Edit Profile",style: TextStyle(
          color: Colors.black,fontWeight: FontWeight.bold
        ),),
        centerTitle: true,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.done,color: Colors.green,size: 30.0,),
              onPressed: ()=> Navigator.pop(context)),
        ],
      ),

      body: isLoading
          ? circularProgress()
          : ListView(
        children: <Widget>[
          Container(
          child: Column(
            children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 16,bottom: 8),
              child: CircleAvatar(
                radius: 50,
                backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),
              ),

              Padding
                (padding: EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    buildDisplayNameField(),
                    buildBioField(),
                  ],
                ),
              ),

              RaisedButton(
                  onPressed: updateProfileData,
              child: Text("Update Profile",style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),),
              ),
              
              Padding(padding: EdgeInsets.all(16),
              child: FlatButton.icon(
                  onPressed: logout,
                  icon: Icon(Icons.cancel,color: Colors.red,),
                  label: Text('Logout',style: TextStyle(
                    color: Colors.red,fontSize: 20
                  ),))
              )


            ],
          ),
          )
        ],
      ) ,

    );
  }
}
