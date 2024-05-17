import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../ActivityDetailsView.dart';
import '../activity/activity.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reevy/globals.dart';
import 'package:reevy/services/imageStorage.dart';

Future<BitmapDescriptor> _bitmapDescriptorFromSvgAsset(BuildContext context, String assetName) async {
  // Read SVG file as String
  String svgString = await DefaultAssetBundle.of(context).loadString(assetName);
  // Create DrawableRoot from SVG String
  DrawableRoot svgDrawableRoot = await svg.fromSvgString(svgString, null);

  // toPicture() and toImage() don't seem to be pixel ratio aware, so we calculate the actual sizes here
  MediaQueryData queryData = MediaQuery.of(context);
  double devicePixelRatio = queryData.devicePixelRatio;
  double width = 15 * devicePixelRatio; // where 32 is your SVG's original width
  double height = 15 * devicePixelRatio; // same thing

  // Convert to ui.Picture
  ui.Picture picture = svgDrawableRoot.toPicture(size: Size(width, height));

  // Convert to ui.Image. toImage() takes width and height as parameters
  // you need to find the best size to suit your needs and take into account the
  // screen DPI
  ui.Image image = await picture.toImage(width.toInt(), height.toInt());
  ByteData bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  return BitmapDescriptor.fromBytes(bytes.buffer.asUint8List());
}

class ActivitiesOnMap extends StatefulWidget{

  final Stream<List<Activity>> activitiesStream;
  //TODO: Utiliser la géolocalisation. Pour l'instant on est sur la Suisse Romande
  final GeoFirePoint center = GeoFirePoint(46.556394, 6.413276);
  ActivitiesOnMap({Key key, this.activitiesStream}) : super(key: key);

  @override
  _ActivitiesOnMapState createState() => _ActivitiesOnMapState();
}

class _ActivitiesOnMapState extends State<ActivitiesOnMap> {
  GoogleMapController mapController;
  LatLng _center;
  Activity _clickedActivity;
  Future<BitmapDescriptor> _futureBitmapDescriptor;
  File _image = File("nana");
  bool _showCard = false;
  void _goToChosenActivity(Activity act) {
    Navigator.of(context).push(
        MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return ChosenActivity(activity: act);
            })
    );
  }

  @override
  void initState() {
    super.initState();
    _center = LatLng(widget.center.latitude, widget.center.longitude);
    _futureBitmapDescriptor = _bitmapDescriptorFromSvgAsset(context, 'assets/marker.svg');
  }
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
                "Carte des activités"
                ,style: TextStyle(color: Colors.black, fontSize: 16,fontFamily: "Poppins", fontWeight: FontWeight.bold),
              ),
            ],
          ), centerTitle: true,
        ),
        body:
            StreamBuilder<List<Activity>>(
              stream: widget.activitiesStream,
              builder: (BuildContext context, AsyncSnapshot<List<Activity>> snapshot){
                if(snapshot.hasData){

                  return Stack(children: <Widget>[
                    FutureBuilder(
                      future: _futureBitmapDescriptor,
                      builder: (BuildContext context, AsyncSnapshot<BitmapDescriptor> bitmapDescriptor){
                        if (bitmapDescriptor.hasData && bitmapDescriptor.connectionState == ConnectionState.done){
                          return  GoogleMap(
                            zoomControlsEnabled: false,
                            mapToolbarEnabled: false,
                            onMapCreated: _onMapCreated,
                            markers: _getActivitiesMarkers(snapshot.data, bitmapDescriptor.data),
                            initialCameraPosition: CameraPosition(
                              target: _center,
                              //Il faudrait faire un calcul pour savoir le zoom...Par rapport au radius recherché ou alors par rapport à l'activité la plus éloignée
                              zoom: 7.0,
                            ),
                          );
                        }
                        else return Container();
                      },

                    ),
                       Visibility(
                         visible: _showCard,
                         child: Align(
                              alignment: Alignment(0.5,0.65),

                              child: SizedBox(
                                height: 170,

                                child: Container(
                                  decoration: new BoxDecoration(
                                    boxShadow: [
                                      new BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 1,
                                        blurRadius: 15,
                                        offset: Offset(0, 5), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: Card(
                                    margin: EdgeInsets.all(15),
                                    shape: RoundedRectangleBorder(borderRadius: new BorderRadius.all(Radius.circular(14))),
                                    child: InkWell(
                                      onTap: () => _goToChosenActivity(_clickedActivity),
                                      child: Stack(
                                        children: [
                                          Padding(
                                            padding:  EdgeInsets.only(right : 8.0, bottom : 8),
                                            child: Align(
                                              alignment: Alignment.bottomRight,
                                              child: Icon(Icons.arrow_forward_ios),
                                            ),
                                          ),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Stack(
                                                children: [
                                                  Container(
                                                      height: 100,
                                                      decoration:
                                                      new BoxDecoration(
                                                          borderRadius: new BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                                                          image: new DecorationImage(
                                                              fit: BoxFit.fitWidth,
                                                              alignment: FractionalOffset.center,
                                                              image: new FileImage(_image))
                                                      )
                                                  ),

                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 8, top: 8),
                                                child: Text(_clickedActivity == null ? "" : _clickedActivity.title, style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold, fontFamily: 'Heebo')),
                                              ),

                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                       )

                  ]
                  );
                }

                else {
                  return CircularProgressIndicator();
                }
              }
            )

      )
    );
  }

  void _handleCard(Activity actvity) async{
    File newImage = await getActivityThumbnail(actvity);
    setState(() {
      _showCard = true;
      _image = newImage;
      _clickedActivity = actvity;
    });
  }

  Set<Marker> _getActivitiesMarkers(List<Activity> activities, BitmapDescriptor bitmapDescriptor) {
    Set<Marker> markers = new Set();

    for(Activity act in activities){
      //Bon là je créé un id avec un peu de la dems, il faudra trouver un truc mieux. En vrai activity a un champs id mais pour l'instant il est pas instantié avec l'id de la db, il faudra
      //changer ça...
      markers.add(
        Marker(markerId: MarkerId(act.title + act.description + act.phone + act.url),
          icon: bitmapDescriptor,
          position: LatLng(act.geoFirePoint.latitude, act.geoFirePoint.longitude),
          onTap: () => _handleCard(act)
        ),
      );
    }
    return markers;
  }


}