import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';


import 'package:insta_clone/models/user.dart';
import 'package:insta_clone/pages/home.dart';
import 'package:insta_clone/widgets/progress.dart';

import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {

  final User currentUser ;

  Upload({this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {

  File file;

  bool isUploading = false ;

  String postId = Uuid().v4();

 TextEditingController locationController = TextEditingController();

  TextEditingController captionController = TextEditingController();


  handleTakePhoto() async{
    Navigator.pop(context);
     File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 965,
    );
     setState(() {
       this.file = file;
     });
  }

  handleChooseFromGallery() async{
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      this.file = file;
    });

  }


  selectImage(parentContext){
    return showDialog(
        context: parentContext,
        builder: (context){
          return SimpleDialog(
              title: Text("Create Post"),
            children: <Widget>[
              SimpleDialogOption(
                child: Text("Photo with Camera"),
                onPressed: handleTakePhoto,
              ),

              SimpleDialogOption(
                child: Text("Image from Gallery"),
                onPressed: handleChooseFromGallery,
              ),

              SimpleDialogOption(
                child: Text("Cancel"),
                onPressed: ()=> Navigator.pop(context),
              ),


            ],
          );
        }
    );
  }


  Container buildSplashScreen(){
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset("assets/images/upload.svg",
            height: 260.0,
          ),
          Padding(padding: EdgeInsets.only(top: 20),
          child: RaisedButton(
            color: Colors.deepOrange,
              onPressed: ()=> selectImage(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0) 
              ),
            child: Text("Upload Image",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.0
            ), ),
          ),
          )
        ],
      ),
    );
  }


  clearImage(){
    setState(() {
      file = null;
    });
  }

  Future<String> uploadImage(imageFile) async{
   StorageUploadTask uploadTask = storageRef.child("post_$postId.jpg").putFile(imageFile);
   StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
   String downloadUrl = await storageSnap.ref.getDownloadURL();
   return downloadUrl;
  }

  createPostInFirestore({String mediaUrl, String location, String description})
  {
    postsRef.document(widget.currentUser.id)
        .collection("userPosts")
        .document(postId)
        .setData({
         "postId" : postId,
         "ownerId" : widget.currentUser.id,
          "username" : widget.currentUser.username,
          "mediaUrl" : mediaUrl,
          "description" : description,
          "location" : location,
          "timestamp" : timeStamp,
          "likes" : {},
    });
  }

  handleSubmit() async{
  setState(() {
    isUploading = true;
  });
  await compressImage();
  String mediaUrl = await uploadImage(file);
  createPostInFirestore(
    mediaUrl: mediaUrl,
    location: locationController.text,
    description: captionController.text
  );
  captionController.clear();
  locationController.clear();
  setState(() {
    file = null;
    isUploading = false;
    postId = Uuid().v4();
  });

  }

  compressImage() async{
  final tempDir = await getTemporaryDirectory();
  final path = tempDir.path;
  Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
  final compressedImageFile = File('$path/img_$postId.jpg')..writeAsBytesSync(Im.encodeJpg(imageFile,quality: 85));

  setState(() {
    file = compressedImageFile;
  });

  }


  Scaffold buildUploadForm(){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(icon: Icon(Icons.arrow_back,color: Colors.black,), onPressed: clearImage),
        title: Text("Caption Post",style: TextStyle(
          color: Colors.black
        ),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: isUploading ? null : () => handleSubmit(),
            child: Text("Post",style: TextStyle(
              color: Colors.blueAccent,fontWeight: FontWeight.bold,fontSize: 20
            ),),

          )
        ],
      ),

      body: ListView(
        children: <Widget>[

          isUploading ? linearProgress() : Text(""),
          Container(
            height: 220,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                  aspectRatio: 16/9,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: FileImage(file),
                    fit: BoxFit.cover
                  )
                ),
              ),
              ),
            ),
          ),
          
          Padding(padding: EdgeInsets.only(top: 10)),

          ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
            title: Container(
              width: 250.00,
              child: TextField(
                controller: captionController,
                decoration: InputDecoration(
                  hintText: "Write a Caption",
                  border: InputBorder.none
                ),
              ),
            ),
          ),

          Divider(
            color: Colors.black,
            thickness: 2,
          ),

          ListTile(
            leading: Icon(Icons.pin_drop,color: Colors.orange,size: 35,),
          title: Container(
            width: 250,
            child: TextField(
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 5,
              controller: locationController,
              decoration: InputDecoration(
                hintText: "Where was this photo Taken?",
                border: InputBorder.none,

              ),
            ),
          ),
          ),

          Container(
            width: 200,
            height: 100,
            alignment: Alignment.center,
            child: RaisedButton.icon(
                onPressed: getUserLocation,
                icon: Icon(Icons.my_location,color: Colors.white,),
                label: Text("Use Current Location",style: TextStyle(
                  color: Colors.white,),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)
                ),
                color: Colors.blue,),
          )

        ],
      ),

    );
  }

  getUserLocation() async {
    Position position = await Geolocator().getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );
     List<Placemark> placemarks = await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
     Placemark placemark = placemarks[0];

    String completeAddress =
        ' ${placemark.subThoroughfare} ${placemark.thoroughfare},'
        ' ${placemark.subLocality} ${placemark.locality},'
        ' ${placemark.subAdministrativeArea},'
        ' ${placemark.administrativeArea} ${placemark.postalCode},'
        ' ${placemark.country}';
    print(completeAddress);

    String formattedAddress = '${placemark.subLocality},${placemark.locality}-${placemark.postalCode},${placemark.administrativeArea},${placemark.country}';

   //  String formattedAddress = '${placemark.subThoroughfare} ${placemark.thoroughfare},'
   //      ' ${placemark.subLocality} ${placemark.locality},'
   //      ' ${placemark.subAdministrativeArea},'
   //      ' ${placemark.administrativeArea} ${placemark.postalCode},'
   //      ' ${placemark.country}';

    locationController.text = formattedAddress;

  }

  @override
  Widget build(BuildContext context) {
    return file == null ? buildSplashScreen() : buildUploadForm() ;
  }
}
