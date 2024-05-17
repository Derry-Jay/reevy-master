
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reevy/activity/commentDatabase.dart';
import 'package:flutter/material.dart';
import 'package:reevy/globals.dart';
class Comment{
  String nickname;
  String activityID;
  String text;
  String id;
  Timestamp date;

  Comment(this.nickname, this.activityID, this.text, this.date){}

  void saveToDatabase(){
    CommentDatabaseService().addNewComment(this).then((ref) => id = ref.documentID);
  }

  Text toText(){
    return new Text(nickname + ", " +date.toDate().day.toString() + "." + date.toDate().month.toString() + "." + date.toDate().year.toString()+"\n"+ text);
  }
  
  RichText toRichText(){
    return RichText(text: TextSpan(
      children: <TextSpan>[
        TextSpan(text : nickname + " ", style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold, fontFamily: 'Heebo', color: Colors.black)),
        TextSpan(text : text + "\n", style: TextStyle(fontSize: 14, fontFamily: 'Heebo', color: Colors.black)),
        TextSpan(text : getDateAsString(), style: TextStyle(fontSize: 12, fontFamily: 'Heebo', color: Colors.black45)),
      ]
    ));
  }
  
  String getNickname(){
    return this.nickname;
  }
  
  String getText(){
    return text;
  }
  
  String getDateAsString(){
    return date.toDate().day.toString() + "." + date.toDate().month.toString() + "." + date.toDate().year.toString();
  }


}