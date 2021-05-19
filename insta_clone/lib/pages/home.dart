import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import 'package:insta_clone/models/user.dart';
import 'package:insta_clone/pages/activity_feed.dart';
import 'package:insta_clone/pages/create_account.dart';
import 'package:insta_clone/pages/profile.dart';
import 'package:insta_clone/pages/search.dart';
import 'package:insta_clone/pages/timeline.dart';
import 'package:insta_clone/pages/upload.dart';

import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();

final usersRef = Firestore.instance.collection("users");

final timeStamp = DateTime.now();

User currentUser;

//----

final StorageReference storageRef = FirebaseStorage.instance.ref();

final postsRef = Firestore.instance.collection("posts");

//---

final commentsRef = Firestore.instance.collection("comments");

//--

final activityFeedRef = Firestore.instance.collection("feed");

//--

final followersRef = Firestore.instance.collection("followers");

final followingRef = Firestore.instance.collection("following");


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;

  PageController pagecontroller;

  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    pagecontroller = PageController();
    googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      handleSignIn(account);
    }, onError: (err) {
      print("Error signing in : $err");
    });
    //Reauthenicate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((err) {
      print("Error signing in : $err");
    });
  }

  handleSignIn(GoogleSignInAccount account) {
    if (account != null) {
    //  print("user signed in! : $account");
      createUserInFirestore();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFirestore() async {
    //(1) check if users exist in users collection in database
    //(according to their ID)
      final GoogleSignInAccount user = googleSignIn.currentUser;
       DocumentSnapshot doc = await usersRef.document(user.id).get();

        if(!doc.exists) {
          //(2) if user doesnot exist, then we want to take them
          // to the create account page

          var userName = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => CreateAccount()));

          //(3) get username from create account ,  use it to make
          // new users document is users collection
          usersRef.document(user.id).setData({
            "id": user.id,
            "username": userName,
            "photoUrl": user.photoUrl,
            "email": user.email,
            "displayName": user.displayName,
            "bio": "",
            "timestamp": timeStamp
          });
        }

      doc = await usersRef.document(user.id).get();

        currentUser = User.fromDocument(doc);
        print(currentUser);
        print(currentUser.username);
  }


  @override
  void dispose() {
    pagecontroller.dispose();
    super.dispose();
  }

  login() {
    googleSignIn.signIn();
    print("11111");
  }

  logout() {
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pagecontroller.animateToPage(pageIndex,
        duration: Duration(milliseconds: 200), curve: Curves.easeIn);
  }




  Scaffold buildAuthScreen() {
    // return RaisedButton(
    //   onPressed: logout,
    // child: Text("Logout",style: TextStyle(
    //   fontSize: 30,fontFamily: "Signatra"
    // ),),
    // );

    return Scaffold(
      body: PageView(
        children: <Widget>[
         // Timeline(),
        RaisedButton(
          onPressed: logout,
        child: Text("Logout",style: TextStyle(
          fontSize: 30,fontFamily: "Signatra"
        ),),),
          ActivityFeed(),
          Upload(currentUser : currentUser),
          Search(),
          Profile(profileId : currentUser?.id)
        ],
        controller: pagecontroller,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),
          BottomNavigationBarItem(icon: Icon(Icons.photo_camera)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
        ],
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
              // Colors.teal,
              // Colors.purple
              Theme.of(context).accentColor.withOpacity(0.8),
              Theme.of(context).primaryColor,
            ])),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "FlutterShare",
              style: TextStyle(
                  fontSize: 70, color: Colors.white, fontFamily: "Signatra"),
            ),
            GestureDetector(
              onTap: () => login(),
              child: Container(
                width: 260.0,
                height: 60.0,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage(
                            "assets/images/google_signin_button.png"))),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
