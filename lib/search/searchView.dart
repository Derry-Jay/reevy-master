import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocation/geolocation.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:reevy/ActivitiesListView.dart';
import 'package:reevy/activity/activity.dart';
import 'package:reevy/activity/activityDatabase.dart';
import 'package:reevy/search/ChooseCategoriesView.dart';
import 'package:reevy/services/location.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';

import '../globals.dart';

const kGoogleApiKey = "AIzaSyD_m4axM683VPRfXxvQ1ICY2kQl0ZbJPug";

class SearchActivity extends StatefulWidget {
  @override
  _SearchActivityState createState() => _SearchActivityState();
}

class _SearchActivityState extends State<SearchActivity> {

  double distance = 10.0;
  double locationLat;
  double locationLong;
  Color enableColor;
  bool _invalidnbParticipants = false;
  bool _invalidLocation = false;
  bool _askLocation = false;
  bool useOwnLocation = false;
  TextEditingController participantsController;
  TextEditingController radiusController;
  TextEditingController locationController;
  final double maxKm = 100;
  final double minKm = 10;
  var inoutsidePreference = ['Intérieur / Extérieur','Intérieur', 'Extérieur'];
  bool inside = true;
  bool outside = true;
  String selectedInOutside;

  GoogleMapsPlaces places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

  @override
  void dispose() {
    participantsController.dispose();
    super.dispose();
  }


