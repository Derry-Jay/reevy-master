import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'activityDatabase.dart';
import 'Day.dart';
class Activity{
  String title;
  String description;
  String phone;
  String url;
  String id;
  int minNbParticipants;
  int maxNbParticipants;
  int likes;
  String thumbnail;
  List<String> images;
  GeoFirePoint geoFirePoint;
  List<String> categories;
  List<Day> days;
  String material;
  bool canRent;
  bool hit;
  String code;
  String promo;
  int promoDelay;
  int score;
  bool inside;
  bool outside;

  Activity(this.id, this.title, this.description, this.phone, this.url, this.likes,this.minNbParticipants, this.maxNbParticipants, this.thumbnail, var location, List<dynamic> dynamicImages,
            List<dynamic> dynamicCategories, List<dynamic> dynamicDays, this.canRent, this.material, this.hit, this.code, this.promoDelay, this.score, this.promo, this.inside, this.outside){
    geoFirePoint = GeoFirePoint(location["geopoint"].latitude, location["geopoint"].longitude);
    images = dynamicImages.cast<String>().toList();
    categories = dynamicCategories.cast<String>().toList();
    days = List();
    for(Map<String, dynamic> day in dynamicDays){
      days.add(Day(day["day"], TimeOfDay(hour: day["begin1Hour"], minute: day["begin1Min"]), TimeOfDay(hour: day["end1Hour"], minute: day["end1Min"]), TimeOfDay(hour: day["begin2Hour"], minute: day["begin2Min"]),
          TimeOfDay(hour: day["end2Hour"], minute: day["end2Min"])));
    }
  }


  Activity.fromDocument(DocumentSnapshot ds) : this(ds.documentID, ds.data["title"], ds.data["description"], ds.data["phone"], ds.data["url"], ds.data["likes"], ds.data["minNbParticipants"],
    ds.data["maxNbParticipants"], ds.data["thumbnail"], ds.data["location"], ds.data["images"], ds.data["categories"], ds.data["days"], ds.data["canRent"], ds.data["material"],
    ds.data["hit"], ds.data["code"], ds.data["promoDelay"], ds.data["score"], ds.data["promo"], ds.data["inside"], ds.data["outside"]);

  Map<String, dynamic> toJson() {
    return {
      'title': this.title,
      'description': this.description,
      'url': this.url,
      'phone': this.phone,
      'minNbParticipants': this.minNbParticipants,
      'maxNbParticipants': this.maxNbParticipants,
      'location': this.geoFirePoint.data,
      'categories': this.categories,
      'days': this.days.map((day) => day.toJson()).toList(),
      'material': this.material,
      'canRent' : this.canRent,
      'thumbnail' : this.thumbnail,
      'hit' : this.hit,
      'code' : this.code,
      'promoDelay' : this.promoDelay,
      'score' : this.score,
      'promo' : this.promo,
      'inside': this.inside,
      'outside': this.outside
    };
  }

  /// Saves the activity to the database and sets the id to the one automatically created by Firebase
  void saveToDatabase(){
    ActivityDatabaseService().addNewActivity(this).then((ref) => id = ref.documentID);
  }

  @override
  String toString(){
    return "Name: "+title+"\nParticipants: "+minNbParticipants.toString()+" to "+maxNbParticipants.toString();
  }


}