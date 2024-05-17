import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reevy/ActivitiesListView.dart';
import 'package:reevy/activity/activity.dart';
import 'package:reevy/globals.dart';
import 'package:reevy/icons/reevy_icon_icons.dart';
import 'package:reevy/services/imageStorage.dart';
import 'ActivityDetailsView.dart';
import 'dart:io';
import 'package:reevy/account/userDatabase.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'activity/activityDatabase.dart';

class HitAndFavView extends StatefulWidget{

  @override
  _HitAndFavViewState createState() => _HitAndFavViewState();
}

class _HitAndFavViewState extends State<HitAndFavView>{

  Future<Stream<DocumentSnapshot>> _futureUserInfo;
  List<String> favouriteActivitiesID;

  Future<List<dynamic>> _futures;

  void initState(){
    super.initState();

    _futureUserInfo = UserDatabaseService().getCurrentUserStream();
  }

  Widget hitAndFavTabs(Stream<DocumentSnapshot> userStream){
    userStream.listen((event){
      setState(() {
        favouriteActivitiesID = List<String>.from(event.data["favourites"]);
      });
    });
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: AppColors.cleanGrey,
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.black, //change your color here
            ),
          backgroundColor: Colors.white,
          bottom: TabBar(indicatorColor: Colors.black,
              tabs:[
          Tab(child: Text("Hits du moment", style: TextStyle(color: Colors.black, fontSize: 16,fontFamily: "Poppins", fontWeight: FontWeight.bold),)),
          Tab(child: Text("Favoris", style: TextStyle(color: Colors.black, fontSize: 16,fontFamily: "Poppins", fontWeight: FontWeight.bold))),
          ]
          ),
        title: SizedBox(height: 30, width: 100,
          child: SvgPicture.asset(
          "assets/Reevy.svg",
          color: AppColors.salmon,

          )),
          centerTitle: true,
          ),
          body: TabBarView(
          children: [
            DisplayActivities(activitiesStream: ActivityDatabaseService().getAllHitActivitiesStream().asBroadcastStream(), title: "Activités de la semaine", hit : true, fav: false,),
            AuthStatus.isAnonymous? NoAccountDisplay() : DisplayActivities(activitiesStream: ActivityDatabaseService().getActivitiesByIds(favouriteActivitiesID).asBroadcastStream(),title: "Vos activités favorites", hit:false, fav: true,)
          ],
        )
      )
    )
    );
  }

  Widget build(BuildContext context) {
    return FutureBuilder<Stream<DocumentSnapshot>>(
      future: _futureUserInfo,
      builder: (BuildContext context, AsyncSnapshot<Stream<DocumentSnapshot>> snapshot){
        if(snapshot.connectionState == ConnectionState.done && snapshot.hasData){
          return hitAndFavTabs(snapshot.data);
        }

        else{
          return CircularProgressIndicator();
        }
      },
    );
  }
}

class NoAccountDisplay extends StatelessWidget{

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
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(ReevyIcon.warning),
        Container(
          padding: EdgeInsets.fromLTRB(30,10,30,10),
          child: Text("Tu dois être connecté(e) pour profiter gratuitement de Reevy", textAlign: TextAlign.center,),
        ),

    FlatButton(
    color: AppColors.salmon,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Text("Se connecter ou se créer un compte",
        style: TextStyle(
        color: Colors.white,
        fontSize: 16.0,
        fontFamily: 'Heebo',
      ),
    ),
      onPressed: ()=> _logout(),
    ),

      ],
    );
  }


}