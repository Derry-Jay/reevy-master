import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:reevy/account/LoginView.dart';
import 'package:reevy/globals.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:reevy/activity/activity.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:reevy/services/imageStorage.dart';
import 'package:reevy/activity/CommentView.dart';
import 'package:reevy/activity/Day.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:reevy/activity/comment.dart';
import 'package:reevy/activity/commentDatabase.dart';

class ChosenActivity extends StatefulWidget{

  final Activity activity;
  List<File> thumbnails = new List();
  ChosenActivity({Key key, this.activity}) : super(key: key);

  @override
  _ChosenActivityState createState() => _ChosenActivityState();

}
class _ChosenActivityState extends State<ChosenActivity> {
  String qr = "";
  bool firstQrRead = true;
  bool displayQrResult = false;
  bool qrResult = false;
  bool favourite_pressed = false;

  Future<QuerySnapshot> _futurePromoUses;
  Future<List<Comment>> _futureComments;



  Future<List<dynamic>> _futures;

  @override
  void initState(){
    super.initState();
    _futureComments = CommentDatabaseService().getActivityComments(widget.activity.id);
  }


  void _goToCommentView(){
    Navigator.of(context).push(
        MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return CommentView(activityID: widget.activity.id);
            }
        )
    );
  }

  String daysToText(List<Day> days){
    String finalString = "";
    for(Day day in days){
      finalString += ""+ day.toString() + "\n";
    }
    return finalString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cleanGrey,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),

          backgroundColor: Colors.white,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(height: 30, width: 100,
                  child: SvgPicture.asset(
                "assets/Reevy.svg",
                color: AppColors.salmon,

              ) ),

              Text(
              widget.activity.title
              ,style: TextStyle(color: Colors.black, fontSize: 20,fontFamily: "Poppins", fontWeight: FontWeight.bold),
        ),
            ],
          ), centerTitle: true,
        ),
        body: ListView(
          children: [
            Container(
              alignment: Alignment.topCenter,
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white,
                  borderRadius: new BorderRadius.all(Radius.circular(20)),
              ),
              child: Column(
                children: <Widget>[
                  FutureBuilder<List<File>>(
                    future: getActivityImages(widget.activity),
                    builder: (BuildContext context, AsyncSnapshot<List<File>> snapshot){
                      if(snapshot.hasData){
                        return CarouselSlider(
                          options: CarouselOptions(
                            height: 160,
                            aspectRatio: 16/9,
                            viewportFraction: 1,
                            initialPage: 0,
                            enableInfiniteScroll: true,
                            reverse: false,
                            enlargeCenterPage: true,
                            scrollDirection: Axis.horizontal,
                          ),
                          items: snapshot.data.map((imageFile) {
                            return Builder(
                              builder: (BuildContext context) {
                                return Container(
                                    decoration: new BoxDecoration(
                                        borderRadius: new BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                                        image: new DecorationImage(
                                        fit: BoxFit.fitWidth,
                                        alignment: FractionalOffset.center,
                                        image: new FileImage(imageFile))
                                )
                                );
                              },
                            );
                          }).toList(),
                        );
                      }
                      else{
                        return Center(child: CircularProgressIndicator());
                      }
                    }),

                    Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[

                        Text(widget.activity.title, style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold, fontFamily: 'Heebo')),
                        SizedBox(height: 20),
                        Text(widget.activity.description, textAlign: TextAlign.justify, style: TextStyle(fontSize: 14, fontFamily: 'Heebo')),
                            SizedBox(height: 20,),
                            Text("Site internet", style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold, fontFamily: 'Heebo')),

                                InkWell(child : Text(widget.activity.url,
                                                    style: TextStyle(color: Colors.black, decoration: TextDecoration.underline, decorationColor: Colors.blueAccent),),
                                        onTap: () => launch(widget.activity.url)),

                            SizedBox(height: 20,),
                            Text("Horaires d'ouveture", style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold, fontFamily: 'Heebo')),

                            Row(children: [Text("Lundi"), SizedBox(width: 58.5,), Text(widget.activity.days[0].toString())],),
                            Row(children: [Text("Mardi"), SizedBox(width: 56.5,), Text(widget.activity.days[1].toString())],),
                            Row(children: [Text("Mercredi"), SizedBox(width: 38,), Text(widget.activity.days[2].toString())],),
                            Row(children: [Text("Jeudi"), SizedBox(width: 58,), Text(widget.activity.days[3].toString())]),
                            Row(children: [Text("Vendredi"), SizedBox(width: 37,), Text(widget.activity.days[4].toString())]),
                            Row(children: [Text("Samedi"), SizedBox(width: 46,), Text(widget.activity.days[5].toString())]),
                            Row(children: [Text("Dimanche"), SizedBox(width: 30,), Text(widget.activity.days[6].toString())]),
                          ]),
                    )



                ],

              ),
            ),

            Container(
                margin: EdgeInsets.all(20),
             padding: EdgeInsets.all(20),
             width: double.infinity,
                decoration: BoxDecoration(color: AppColors.commentGrey,
                  borderRadius: new BorderRadius.all(Radius.circular(20)),
                ),
              child:
              Column(
                children: [
                  FutureBuilder<List<Comment>>(
                    future: _futureComments,
                    builder: (BuildContext context, AsyncSnapshot<List<Comment>> comments){
                      if(comments.hasData){
                        if(comments.data.length == 0){
                          return RaisedButton(
                            child: Text("Soyez le premier à commenter"),
                            onPressed: _goToCommentView,
                          );
                        }
                        else if (comments.data.length == 1){
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Align(
                                  alignment: Alignment.center,
                                  child: Text("Commentaire (1)", style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold, fontFamily: 'Heebo'))),
                              SizedBox(height: 20,),
                              comments.data[0].toRichText(),
                              Align(
                                alignment: Alignment.center,
                                child: RaisedButton(
                                  child: Text("Voir plus"),
                                  onPressed: _goToCommentView,
                                ),
                              )
                            ],
                          );
                        }
                        else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Align(
                                alignment: Alignment.center,
                                  child: Text("Commentaires ("+ comments.data.length.toString() +")", style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold, fontFamily: 'Heebo'))),
                              SizedBox(height: 20,),
                              comments.data[0].toRichText(),
                              SizedBox(height: 10,),
                              comments.data[1].toRichText(),
                              Align(
                                alignment: Alignment.center,
                                child: RaisedButton(
                                  child: Text("Voir plus"),
                                  onPressed: _goToCommentView,
                                ),
                              )

                            ],
                          );
                        }
                      }
                      else {
                        return Container();
                      }
                    },
                  ),
                ],
              )
            )
          ],
        ),


    );
  }
}