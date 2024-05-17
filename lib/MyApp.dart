import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reevy/ActivitiesListView.dart';
import 'package:reevy/HitAndFavView.dart';
import 'package:reevy/account/LoggedOutAccountView.dart';
import 'package:reevy/codePromo//QRCodeView.dart';
import 'package:reevy/account//MyAccountView.dart';
import 'package:reevy/globals.dart';
import 'package:reevy/icons/reevy_icon_icons.dart';
import 'package:reevy/search/ActivitiesOnMapView.dart';
import 'package:reevy/search/searchView.dart';
import 'account/LoginView.dart';
import 'activity/activityDatabase.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with AutomaticKeepAliveClientMixin<MyApp>{

  Stream<FirebaseUser> _usersStream = FirebaseAuth.instance.onAuthStateChanged;

  @override
  bool get wantKeepAlive => true;
  final CupertinoTabController _controller = CupertinoTabController();

  bool clickCentral = false;
  @override
  void initState(){
    super.initState();
    _controller.index = 2;
    FirebaseAuth.instance.currentUser().then((currentUser){
      if(currentUser != null && !currentUser.isAnonymous){
        AuthStatus.currentUserId = currentUser.uid;
        AuthStatus.currentUserNickname = currentUser.displayName;

      }

    });
  }


  Widget cupertinoTab(){
    return MaterialApp(
      home: Scaffold(

        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.salmon,
          onPressed: () {
            setState(() {
              clickCentral = true;
              _controller.index = 2;
            });},
          child: Icon(
            ReevyIcon.vector,
          ),
        ),
        body: CupertinoTabScaffold(
          controller: _controller,
          tabBar: CupertinoTabBar(
            backgroundColor: Colors.white.withOpacity(1.0),
            items: List.of([
              BottomNavigationBarItem(icon: Icon(ReevyIcon.loupe)),
              BottomNavigationBarItem(icon: Icon(ReevyIcon.map)),
              BottomNavigationBarItem(icon: Icon(Icons.home)),
              BottomNavigationBarItem(icon: Icon(ReevyIcon.qrcode)),
              BottomNavigationBarItem(icon: Icon(ReevyIcon.profile)),
            ]),

          ),
          tabBuilder: (BuildContext context, int index){
            return CupertinoTabView(
              builder: (context) {
                switch (index) {
                  case 0:
                    return SearchActivity();
                    break;
                  case 1:
                    return  ActivitiesOnMap(activitiesStream:  ActivityDatabaseService().getAllActivitiesStream().asBroadcastStream());
                    break;
                  case 2:
                    return HitAndFavView();//DisplayActivities(activitiesStream: ActivityDatabaseService().getAllHitActivitiesStream().asBroadcastStream(), title: "Activités de la semaine", hit : true);
                    break;
                  case 3:
                    return QRCodeView();

                    break;
                  case 4:
                    return AuthStatus.isAnonymous ? LoggedOutAccount() : MyAccount();
                    break;
                  default:
                    return Text("Cannot happen");
                }
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FirebaseUser>(
        stream: _usersStream,
        builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
          _controller.index = 2;
          if(clickCentral){
            clickCentral = false;
            return cupertinoTab();
          }
          if(snapshot.connectionState != ConnectionState.active){
            return Center(child: CircularProgressIndicator());
          }
          else if (!snapshot.hasData ) {
            print("No data");
            return Login(unverified: false);
          }
          else if (!snapshot.data.isAnonymous && !snapshot.data.isEmailVerified){
            print("Unverified");
            try {
              snapshot.data.sendEmailVerification();
            }
            catch (error){
              print("Too many request");
            }
            FirebaseAuth.instance.signOut();
            return Login(unverified: true);
          }
          else{
            if(!snapshot.data.isAnonymous && snapshot.data.isEmailVerified){
              AuthStatus.isAnonymous = false;
              if(snapshot.data.displayName != null){
                _controller.index = 4;
              }
              print("Logged in");

            }

            else if(snapshot.data.isAnonymous){
              AuthStatus.isAnonymous = true;
              _controller.index = 2;
              print("Anonymous user");

            }
            return cupertinoTab();

          }



        }
    );
  }
}