import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reevy/activity/comment.dart';

class CommentDatabaseService{
  final CollectionReference commentCollection = Firestore.instance.collection("comment");

  Future<DocumentReference> addNewComment(Comment comment) async {
    return commentCollection.add({
      'nickname':comment.nickname,
      'activityID': comment.activityID,
      'text' : comment.text,
      'date' : comment.date
    });
  }

  Future<List<Comment>> getActivityComments(String activityID) async {
    Query query = commentCollection.where("activityID", isEqualTo: activityID).orderBy("date", descending: true);
    List<Comment> comments = new List();
    QuerySnapshot qs = await query.getDocuments();
    for(DocumentSnapshot ds in qs.documents){
        comments.add(Comment(ds["nickname"], activityID, ds["text"], ds["date"]));
      }
    return comments;
  }


}