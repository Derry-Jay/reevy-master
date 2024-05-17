import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_mobile_vision/qr_camera.dart';
import 'package:reevy/activity/activityDatabase.dart';
import 'package:reevy/activity/activity.dart';
import 'package:reevy/codePromo/QRValidationView.dart';
import 'package:device_info/device_info.dart';
import 'package:reevy/codePromo/promoUseDatabase.dart';
import 'package:reevy/account/userDatabase.dart';

import 'package:reevy/globals.dart';

class QRCodeView extends StatefulWidget{
  @override
  _QRCodeState createState() => _QRCodeState();

}

class _QRCodeState extends State<QRCodeView> {


  bool firstRead = true;


  @override
  void initState(){
    super.initState();
  }

  void _goToQR(activityName, nbPoints) async{
    final information = await Navigator.of(context).push(
        MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return QRValidationView(activityName: activityName, nbPoints: nbPoints);
            })
    );
    firstRead = true;
  }

  Future<String> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) { // import 'dart:io'
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: QrCamera(
          child: Padding(
            padding: const EdgeInsets.only(left:8, top: 30),
            child: SizedBox(
              height: 40,
              width: 80,

              child: FlatButton(
                color: AppColors.salmon,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                child: Center(child: Text("Info",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontFamily: 'Heebo',
                  ),
                ),
                ),
                onPressed:(){showDialog(context: context, builder: (_) => AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Passe simplement ton téléphone sur le code pour le scanner.", textAlign: TextAlign.center,),
                    SizedBox(
                      width: 150,
                      child: FlatButton(color: AppColors.salmon,
                        onPressed: (){Navigator.of(context, rootNavigator: true).pop();},
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        child: Center(child: Text("Scanner",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontFamily: 'Heebo',
                        ),
                      ),
                ),),
                    ),
                    ],
                  )
                ));
                },
              ),
            ),
          ),
          qrCodeCallback: (code) async{
            if(firstRead){
              firstRead = false;
              Activity activity = await ActivityDatabaseService().getActivityWhereEqualTo("code", code);
              if(activity != null){
                String deviceID = await _getId();

                Timestamp lastTimeUsed = await PromoUseDatabaseService().getLastTimeUsed(activity.id, deviceID);

                if(lastTimeUsed.toDate().add(Duration(days: activity.promoDelay)).isAfter(DateTime.now())) {
                  DateTime reusableDate =  lastTimeUsed.toDate().add(Duration(days: activity.promoDelay));
                  String reusableString = reusableDate.day.toString() + "." + reusableDate.month.toString() + "." + reusableDate.year.toString();
                  _goToQR("Vous pourrez réutiliser ce code le " + reusableString, -1);
                }
                else{
                  UserDatabaseService().incrementScore(AuthStatus.currentUserId, activity.score);
                  PromoUseDatabaseService().addNewPromoUse(deviceID, activity.id);
                  _goToQR(activity.title, activity.score);
                }

              }
              else{
                _goToQR(null, -1);
              }
            }

          },
          notStartedBuilder: (BuildContext context) {return Container();},
      )

    );
  }
}
