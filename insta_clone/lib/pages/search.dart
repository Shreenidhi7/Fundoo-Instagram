import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:insta_clone/models/user.dart';
import 'package:insta_clone/pages/activity_feed.dart';
import 'package:insta_clone/pages/home.dart';
import 'package:insta_clone/widgets/progress.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {

  TextEditingController searchController = TextEditingController();

  Future<QuerySnapshot> searchResultsFuture ;

  handleSearch(String query){
    Future<QuerySnapshot> users = usersRef.where("displayName",isEqualTo: query).getDocuments();
    setState(() {
      searchResultsFuture = users;
    });
  }

  clearSearch(){
    searchController.clear();
  }


  AppBar buildSearchField(){
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: searchController ,
        decoration: InputDecoration(
          hintText: "Search for a user",
          filled: true,
          prefixIcon: Icon(Icons.account_box,
            size: 28.0,
          ),
          suffixIcon: IconButton(icon: Icon(Icons.clear), onPressed: clearSearch,
          )
        ),
        onFieldSubmitted: handleSearch,
      ),
    );
  }

Container buildNoContent(){
  final Orientation orientation = MediaQuery.of(context).orientation;
return Container(
  child: Center(
    child: ListView(
      shrinkWrap: true,
      children: <Widget>[
        SvgPicture.asset("assets/images/search.svg",
        height: orientation == Orientation.portrait ? 300.00 : 200.00 ,),
        Text("Find Users",textAlign: TextAlign.center,style: TextStyle(
          color: Colors.white,fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w600,fontSize: 60.0
        ),)
      ],
    ),
  ),
);
}

  buildSearchResult(){
    return FutureBuilder(
        future: searchResultsFuture,
        builder: (context,snapshot){
         if(! snapshot.hasData){
           return circularProgress();
         }
         List<UserResult> searchResults = [];
         snapshot.data.documents.forEach((doc){
           User user  = User.fromDocument(doc);
           UserResult searchResult = UserResult (user);
            searchResults.add(searchResult);
          // searchResults.add(Text(user.username));
         });
         return ListView(
           children: searchResults,
         );

    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
      appBar: buildSearchField(),
      body: searchResultsFuture == null ? buildNoContent() : buildSearchResult() ,
    );
  }
}

class UserResult extends StatelessWidget {

  final User user;

  UserResult(this.user);

  @override
  Widget build(BuildContext context) {
    //return Text("User Result");
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.7),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: ()=> showProfile(context,profileId: user.id),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                 backgroundImage: CachedNetworkImageProvider(user.photoUrl),
              ),


              title: Text(user.displayName,style: TextStyle(
                fontWeight: FontWeight.bold,color: Colors.white
              ),),

              subtitle: Text(user.username,style: TextStyle(
                color: Colors.white
              ),),


            ),
          ),

          Divider(
            thickness: 2.0,
            height: 2.0,color: Colors.white54,
          ),


        ],
      ),
    );
  }
}