  void _goToActivities() async{
    GeoFirePoint center;
    if(useOwnLocation){
      PermissionStatus permission = await LocationPermissions().checkPermissionStatus();
      if(permission == PermissionStatus.denied){
        PermissionStatus permission = await LocationPermissions().requestPermissions();
        if(permission == PermissionStatus.denied){
          _askLocation = true;
          return;
        }
      }
      LocationResult locationResult = await getLocation();
      center = GeoFirePoint(locationResult.location.latitude, locationResult.location.longitude);
    }
    else{
      center = GeoFirePoint(locationLat, locationLong);
    }
    if (center == null){
      _invalidLocation = true;
      return;
    }
    Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context){
            return ChooseCategories(center: center, distance: distance, nbParticipants: int.parse(participantsController.text),
              inside: this.inside, outside: this.outside,);
          },
        )
    );
  }

  void addToNbParticipants(){
    participantsController.text = (int.parse(participantsController.text) + 1).toString();
    setState(() {
      enableColor = AppColors.salmon;
    });
  }

  void subToNbParticipants(){
    participantsController.text = (int.parse(participantsController.text) - 1).toString();
    if(int.parse(participantsController.text) == 1){
      setState(() {
        enableColor = AppColors.lessSalmon;
      });
    }
  }


  @override
  void initState() {
    super.initState();
    participantsController = new TextEditingController(text: '1');
    radiusController = new TextEditingController(text: '10');
    locationController = new TextEditingController(text: '');
    enableColor = AppColors.lessSalmon;
    selectedInOutside = inoutsidePreference[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
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
                "Trouver une activité (1/3)"
                ,style: TextStyle(color: Colors.black, fontSize: 16,fontFamily: "Poppins", fontWeight: FontWeight.bold),
              ),
            ],
          ), centerTitle: true,
        ),
      body: ListView(
        children: [
          Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
                child: Column(
                  children: [
                    Text("Pars à la recherche d'une activté en 2 étapes.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black, fontSize: 16,fontFamily: "Poppins", fontWeight: FontWeight.bold),
                      ),
                    Text("Sélectionne tout d'abord le nombre de participants et"
                    " le lieu, puis, la ou les catégorie(s) qui t'intéresse(nt)",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black, fontSize: 16,fontFamily: "Poppins")
                    )
                  ],
                ),
              ),
              Container(
                  padding: EdgeInsets.all(15),
                  margin: EdgeInsets.fromLTRB(20,10,20,0),
                  decoration: BoxDecoration(color: Colors.white,
                    borderRadius: new BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                        "Participants"
                        ,style: TextStyle(color: Colors.black, fontSize: 16,fontFamily: "Heebo", fontWeight: FontWeight.bold),

                      ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(icon: Icon(Icons.indeterminate_check_box, color: enableColor, size: 35,),
                          onPressed:() {if (int.parse(participantsController.text) > 1) subToNbParticipants();}
                          ),

                          Container(
                            width: 50,
                            height: 50,
                            child: TextField(
                              textAlign: TextAlign.center,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                errorText: _invalidnbParticipants? "Ne peut pas être vide" : null,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                              controller: participantsController,
                              onChanged:(value){ setState(() {
                                if(_invalidnbParticipants) {
                                  _invalidnbParticipants = !_invalidnbParticipants;
                                }
                              });
                              },
                            ),
                          ),
                          IconButton(icon: Icon(Icons.add_box, color: AppColors.salmon, size: 35,), onPressed: addToNbParticipants),
                        ],
                      ),
                    ],
                  )
              ),

              Container(
                padding: EdgeInsets.all(15),
                margin: EdgeInsets.fromLTRB(20,10,20,0),
                decoration: BoxDecoration(color: Colors.white,
                  borderRadius: new BorderRadius.all(Radius.circular(20)),
                ),
                child: Column(
                  children: <Widget>[
                    Center(
                      child:Text(
                      "Lieu de l'activité"
                      ,style: TextStyle(color: Colors.black, fontSize: 16,fontFamily: "Heebo", fontWeight: FontWeight.bold),
                    ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      height: 70,
                      child: TextField(
                          textAlignVertical: TextAlignVertical.center,
                          enabled: !useOwnLocation,
                          decoration: InputDecoration(
                            hintText: "Lieu de référence",
                            border: OutlineInputBorder(),
                            errorText: _invalidLocation? "Saisie incorrecte" : null,
                          ),
                          keyboardType: TextInputType.text,
                          onTap: () async{
                            _invalidLocation = false;
                            Prediction p = await PlacesAutocomplete.show(
                                context: context,
                                apiKey: kGoogleApiKey,
                                mode: Mode.fullscreen,
                                language: "fr",
                                components: [new Component(Component.country, "ch")],
                                startText: locationController.text
                            );
                            displayPrediction(p);
                          },
                          controller: locationController,
                        ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                       Container(
                            width: 60,
                            child: Checkbox(

                              checkColor: Colors.white,
                              activeColor: AppColors.salmon,
                              value: useOwnLocation,
                              onChanged: (value) {
                                setState(() {
                                  useOwnLocation = value;
                                  locationController.text = "";
                                  if(_askLocation == true) {
                                    _askLocation = value;
                                  }
                                });
                              },
                            )
                        ),
                        Text("Utiliser ma position actuelle", style: TextStyle(fontSize: 10, fontFamily: "Heebo")),

                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text("Rayon", style: TextStyle(fontSize: 10, fontFamily: "Heebo")),

                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.cleanGrey,
                            inactiveTrackColor: AppColors.cleanGrey,
                            trackHeight: 22.0,
                            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 9.0),
                            thumbColor: AppColors.salmon,
                            trackShape: RoundedRectSliderTrackShape(),
                          ),
                          child: Slider(
                            min: minKm,
                            max: maxKm,
                            value: distance,
                            onChanged: (_distance){ setState(() {
                              distance = _distance;
                              radiusController.text = distance.toInt().toString();
                            });} ,
                            divisions: maxKm.toInt(),
                          ),
                        ),
                        Container(
                          width: 55,
                          height: 55,
                          child: TextField(
                            textAlign: TextAlign.center,
                            textAlignVertical: TextAlignVertical.top,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            controller: radiusController,
                            inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                            onChanged: (_distance){
                              setState(() {
                                distance = double.parse(_distance);
                                if(distance > maxKm){
                                  radiusController.text = maxKm.toInt().toString();
                                  distance = maxKm;
                                }
                              });
                            },
                          ),
                        ),
                        Text("km", style: TextStyle(fontSize: 10, fontFamily: "Heebo")),
                      ],
                    ),

                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Préférence intérieur ou extérieur', style: TextStyle(fontSize: 14, fontFamily: "Heebo", fontWeight: FontWeight.bold),)),

                    Container(
                      margin: EdgeInsets.all(10),
                      width: 400,
                      height: 30,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                          ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          value: selectedInOutside,
                          icon: Icon(Icons.arrow_drop_down),
                          iconSize: 24,
                          onChanged: (String s){
                            setState(() {
                              selectedInOutside = s;
                              if (s == inoutsidePreference[0]){
                                inside = true;
                                outside = true;
                              }
                              else if (s == inoutsidePreference[1]){
                                inside = true;
                                outside = false;
                              }
                              else{
                                inside = false;
                                outside = true;
                              }
                            });
                          },
                          items: inoutsidePreference.map<DropdownMenuItem<String>>((String place) {
                            return DropdownMenuItem<String>(
                            value: place,
                            child: Container(
                              padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                child: Text(place, style: TextStyle(fontSize: 14, fontFamily: "Heebo"),),),
                        );}).toList()
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]
    ),
    Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 25, 0),
          child: FlatButton(
            color: AppColors.salmon,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            child: Center(child: Text("Suivant",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontFamily: 'Heebo',
                ),
                ),
    ),
            onPressed:(){
              if(participantsController.text.isNotEmpty && (locationController.text.isNotEmpty || useOwnLocation) ) _goToActivities();
              else setState(() {
                if(participantsController.text.isEmpty) _invalidnbParticipants = true;
                if(locationController.text.isEmpty) _invalidLocation = true;
              });
            },
          ),
        ),
      ],
    )
       ]
      ),
    );
  }

  Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId);
      locationLat = detail.result.geometry.location.lat;
      locationLong = detail.result.geometry.location.lng;
      setState(() {
        locationController.text = p.description;
      });
    }
  }
}
