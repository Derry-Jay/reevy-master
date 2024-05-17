import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reevy/account/user.dart';


class UserDatabaseService{
  final CollectionReference userCollection = Firestore.instance.collection("user");

  void addNewUser(String userID) async {
    userCollection.document(userID).setData({
      'liked' : List<String>(),
      'favourites' : List<String>(),
      'score' : 0
    });
  }
  
  void addNewLiked(String userID, String activityID){
    userCollection.document(userID).updateData({"liked" : FieldValue.arrayUnion(List.of([activityID]))});
  }

  void removeLiked(String userID, String activityID){
    userCollection.document(userID).updateData({"liked" : FieldValue.arrayRemove(List.of([activityID]))});
  }
  
  void addNewFavorite(String userID, String activityID){
    userCollection.document(userID).updateData({"favourites": FieldValue.arrayUnion(List.of([activityID]))});
  }

  void removeFavorite(String userID, String activityID){
    userCollection.document(userID).updateData({"favourites": FieldValue.arrayRemove(List.of([activityID]))});
  }

  void incrementScore(String userID, int increment){
    userCollection.document(userID).updateData({"score" : FieldValue.increment(increment)});
  }

  Future<bool> userExists(String userID)async {
    DocumentSnapshot ds = await userCollection.document(userID).get();
    return ds.exists;
  }

  //CETTE FONCTION SEMBLE TOUJOURS RETOURNER NULL ????
  Future<User> getCurrentUserData() async{
    FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
    DocumentSnapshot ds = await userCollection.document(firebaseUser.uid).get();
    return new User(ds.documentID, ds.data["liked"], ds.data["favourites"], ds.data["score"]);
  }

  Future<Stream<DocumentSnapshot>> getCurrentUserStream() async{
    FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
    if(firebaseUser == null){
      return null;
    }
    return userCollection.document(firebaseUser.uid).snapshots();
  }

  Future<DocumentSnapshot> getCurrentUserDocumentSnapshot() async{
    FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
    if(firebaseUser == null){
      return null;
    }
    return userCollection.document(firebaseUser.uid).get();
  }







}