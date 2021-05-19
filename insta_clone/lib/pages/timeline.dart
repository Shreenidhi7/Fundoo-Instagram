import 'package:flutter/material.dart';

import 'package:insta_clone/widgets/header.dart';
import 'package:insta_clone/widgets/progress.dart';

import 'package:cloud_firestore/cloud_firestore.dart';


final userRef = Firestore.instance.collection("users");


class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {

  //List<dynamic> users = [];


  @override
  void initState() {
    // TODO: implement initState
    //getUsers(); // for getting all the users
    //getUserbyId();

    //createUser();

    //updateUser();

    deleteUser();
    super.initState();
  }

  //creating/add a user dynamically
  createUser() {
       userRef.document("abcdabcd").setData({
      "username" : "Swetha",
      "isAdmin" : false,
      "postsCount" : 0
    });
  }

  updateUser() async{
    // userRef.document("abcd").updateData({
    //   "username" : "Swetha K S"

    final doc = await userRef.document("abcd").get();
      if(doc.exists) {
        doc.reference.updateData({
          "username": "Swetha KS"
        });
      }
  }


  deleteUser() async{
   final DocumentSnapshot doc = await userRef.document("abcd").get();
   if(doc.exists){
     doc.reference.delete();
   }
  }


//for getting all the users
//   getUsers(){
//     userRef.getDocuments().then((QuerySnapshot snapshot){
//       snapshot.documents.forEach((DocumentSnapshot doc){
//         print(doc.data);
//         print(doc.documentID);
//         print(doc.exists);
//       });
//     });
//   }  or


  //getUsers() async {
   // final QuerySnapshot snapshot = await userRef
   // //queries that we use for collections
   // //where query (very usefull) (very impt)
   //    // .where("postsCount",isLessThanOrEqualTo: 3)
   //    // .where("username",isEqualTo: "Shree").getDocuments();
   //
   // //order by query [generally orderby is used for number or timestamps
   //    // .orderBy("postsCount",descending: true).getDocuments();
   //
   // //limit query = where we can limit the number of documents we want to get from getDocuments Collection/List
   //    .limit(1).getDocuments();
   //
   // snapshot.documents.forEach((DocumentSnapshot doc){
   //   // here we are printing the data that we are getting from database in console
   //   print("123456789");
   //       print(doc.data);
   //       print(doc.documentID);
   //       print(doc.exists);
   //   // inorder to print the data in the UI Screen ,
   //   //we need to put the data in state...
   //    });

    // final QuerySnapshot snapshot = await userRef.getDocuments();
    // setState(() {
    //   users = snapshot.documents;
    // });

  //}






  // getUserbyId() {
  //   final String id = "dapjWEJWanLDpxZfvGi9";
  //   userRef.document(id).get().then((DocumentSnapshot doc) {
  //       print(doc.documentID);
  //       print(doc.data);
  //       print(doc.exists);
  //   });
  // } or
  // getUserbyId()async {
  //   final String id = "GAn3uactcVgKTIMjXjZb";
  //   final DocumentSnapshot doc = await userRef.document(id).get();
  //     print(doc.documentID);
  //     print(doc.data);
  //     print(doc.exists);
  //
  // }



  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context,isAppTitle: true),
      //body: circularProgress(),
      // body: Container(
      //   child: ListView(
      //     children: users.map((user)=> Text(user["username"]),).toList(),
      //   ),
      // ),
      // body: FutureBuilder<QuerySnapshot>(
      //   future: userRef.getDocuments(),
      //   builder: (context,snapshot){
      //     if(!snapshot.hasData){
      //      return circularProgress();
      //     }
      //     final List<Text> children = snapshot.data.documents
      //         .map((doc)=> Text(doc["username"]))
      //         .toList();
      //     return Container(
      //       child: ListView(
      //         children: children ,
      //       ),
      //     );
      //   },),
      body: StreamBuilder<QuerySnapshot>(
          stream: userRef.snapshots(),
          builder: (context,snapshot){
            if(!snapshot.hasData){
              return circularProgress();
            }
            final List<Text> children = snapshot.data.documents
                .map((user)=> Text(user["username"]))
                .toList();
            return Container(
              child: ListView(
                children: children,
              ),
            );
          }),
    ) ;
  }
}
