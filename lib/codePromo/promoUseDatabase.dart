import 'package:cloud_firestore/cloud_firestore.dart';

class PromoUseDatabaseService{
  final CollectionReference promoUseCollection = Firestore.instance.collection("promoUse");

  Future<Timestamp> getLastTimeUsed(String activityID, String deviceID) async{
    final promoUses = await promoUseCollection.where("deviceID", isEqualTo: deviceID).where("activityID", isEqualTo: activityID).getDocuments();
    Timestamp lastTimeUsed = Timestamp.fromMicrosecondsSinceEpoch(0);
    for(DocumentSnapshot ds in promoUses.documents){
      if (ds.data["date"].compareTo(lastTimeUsed) > 0){
        lastTimeUsed = ds.data["date"];
      }
    }
    return lastTimeUsed;
  }

  Future<DocumentReference> addNewPromoUse(String deviceID, String activityID){
    return promoUseCollection.add({
      'deviceID' : deviceID,
      'activityID' : activityID,
      'date' : Timestamp.fromDate(DateTime.now())
    });
  }




}