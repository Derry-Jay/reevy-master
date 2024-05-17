import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reevy/account/userDatabase.dart';
import 'package:reevy/activity/activityDatabase.dart';
import 'package:reevy/globals.dart';
import 'package:reevy/ActivitiesListView.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MyAccount extends StatefulWidget{
  @override
  _MyAccountState createState() => _MyAccountState();

}

class _MyAccountState extends State<MyAccount> {

  String name = AuthStatus.currentUserNickname;
  int score = 0;
  Future<Stream<DocumentSnapshot>> _futureUserInfo;
  List<String> favouriteActivitiesID;

  Future<List<dynamic>> _futures;

  void _logout() async{
    if(await GoogleSignIn().isSignedIn()){
      GoogleSignIn().signOut();
    }
    AuthStatus.isAnonymous = false;
    AuthStatus.currentUserId = null;
    AuthStatus.currentUserNickname = null;
    FirebaseAuth.instance.signOut();
    }

  @override
  void initState(){
    super.initState();
    _futureUserInfo = UserDatabaseService().getCurrentUserStream();
  }


  void _goToFavourites(List<String> likedActivitiesID) async{
    Navigator.of(context).push(
        MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return DisplayActivities(activitiesStream: ActivityDatabaseService().getActivitiesByIds(likedActivitiesID).asBroadcastStream(),title: "Vos activités favorites", hit:false, fav: true,);
            }
        )
    );
  }

  Widget myAccountScreen(Stream<DocumentSnapshot> userStream){
    userStream.listen((event){
      setState(() {
        score = event.data["score"];
        favouriteActivitiesID = List<String>.from(event.data["favourites"]);
      });
    });
    return Scaffold(
      backgroundColor: AppColors.cleanGrey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),

        backgroundColor: Colors.white,
        title:

        SizedBox(height: 30, width: 100,
            child: SvgPicture.asset(
              "assets/Reevy.svg",
              color: AppColors.salmon,

            ) ),

        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: new BorderRadius.all(Radius.circular(14)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder(
                    future: FirebaseAuth.instance.currentUser(),
                    builder: (BuildContext context, AsyncSnapshot<FirebaseUser> user){
                      if(user.hasData){
                        return Center(child: Text(user.data.displayName, style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold, fontFamily: 'Heebo')));
                      }
                      else{
                        return Container();
                      }
                    }),
              //,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text('Score', style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold, fontFamily: 'Heebo', color: AppColors.salmon)),
                        StreamBuilder(
                            stream: userStream,
                            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot>snapshot){
                              if(snapshot.hasData){
                                DocumentSnapshot ds = snapshot.data;
                                return  Container(

                                    padding: EdgeInsets.only(top:13, bottom: 13, right:50, left:50),
                                    margin: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: AppColors.salmon,
                                      borderRadius: new BorderRadius.all(Radius.circular(5)),

                                    ),
                                    child: Text(ds.data["score"].toString() + " pts", style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold, fontFamily: 'Heebo', color: Colors.white))
                                );
                              }
                              else{
                                return Container();
                              }

                            }
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text('Rang', style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold, fontFamily: 'Heebo', color: AppColors.salmon)),
                        StreamBuilder(
                            stream: userStream,
                            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot>snapshot){
                              if(snapshot.hasData){
                                DocumentSnapshot ds = snapshot.data;
                                return  Container(

                                    padding: EdgeInsets.only(top:13, bottom: 13, right:50, left:50),
                                    margin: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: AppColors.salmon,
                                      borderRadius: new BorderRadius.all(Radius.circular(5)),

                                    ),
                                    child: Text("???", style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold, fontFamily: 'Heebo', color: Colors.white))
                                );
                              }
                              else{
                                return Container();
                              }

                            }
                        ),
                      ],
                    )
                  ],
                ),

              ],

            ),




          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.commentGrey,
              borderRadius: new BorderRadius.all(Radius.circular(14)),
            ),
            child: Column(
              children: [
                Text("Partage Reevy avec tes ami·e·s", style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold, fontFamily: 'Heebo', color: Colors.black)),
                SizedBox(height: 20,),
                RichText(text: TextSpan(
                  style: TextStyle(fontSize: 14, fontFamily: 'Heebo', color: Colors.black, height: 1.5),
                  children: [
                    TextSpan(text: "Fais découvrir Reevy à tes ami·e·s et augmente ton score! ", style :  TextStyle(fontSize: 14, fontFamily: 'Heebo', fontWeight: FontWeight.bold, color: Colors.black, height:1.5)),
                    TextSpan(text:"Tes ami·e·s gagneront aussi des points. Pour cela, rien de plus simple: partage ton lien personnel ci-dessous.")
                  ]
                )),
                Container(
                  height: 70,
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: TextField(
                    enabled: false,
                      decoration: new InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),

                        filled: true,
                        fillColor: Colors.white
                      )

                  ),
                ),
                SizedBox(height:20),
                InkWell(
                    child: Text("Copier",
                      style: TextStyle(decoration: TextDecoration.underline,fontSize: 14, fontWeight: FontWeight.bold,fontFamily:"Heebo"),),
                    onTap: (){
                      print("Feature not implemented");
                    }
                )
              ],
            ),
          ),
          SizedBox(height: 20,),

          InkWell(
              child: Text("Se déconnecter",
                style: TextStyle(decoration: TextDecoration.underline,fontSize: 14, fontWeight: FontWeight.bold,fontFamily:"Heebo"),),
              onTap: (){
                _logout();
              }
          ),
          SizedBox(height: 20,),

          InkWell(
              child: Text("Voir vos favoris",
                style: TextStyle(decoration: TextDecoration.underline,fontSize: 14, fontWeight: FontWeight.bold,fontFamily:"Heebo"),),
              onTap: (){
                _goToFavourites(favouriteActivitiesID);
              }
          ),

        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Stream<DocumentSnapshot>>(
      future: _futureUserInfo,
      builder: (BuildContext context, AsyncSnapshot<Stream<DocumentSnapshot>> snapshot){
        if(snapshot.connectionState == ConnectionState.done && snapshot.hasData){
          return myAccountScreen(snapshot.data);
        }

        else{
          return CircularProgressIndicator();
        }
      },
    );
  }
}
