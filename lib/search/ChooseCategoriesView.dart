import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:reevy/ActivitiesListView.dart';
import 'package:reevy/services/categoryDatabase.dart';
import '../activity/activity.dart';
import 'package:reevy/activity/activityDatabase.dart';

import '../globals.dart';
class ChooseCategories extends StatefulWidget{

  final double distance;
  final num nbParticipants;
  final GeoFirePoint center;
  final bool inside;
  final bool outside;
  //need to catch the error if no number is inserted
  ChooseCategories({Key key, this.distance, @required this.nbParticipants, @required this.center, @required this.inside, @required this.outside}) : super(key: key);

  @override
  _ChooseCategoriesState createState() => _ChooseCategoriesState();

}
class _ChooseCategoriesState extends State<ChooseCategories> {
  var searchItems = List<String>();
  Map<String, bool> _selected;
  TextEditingController _searchController = TextEditingController();
  Map<String, List> categories;
  //Creating a map containing all the selected items and a list with all categories for the search (will be updated)
  @override
  void initState() {
    super.initState();
    CategoryDatabaseServices().getCategories().then((cat) {
      setState(() {
        categories = cat;
        searchItems.addAll(categories.keys) ;
        _selected = Map.fromIterable(categories.keys, key: (item) => item, value: (item) => false);
      });
    });
  }
  //Creates a card that contains the category, will light in blue when selected
  Widget categoryRow(index){
    return  SizedBox(
      height: double.infinity,
      child: Card(
        color:  _selected[searchItems[index]]? AppColors.salmon: null,
        margin: EdgeInsets.only(left : 7, right: 7, bottom: 7, top:7),
        shape: RoundedRectangleBorder(borderRadius: new BorderRadius.all(Radius.circular(14))),
        child: InkWell(
          onTap: () {setState(() {_selected[searchItems[index]] = !_selected[searchItems[index]];});},
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Container(
                height: 115,
                decoration:
                new BoxDecoration(
                    borderRadius: new BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                    image: new DecorationImage(
                        fit: BoxFit.fitWidth,
                        alignment: FractionalOffset.center,
                        image: new AssetImage("assets/category/"+categories[searchItems[index]][1])
                    )
                ),),
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 8),
              child:
              Text(categories[searchItems[index]][0] == null ? "" : categories[searchItems[index]][0], style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold, fontFamily: 'Heebo'))
          )

            ],
          ),
        ),
      ),
    );

    return new Card(
      child:
        ListTile(
            title: Center(child: Text(categories[searchItems[index]][0], style: TextStyle(fontSize: 20),)), dense: true, onTap: (){setState(() {_selected[searchItems[index]] = !_selected[searchItems[index]];});}),
      color: _selected[searchItems[index]]? Colors.blue: null,
    );
  }

  //Function that searches the category the user types and updating the screen display

  void searchFilter(String query){
    List<String> dummy = List<String>();
    dummy.addAll(categories.values.map((e) => e[0]));
    if(query.isNotEmpty){
      List<String> dummyData = List<String>();
      dummy.forEach((element) {if (element.toLowerCase().contains(query.toLowerCase())){
        dummyData.add(element);}
        });
      setState(() {
        searchItems.clear();
        for (String value in dummyData)
          {
            //print(value);
            for(String key in categories.keys){
            if (categories[key][0] == value){
              searchItems.add(key);
            }
          }
        }
      });
      return;
    }
    else{
      setState(() {
        searchItems.clear();
        searchItems.addAll(categories.keys);
      });
    }
  }

  void _goToDisplayActivitiesCat() async{
    Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) {
            return DisplayActivities(activitiesStream: searchActivitiesInRangeAndCat().asBroadcastStream(), title: "Choisis une activité!", hit: false, fav: false,);
          }
      )
    );
  }
  void _goToDisplayActivities() async{
    Navigator.of(context).push(
        MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return DisplayActivities(activitiesStream: searchActivitiesInRange().asBroadcastStream(), title: "Choisis une activité!", hit: false, fav: false);
            }
        )
    );
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
                "Trouver une activité (2/3)"
                ,style: TextStyle(color: Colors.black, fontSize: 16,fontFamily: "Poppins", fontWeight: FontWeight.bold),
              ),
            ],
          ), centerTitle: true,
        ),
        body:Column(
          crossAxisAlignment:CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
            margin: EdgeInsets.fromLTRB(25,10,25,0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Rechercher",
                prefixIcon: Icon(Icons.search),
                fillColor: AppColors.commentGrey,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  borderSide: BorderSide(color: Colors.grey,),

            ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            onChanged:(search) => searchFilter(search),
            )),
            Container(
            margin: EdgeInsets.fromLTRB(25,10,25,0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              Text("Choix de(s) catégorie(s)",
              style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold, fontFamily: 'Heebo')),
              InkWell(
              child: Text("Tout sélectionner",
              style: TextStyle(decoration: TextDecoration.underline,fontSize: 14, fontWeight: FontWeight.bold,fontFamily:"Heebo"),),
              onTap: (){
                _goToDisplayActivities();
              }
    )
            ],),),

            Expanded(

                child: Stack(
                  children: [GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.1),

                    itemBuilder: (context, index) => categoryRow(index,),
                    itemCount: searchItems.length,
                  ),
                    Align(
                      alignment: Alignment(0, 0.7),
                      child: FlatButton(
                          padding: EdgeInsets.only(left: 20, right:20, top:5, bottom:5),
                          color: AppColors.salmon,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                          child:Text("Afficher les résultats", style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold, fontFamily: 'Heebo', color: Colors.white)),
                          onPressed: (){
                            int count = 0;
                            _selected.forEach((key, value) {if(value) count++;}); //Faire peut-être un message d'erreur clair?
                            if(count == 0) {
                              Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text("Vous ne pouvez pas sélectionner 0 catégories")));
                              return;
                            }
                              if(count > 10){
                                //TODO : Trouver un autre moyen peut-être? La limitation de Firebase de 10 catégories calme.
                                Scaffold.of(context).showSnackBar(SnackBar(
                                    content: Text("Vous ne pouvez pas sélectionner plus de 10 catégories, à moins de toutes les sélectionner.")));
                                return;
                              }

                            else{
                              _goToDisplayActivitiesCat();}
                          }
                      ),
                    ),]
                )
            ),

          ],
        )

    );
  }

  Stream<List<Activity>> searchActivitiesInRangeAndCat() async* {

    List<String> selectedCategoriesID = new List();

    _selected.forEach((key, value) {if(value) selectedCategoriesID.add(key);});
    //case we didn't select anything
    Stream<List<Activity>> activitiesStream = ActivityDatabaseService().getActivitiesInRangeAndWithinCategories(widget.center,
        widget.distance, widget.nbParticipants, selectedCategoriesID, widget.inside, widget.outside);
    yield* activitiesStream;
  }

  Stream<List<Activity>> searchActivitiesInRange() async* {

    Stream<List<Activity>> activitiesStream = ActivityDatabaseService().getActivitiesInRangeAndParticipants(widget.center, widget.distance, widget.nbParticipants, widget.inside, widget.outside);
    yield* activitiesStream;
  }




}