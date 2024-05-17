import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:reevy/activity/activity.dart';

final Directory systemTempDir = Directory.systemTemp;

Future<List<File>> getThumbnails(List<Activity> activities) async {
  List<File> thumbnails = new List();
  for(Activity activity in activities){
    File tempFile = File('${systemTempDir.path}/tmp'+activity.thumbnail);
    thumbnails.add(tempFile);
    if(!tempFile.existsSync()){
      await tempFile.create();
      await FirebaseStorage.instance.ref().child(activity.thumbnail).writeToFile(tempFile).future;
    }
  }
  return thumbnails;
}

Future<File> getActivityThumbnail(Activity activity) async {
  File thumbnail = File('${systemTempDir.path}/tmp'+activity.thumbnail);
  if(!thumbnail.existsSync()){
    await thumbnail.create();
    await FirebaseStorage.instance.ref().child(activity.thumbnail).writeToFile(thumbnail).future;
  }
  return thumbnail;
}


Future<List<File>> getActivityImages(Activity activity) async {
  List<File> images = new List();
  for(String filename in activity.images){
    File tempFile = File('${systemTempDir.path}/tmp'+filename);
    images.add(tempFile);
    if(!tempFile.existsSync()){
      await tempFile.create();
      await FirebaseStorage.instance.ref().child(filename).writeToFile(tempFile).future;
    }
  }
  return images;
}