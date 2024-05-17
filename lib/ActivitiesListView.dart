import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reevy/activity/activity.dart';
import 'package:reevy/globals.dart';
import 'package:reevy/icons/reevy_icon_icons.dart';
import 'package:reevy/services/imageStorage.dart';
import 'ActivityDetailsView.dart';
import 'dart:io';
import 'package:reevy/account/userDatabase.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DisplayActivities extends StatefulWidget{

  final Stream<List<Activity>> activitiesStream;
  final String title;
  final bool hit;
  final bool fav;
  DisplayActivities({Key key, this.activitiesStream, this.title, this.hit, this.fav}) : super(key: key);

  @override
  _DisplayActivitiesState createState() => _DisplayActivitiesState();


}
class _DisplayActivitiesState extends State<DisplayActivities>  with AutomaticKeepAliveClientMixin<DisplayActivities> {
  @override
  bool get wantKeepAlive => true;

  List<bool> isFavourite = new List.filled(100, true, growable: true);
  String userID;
  Future<Stream<DocumentSnapshot>> _futureUserStream;
  Future<List<File>> _futureFiles;
  Future<List<dynamic>> _futures;
  List<Activity> _activities;
  bool firstActivities = true;

  @override
  void setState(fn) {
    if(this.mounted) {
      super.setState(fn);
    }
  }

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
  void initState() {

    super.initState();
  }

    _fillIconsList(List<dynamic> userIsFavourite) {
      isFavourite.clear();
      var userIsFavouriteStrings = new List<String>.from(userIsFavourite);
      if (userIsFavourite == null) {
        return;
      }
      setState(() {
        for (Activity activity in _activities) {
          if (userIsFavouriteStrings.contains(activity.id)) {
            isFavourite.add(true);
          }
          else {
            isFavourite.add(false);
          }
        }
      });
    }



