import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qr_mobile_vision/qr_camera.dart';
import 'package:reevy/activity/activityDatabase.dart';
import 'package:reevy/activity/activity.dart';
import 'package:reevy/codePromo/QRCodeView.dart';
import 'package:reevy/globals.dart';

class QRValidationView extends StatefulWidget{

  final String activityName;
  final int nbPoints;

  QRValidationView({Key key, this.activityName, this.nbPoints}) : super(key:key);

  @override
  _QRValidationState createState() => _QRValidationState();

}

class _QRValidationState extends State<QRValidationView> {



  @override
  void initState(){
    super.initState();
  }

  void _returnToQRCodeView() {
    Navigator.of(context).pop();
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
                    color: AppColors.salmon,)
              ),
              Text(
                "QR Code"
                ,style: TextStyle(color: Colors.black, fontSize: 16,fontFamily: "Poppins", fontWeight: FontWeight.bold),
              ),
            ],
          ), centerTitle: true,
        ),
      body:  Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(widget.activityName == null ? "QR code invalide" : "QR code validé",
              style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
              fontFamily: 'Heebo',
            ),
          ),

            SizedBox(
              height: 50,
            ),
            Text(widget.activityName,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14.0,
                fontFamily: 'Heebo',
              ),
            ),
            SizedBox(
              height: 20,
            ),
            widget.nbPoints == -1 ? Container() : Center(child: Text("Vous avez gagné " + widget.nbPoints.toString() + " points")),
            SizedBox(
              height: 50,
            ),
            FlatButton(
              color: Colors.white.withOpacity(0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0), side: BorderSide(color: AppColors.salmon)),
              child: SizedBox(
                width: 100,
                child: Center(child: Text("Retour",
                  style: TextStyle(
                    color: AppColors.salmon,
                    fontSize: 16.0,
                    fontFamily: 'Heebo',
                  ),
                ),
                ),
              ),
              onPressed: _returnToQRCodeView
            )

          ],
        )
    );
  }
}
