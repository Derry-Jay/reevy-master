import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reevy/account/userDatabase.dart';
import 'package:reevy/globals.dart';
import 'RegisterView.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoggedOutAccount extends StatefulWidget{

  bool unverified = false;

  LoggedOutAccount({Key key, this.unverified}) : super(key: key);

  @override
  _LoggedOutAccountState createState() => _LoggedOutAccountState();

}

class _LoggedOutAccountState extends State<LoggedOutAccount> {


  @override
  void initState(){
    super.initState();


  }
  void _logout() async{
    if(await GoogleSignIn().isSignedIn()){
      GoogleSignIn().signOut();
    }
    AuthStatus.isAnonymous = false;
    AuthStatus.currentUserId = null;
    AuthStatus.currentUserNickname = null;
    FirebaseAuth.instance.signOut();
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
        title:

        SizedBox(height: 30, width: 100,
            child: SvgPicture.asset(
              "assets/Reevy.svg",
              color: AppColors.salmon,

            )),

        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: new BorderRadius.all(Radius.circular(14)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Avantages Reevy", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,fontFamily:"Heebo"),),
                  SizedBox(height: 20,),

                  Text("Offres hits", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,fontFamily:"Heebo", color: AppColors.salmon),),
                  SizedBox(height: 10,),
                  Text("Profite de toutes nos offres hits exclusives, disponibles pour une durée limitée chez nos partenaires.", style: TextStyle(fontSize: 14 ,fontFamily:"Heebo"), textAlign: TextAlign.center,),
                  SizedBox(height:30),

                  Text("Favoris", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,fontFamily:"Heebo", color: AppColors.salmon),),
                  SizedBox(height: 10,),
                  Text("Enregistres tes activités préférées afin de les retrouver facilement, reçois une notification quand l’une d’elle a une nouvelle offre hit, et ajoute tes commentaires.", style: TextStyle(fontSize: 14 ,fontFamily:"Heebo"), textAlign: TextAlign.center,),
                  SizedBox(height:30),

                  Text("Points & Bonus", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,fontFamily:"Heebo", color: AppColors.salmon),),
                  SizedBox(height: 10,),
                  Text("Accumule des points à chaque activité faite, et reçois en échange des offres bonus chez nos partenaires.", style: TextStyle(fontSize: 14 ,fontFamily:"Heebo"), textAlign: TextAlign.center,),
                  SizedBox(height:30),

                  Text("100% gratuit", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,fontFamily:"Heebo", color: AppColors.salmon),),
                  SizedBox(height: 10,),
                  Text("Reevy est totalement gratuite pour les utilisatrices et utilisateurs. Alors n’attends plus, connecte-toi dès maintenant!", style: TextStyle(fontSize: 14 ,fontFamily:"Heebo"), textAlign: TextAlign.center,),
                  SizedBox(height:30),

                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
              child: FlatButton(color: AppColors.salmon,
                onPressed: _logout,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                child: Center(child: Text("Se connecter ou se créer un compte",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                    fontFamily: 'Heebo',
                  ),
                ),
                ),),
            )


          ],
        ),
      ),
    );
  }


}