  Future<void> _needToBeLoggedIn(){
    return showDialog(context: context,
    barrierDismissible: true,
    builder: (BuildContext context){
      return new AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(ReevyIcon.warning,size: 30,),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Tu dois être connecté(e) pour profiter gratuitement de tous les avantages de Reevy", textAlign: TextAlign.center,),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 150,
                  child: FlatButton(color: AppColors.salmon,
                    onPressed: (){
                    Navigator.of(context, rootNavigator: true).pop();
                    _logout();},
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    child: Center(child: Text("Se connecter",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontFamily: 'Heebo',
                      ),
                    ),
                    ),),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8,30,8,0),
                child: InkWell(child: Text("Continuer sans se connecter",
                style: TextStyle(decoration: TextDecoration.underline,fontSize: 14, fontWeight: FontWeight.bold,fontFamily:"Heebo"),), onTap:(){Navigator.of(context, rootNavigator: true).pop();} ,),
              )
            ],
          )
      );});
    }



    void _goToChosenActivity(index) {
    Navigator.of(context).push(
        MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return ChosenActivity(activity: _activities[index]);
            })
    );
  }


    void _handleFavourite(int index) async {
      if (!isFavourite[index]) {
        UserDatabaseService().addNewFavorite(userID, _activities[index].id);
      }
      else {
        UserDatabaseService().removeFavorite(userID, _activities[index].id);
      }
      setState(() {
        isFavourite[index] = !isFavourite[index];
      });
    }

    SizedBox activityRow(index, thumbnails, bool withFavouriteIcons) {

    Widget likeIconButton;
      if (withFavouriteIcons){
        likeIconButton = Align(
          alignment: Alignment.topRight,
          child: Stack(
            children: [
              Opacity(opacity: isFavourite[index] ? 1 : 0.4,
              child: IconButton(
                icon: Icon(Icons.star, color: AppColors.salmon, size: 30),
                onPressed: () {
                  _handleFavourite(index);
                },
              )),
              IconButton(
                icon: Icon(Icons.star_border, color: AppColors.salmon, size: 30),
                onPressed: () {
                  _handleFavourite(index);
                },
              )
            ],
          )

,
        );
      }
      else {
        likeIconButton = Container();
      }

      return SizedBox(
        height: widget.hit ? 215 : _activities[index].hit ? 165 : 145,

        child: Card(
          margin: EdgeInsets.only(left : 20, right: 20, bottom: 20),
          shape: RoundedRectangleBorder(borderRadius: new BorderRadius.all(Radius.circular(14))),
          child: InkWell(
            onTap: () => _goToChosenActivity(index),
            child: Stack(
              children: [
                widget.hit ? Container(height: 0) : Padding(
                  padding: _activities[index].hit ?  EdgeInsets.only(right : 8.0, bottom : 16) :  EdgeInsets.only(right : 8.0, bottom : 8),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Icon(Icons.arrow_forward_ios),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                            height: 90,
                            decoration:
                            new BoxDecoration(
                                borderRadius: new BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                                image: new DecorationImage(
                                    fit: BoxFit.fitWidth,
                                    alignment: FractionalOffset.center,
                                    image: new FileImage(thumbnails[index]))
                            )
                        ),
                        likeIconButton,

                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8, top: 8),
                      child: Text(_activities[index].title, style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold, fontFamily: 'Heebo')),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left : 8.0, top : 4),
                      child: Container(
                          child: _activities[index].hit ? Text(_activities[index].promo, style: TextStyle(fontSize: 14, fontFamily: 'Heebo')) : Container(height:0)
                      ),
                    ),

                    Align(
                      alignment: Alignment.center,
                      child: Container(
                          child: widget.hit ?FlatButton(
                              color: withFavouriteIcons? AppColors.salmon : AppColors.lessSalmon,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                              child: Text("En profiter",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontFamily: 'Heebo',
                                ),
                              ),
                              onPressed: (){
                                if (withFavouriteIcons){
                                  _goToChosenActivity(index);
                                }
                                else{
                                  _needToBeLoggedIn();
                                };}
                          ) : Container(height:0)
                      ),
                    ),

                  ],
                ),
              ],
            ),

          ),



        ),
      );
    }

    Widget listOfActivities(){
      return Column(
        children: <Widget>[
          SizedBox(height: 20,),
          StreamBuilder<List<Activity>>(
            stream: widget.activitiesStream,
            builder: (BuildContext context, AsyncSnapshot<List<Activity>> activityStream) {

              if (activityStream.hasData) {
                if (firstActivities) {
                  _activities = activityStream.data;
                  _futureFiles = getThumbnails(_activities);
                  _futureUserStream = UserDatabaseService().getCurrentUserStream();
                  _futures = Future.wait([_futureFiles, _futureUserStream]);
                  firstActivities = false;
                }


                return FutureBuilder<List<dynamic>>(
                    future: _futures,
                    builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {

                        if(!AuthStatus.isAnonymous){
                          snapshot.data[1].listen((userInfo) {
                            _fillIconsList(userInfo["favourites"]);
                            userID = userInfo.documentID;
                          });
                        }

                        if(_activities.isEmpty) {
                          if(widget.fav){
                            return Center(child: Column(
                              children: [
                                Icon(Icons.star, size: 30),
                                Text(
                                  "Vous n'avez pas encore de favoris",
                                  style: TextStyle(color: Colors.black,
                                      fontSize: 16,
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ));
                          }
                          else {
                            return Center(child: Text(
                              "Votre recherche n'a trouvé aucune activité",
                              style: TextStyle(color: Colors.black,
                                  fontSize: 16,
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.bold),
                            ));
                          }
                        }
                        else {
                          return Expanded(
                              child: ListView.builder(
                                //TODO: Peut être remplacé par la variable globale de login
                                itemBuilder: (context, index) =>
                                    activityRow(index, snapshot.data[0],
                                        !AuthStatus.isAnonymous),
                                itemCount: _activities.length,
                              )
                          );
                        }
                      }
                      else {

                        return Center(child: CircularProgressIndicator());
                      }
                    }
                );
              }
              else {

                return Center(child: CircularProgressIndicator());
              }
            },
          ),

        ],
      );
    }



    @override
    Widget build(BuildContext context) {
      if(widget.hit || widget.fav){
        return listOfActivities();
      }
      else {
        return Scaffold(
            backgroundColor: AppColors.cleanGrey,
            appBar: AppBar(
              iconTheme: IconThemeData(
                color: Colors.black, //change your color here
              ),

              backgroundColor: Colors.white,
              title: Column(children: [
                SizedBox(height: 30, width: 100,
                    child: SvgPicture.asset(
                      "assets/Reevy.svg",
                      color: AppColors.salmon,

                    )),
                if (!widget.hit || !widget.fav) Text("Trouver une activité (3/3)",
                  style: TextStyle(color: Colors.black,
                      fontSize: 16,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.bold),
                ),
              ],
              ),
              centerTitle: true,
            ),
            body: listOfActivities()
        );
      }
    }
}



