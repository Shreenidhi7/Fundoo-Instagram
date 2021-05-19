import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


import 'package:insta_clone/models/user.dart';
import 'package:insta_clone/pages/activity_feed.dart';
import 'package:insta_clone/pages/comments.dart';
import 'package:insta_clone/pages/home.dart';
import 'package:insta_clone/widgets/custom_image.dart';
import 'package:insta_clone/widgets/progress.dart';



class Post extends StatefulWidget {

  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final dynamic likes ;

  Post({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.description,
    this.mediaUrl,
    this.likes
});

  factory Post.fromDocument(DocumentSnapshot doc){
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],
      likes: doc['likes'],
    );
  }

  int getLikeCount(likes){
    // if there are no likes, return 0
    if(likes == null){
      return 0;
    }
    int count = 0;
    // if the key is explicitly set to true,add a like
    likes.values.forEach((val){
      if(val == true){
        count +=1;
      }
    });
    return count;
  }


  @override
  _PostState createState() => _PostState(

    postId: this.postId,
    ownerId: this.ownerId,
    username: this.username,
    description: this.description,
    location: this.location,
    mediaUrl: this.mediaUrl,
    likes: this.likes,
    likeCount: getLikeCount(this.likes),

  );
}

class _PostState extends State<Post> {

  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  int likeCount;
  Map likes;

  final String currentUserId = currentUser?.id;
  bool isLiked ;
  bool showHeart = false;

  _PostState({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.description,
    this.mediaUrl,
    this.likeCount,
    this.likes
  });



  buildPostHeader(){
    return FutureBuilder(
        future: usersRef.document(ownerId).get(),
        builder: (context,snapshot){
          if(!snapshot.hasData){
           return circularProgress();
          }
          User user = User.fromDocument(snapshot.data);
          return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            backgroundColor: Colors.grey,
           // radius: 6,
          ),
            title: GestureDetector(
              onTap: ()=> showProfile(context,profileId:user.id),
              child: Text(user.username,
                style: TextStyle(color: Colors.black,
              fontWeight: FontWeight.bold
              ),),
            ),

            subtitle: Text(location),
            trailing: IconButton(
                onPressed:()=> print("Deleting Posy"),
              icon: Icon(Icons.more_vert),
            ),

    );
    });
  }

  handleLikePost(){
    bool _isLiked =likes[currentUserId] == true;
    if(_isLiked) {
      postsRef
          .document(ownerId)
          .collection("userPosts")
          .document(postId)
          .updateData({'likes.$currentUserId' : false });
      removeLikeFromActivityFeed();
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUserId] = false ;
      });
    } else if(!_isLiked){
      postsRef
          .document(ownerId)
          .collection("userPosts")
          .document(postId)
          .updateData({'likes.$currentUserId' : true });
      addLikeToActivityFeed();
      setState(() {
        likeCount += 1;
        isLiked = true;
        likes[currentUserId] = true ;
        showHeart = true;
      });
     Timer(Duration(
       milliseconds: 500),()  {
       setState(() {
         showHeart = false;
       });
     });
    }
  }

  addLikeToActivityFeed(){

    //add a notification to the postOwner's activity  feed only if
    // comment made by OTHER user(to avoid getting notification for owr own like)

    bool isNotPostOwner = currentUserId != ownerId;

    if(isNotPostOwner){
      activityFeedRef
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .setData({
        "type": "like",
        "username": currentUser.username,
        "userId": currentUser.id,
        "userProfileImg" : currentUser.photoUrl,
        "postId" : postId,
        "mediaUrl" : mediaUrl,
        "timestamp": timeStamp
      });

    }


  }

  removeLikeFromActivityFeed(){

    bool isNotPostOwner = currentUserId != ownerId;
    if(isNotPostOwner){
      activityFeedRef
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .get().then((doc){
        if(doc.exists){
          doc.reference.delete();
        }
      });
    }

  }



  buildPostImage(){
    return GestureDetector(
      onDoubleTap: handleLikePost,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
         // Image.network(mediaUrl),
          cachedNetworkImage(mediaUrl),
         // showHeart ? Animator(
         //    duration: Duration(milliseconds: 300),
         //    tween: Tween(begin: 0.8,end: 1.4),
         //    curve: Curves.elasticOut,
         //    cycles: 0,
         //    builder: (anim)=>
         //        Transform.scale(scale: anim.value,
         //      child: Icon(Icons.favorite,size: 80.00,color: Colors.red, ),),
         //  )  : Text("") ,
          showHeart ? Icon(Icons.favorite,size: 80.0,color: Colors.red) : Text("")
        ],
      ),
    );
  }

  buildPostFooter(){
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 40,left: 20)),

            GestureDetector(
              onTap: handleLikePost,
              child: Icon( isLiked ? Icons.favorite : Icons.favorite_border ,
              size: 28.0,color: Colors.pink,),
            ),

            Padding(padding: EdgeInsets.only(right: 20)),


            GestureDetector(
              onTap: ()=> showComments(
                context,
                postId: postId,
                ownerId: ownerId,
                mediaUrl: mediaUrl
              ),
              child: Icon(Icons.chat,
                size: 28.0,color: Colors.blue[900],),
            ),

          ],
        ),

        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text("$likeCount likes",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold
              ),
              ),
            ),
          ],
        ),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text("$username",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),

            Expanded(
              flex: 1,
                child: Text(description)),

          ],
        ),


      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId] == true);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter()
      ],
    );
  }
}

showComments(BuildContext context, {String postId, String ownerId, String mediaUrl}) {
  Navigator.push(context,
      MaterialPageRoute(
          builder: (context){
            return Comments(
              postId:postId,
              postOwnerId : ownerId,
              postMediaUrl : mediaUrl
            );
          })
  );

}
