import 'package:cloud_firestore/cloud_firestore.dart';


class CategoryDatabaseServices{
  final CollectionReference categoryCollection = Firestore.instance.collection("category");

  Future<Map<String, List>> getCategories() async{
    QuerySnapshot query = await categoryCollection.getDocuments();
    Map<String, List> categories = new Map();
    for(DocumentSnapshot documentSnapshot in query.documents){
      List<String> data = List<String>(2);
      data[0] = documentSnapshot.data["name"];
      data[1] = documentSnapshot.data["image"];
      categories.putIfAbsent(documentSnapshot.documentID, () => data);
    }
    return categories;
  }
}