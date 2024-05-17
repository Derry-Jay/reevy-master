import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:reevy/activity/activity.dart';
import 'dart:async';

class ActivityDatabaseService{
  final CollectionReference activityCollection = Firestore.instance.collection("activity");
  final Geoflutterfire geo = Geoflutterfire();


  Future<DocumentReference> addNewActivity(Activity activity) async {
    return activityCollection.add(activity.toJson());
  }

  Stream<List<DocumentSnapshot>> getActivityStreamInRadius(GeoFirePoint center, double radius, [Query query]){
    if(query == null){
      return geo.collection(collectionRef: activityCollection).within(center: center, radius: radius, field: 'location', strictMode: true);
    }
    else{
      return geo.collection(collectionRef: query).within(center: center, radius: radius, field: 'location', strictMode: true);
    }
  }

  Stream<List<Activity>> getActivitiesInRange(GeoFirePoint center, double radius, [Query query]) async* {

    final snapshots = getActivityStreamInRadius(center, radius, query);
    await for (final snapshot in snapshots){
      List<Activity> activities = List();
      for(DocumentSnapshot ds in snapshot){
        activities.add(new Activity(ds.documentID, ds.data["title"], ds.data["description"], ds.data["phone"], ds.data["url"], ds.data["likes"], ds.data["minNbParticipants"],
            ds.data["maxNbParticipants"], ds.data["thumbnail"], ds.data["location"], ds.data["images"], ds.data["categories"], ds.data["days"], ds.data["canRent"], ds.data["material"],
            ds.data["hit"], ds.data["code"], ds.data["promoDelay"], ds.data["score"], ds.data["promo"], ds.data["inside"], ds.data["outside"]));
      }
      yield activities;
    }
  }

  Stream<List<Activity>> getActivitiesInRangeAndParticipants(GeoFirePoint center, double radius, num nbParticipants, bool inside, bool outside,[Query query]) async* {

    final snapshots = getActivityStreamInRadius(center, radius, query);
    await for (final snapshot in snapshots){
      List<Activity> activities = List();
      for(DocumentSnapshot ds in snapshot){
        if(ds.data["maxNbParticipants"]>= nbParticipants && ds.data["minNbParticipants"] <= nbParticipants && (ds.data["inside"] == inside || ds.data["outside"] == outside)){
          activities.add(new Activity(ds.documentID, ds.data["title"], ds.data["description"], ds.data["phone"], ds.data["url"], ds.data["likes"], ds.data["minNbParticipants"],
              ds.data["maxNbParticipants"], ds.data["thumbnail"], ds.data["location"], ds.data["images"], ds.data["categories"], ds.data["days"], ds.data["canRent"], ds.data["material"],
              ds.data["hit"], ds.data["code"], ds.data["promoDelay"], ds.data["score"], ds.data["promo"], ds.data["inside"], ds.data["outside"]));
          }
      }
      yield activities;
    }
  }


  Stream<List<Activity>> getActivitiesInRangeAndWithinCategories(GeoFirePoint center, double radius, num nbParticipants, List<String> categories, bool inside, bool outside) async* {
    Query query = activityCollection.where("categories", arrayContainsAny: categories);
    yield* getActivitiesInRangeAndParticipants(center, radius, nbParticipants, inside, outside, query);
  }


  
  void addLike(String activityID){
    activityCollection.document(activityID).updateData({"likes": FieldValue.increment(1)});
  }

  void removeLike(String activityID){
    activityCollection.document(activityID).updateData({"likes": FieldValue.increment(-1)});
  }

  Future<List<Activity>> getAllActivities() async{
    QuerySnapshot query = await activityCollection.getDocuments();
    List<Activity> activities = List();
    for(DocumentSnapshot ds in query.documents){
      activities.add(Activity.fromDocument(ds));
    }
    return activities;
  }

  Stream<List<Activity>> getAllActivitiesStream() async*{
     final snapshots = activityCollection.snapshots();
     await for (final snapshot in snapshots){
       List<Activity> activities = List();
       for(DocumentSnapshot ds in snapshot.documents){
         activities.add(Activity.fromDocument(ds));
       }
       yield activities;
     }
  }

  Future<List<Activity>> getAllHitActivities() async{
    QuerySnapshot query = await activityCollection.where('hit', isEqualTo: true).getDocuments();
    List<Activity> activities = List();
    for(DocumentSnapshot ds in query.documents){
      activities.add(Activity.fromDocument(ds));
    }
    return activities;
  }

  Stream<List<Activity>> getAllHitActivitiesStream() async*{
    final snapshots = activityCollection.where('hit', isEqualTo: true).snapshots();

    await for (final snapshot in snapshots){
      List<Activity> activities = List();
      for(DocumentSnapshot ds in snapshot.documents){
        activities.add(Activity.fromDocument(ds));
      }
      yield activities;
    }
  }

  Future<Activity> getActivityWhereEqualTo(String field, dynamic value) async{
    QuerySnapshot query = await activityCollection.where(field, isEqualTo: value).getDocuments();
    if(query.documents.length > 0){
      DocumentSnapshot documentSnapshot = query.documents[0];
      return Activity.fromDocument(documentSnapshot);
    }
    else{
      return null;
    }

  }

  Future<Activity> getActivityById(String id) async{
    DocumentReference document = activityCollection.document(id);
    DocumentSnapshot ds = await document.get();
    return Activity.fromDocument(ds);
  }

  Stream<DocumentSnapshot> getActivityStreamById(String id) async*{
    yield* activityCollection.document(id).snapshots();
  }

  Stream<List<Activity>> getActivitiesByIds(List<String> ids) async*{
    final snapshots =  activityCollection.snapshots();

    await for (final snapshot in snapshots){
      List<Activity> activities = List();
      for(DocumentSnapshot ds in snapshot.documents){
        if(ids.contains(ds.documentID))
          activities.add(Activity.fromDocument(ds));
      }
      yield activities;
    }
  }


}