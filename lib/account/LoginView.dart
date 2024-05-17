import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reevy/account/userDatabase.dart';
import 'package:reevy/globals.dart';
import 'RegisterView.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Login extends StatefulWidget{

  bool unverified = false;

  Login({Key key, this.unverified}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();

}

class _LoginState extends State<Login> {

  TextEditingController emailController;
  TextEditingController passwordController;
  bool _invalidEmail = false;
  bool _invalidPassword = false;

  @override
  void initState(){
    super.initState();
    emailController = new TextEditingController();
    passwordController = new TextEditingController();


  }

  void _googleAuthentication() async{
    //await FirebaseAuth.instance.signOut();
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    if(googleUser != null) {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      // get the credentials to (access / id token)
      // to sign in via Firebase Authentication
      final AuthCredential credential = GoogleAuthProvider.getCredential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken
      );
      FirebaseAuth.instance.signInWithCredential(credential).then((value) async{
        if (value != null) {
          AuthStatus.isAnonymous = false;
          AuthStatus.currentUserId = value.user.uid;
          AuthStatus.currentUserNickname = value.user.displayName;
          if(!await UserDatabaseService().userExists(value.user.uid)){
            UserDatabaseService().addNewUser(value.user.uid);
          }
        }
      });

    }
  }

  Future sendPasswordResetEmail(String email) async{
      return FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }


  void _login() async {

    await FirebaseAuth.instance.signOut();
    if (emailController.text.isEmpty) {
      setState(() {
        _invalidEmail = true;
      });
      return;
    }
    else if (passwordController.text.isEmpty) {
      setState(() {
        _invalidPassword = true;
      });
      return;
    }

    try{
      AuthResult result = await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text);
      AuthStatus.isAnonymous = false;
      AuthStatus.currentUserId = result.user.uid;
      AuthStatus.currentUserNickname = result.user.displayName;
    }
    catch(error){
      showDialog(context: context, builder: (_) => AlertDialog(title: Text("Erreur de connexion"), content: Text("Adresse e-mail ou mot de passe incorrect"), actions: <Widget>[
      FlatButton(
      child: Text('OK'),
        onPressed: () {
          Navigator.of(context).pop();
        },
      )]
    ));
    }
  }




  void _goToRegister(){
      Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context){
              return Register();
            },
          )
      );
  }

  Future<void> _showResetPassword() async{
    return showDialog(context: context,
    barrierDismissible: false,
    builder: (BuildContext context){
      return new AlertDialog(
        title: Text("Réinitialiser le mot de passe",
            style: TextStyle(fontFamily:"Heebo")),
        contentPadding: EdgeInsets.only(left: 12.0,right: 12.0),
        content: Text("Envoyez moi un email pour réinitialiser le mot de passe?",
        style: TextStyle(fontFamily:"Heebo"),),
        actions: <Widget>[
          FlatButton(
            child: Text('Annuler'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text('OK'),
            onPressed:(){
                sendPasswordResetEmail(emailController.text);
                Navigator.of(context).pop();
            } ,
          )
        ],

      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if(widget.unverified){
      widget.unverified = false;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await showDialog<String>(
          context: context,
          builder: (BuildContext context) => new AlertDialog(
            title: new Text("Vérification de l'adresse e-mail"),
            content: new Text("Veuillez vérifier votre adresse e-mail avant de vous connecter"),
            actions: <Widget>[
              new FlatButton(
                child: new Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      });
    }
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.salmon,AppColors.cleanGrey],)
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: ListView(
              children: <Widget>[
                Center(child: SizedBox(height: 40,
                    child: SvgPicture.asset(
                      "assets/Reevy.svg",
                      color: Colors.white,

                    ) ),),

                SizedBox(height: 20),
                Center(child: Text(
                    "Bienvenue sur Reevy, ta source d'activités"
                ,style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,fontFamily: "Poppins", color: Colors.white),
                  )
                ),
                Center(child: Text(
                  "Connecte-toi pour profiter dès maintenant de tous"
                  ,style: TextStyle(fontSize: 12,fontFamily: "Poppins", color: Colors.white),
                  )
                ),
                Center(child: Text(
                  "les avantages de Reevy gratuitement."
                  ,style: TextStyle(fontSize: 12,fontFamily: "Poppins", color: Colors.white),
                )
                ),

                Container(
                padding: EdgeInsets.all(25),
                margin: EdgeInsets.fromLTRB(25,10,25,0),
                decoration: BoxDecoration(color: Colors.white,
                  borderRadius: new BorderRadius.all(Radius.circular(20)),
                ),
                child: Column(
                  children: <Widget>[
                    Text('Connexion', style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold, fontFamily: 'Heebo'),),
                    Container(
                      height: 70,
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: new InputDecoration(
                          hintText: "E-mail",
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                          errorText: _invalidEmail? "Email invalide": null,
                        ),
                        onChanged:(value){ setState(() {
                          if(_invalidEmail) {
                          _invalidEmail = !_invalidEmail;
                          }
                          });
                            }
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(0,20,0,0),
                    height: 70,
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: new InputDecoration(
                          hintText: "Mot de passe",
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                          errorText: _invalidPassword? "Ne peut pas être vide" : null
                      ),
                        onChanged:(value){ setState(() {
                          if(_invalidPassword) {
                            _invalidPassword = !_invalidPassword;
                          }
                        });
                        }
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0,20,0,0),
                    child: FlatButton(
                      color: AppColors.salmon,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      child: Text("    Connexion    ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontFamily: 'Heebo',
                      ),
                      ),
                        onPressed: _login
                      ),
                  ),
                    FlatButton(
                      
                      child: Text("Mot de passe oublié?",
                        style: TextStyle(
                          color: AppColors.salmon,
                          fontSize: 10.0,
                        ),
                      ),
                      onPressed: _showResetPassword,
                    ),
                  FlatButton(
                    child: Text("Se connecter avec Google",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.black,
                        fontSize: 14.0,
                      ),
                    ),
                    onPressed: _googleAuthentication,
                  ),


                ],
            ),
              ),
              Container(
                padding: EdgeInsets.all(25),
                margin: EdgeInsets.fromLTRB(25,30,25,10),
                decoration: BoxDecoration(color: Colors.white,
                  borderRadius: new BorderRadius.all(Radius.circular(20)),
                ),
                child: Column(
                  children: <Widget>[
                    Text("Pas encore de compte Reevy?",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: "Heebo"),
                    ),
                    FlatButton(
                      shape: RoundedRectangleBorder(side: BorderSide(
                          color: AppColors.salmon,
                          width: 1,
                          style: BorderStyle.solid
                      ), borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Text("Créer un compte",
                        style: TextStyle(
                          color: AppColors.salmon,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Heebo",
                        ),
                      ),
                      ),
                      onPressed: _goToRegister,
                    ),
                  ],
                ),
              ),
                Center(
                    child: Visibility(
                    visible: !AuthStatus.isAnonymous,
                   child: InkWell(
                        child: Text("Continuer sans se connecter?",
                        style: TextStyle(decoration: TextDecoration.underline,fontSize: 14, fontWeight: FontWeight.bold,fontFamily:"Heebo"),),
                        onTap: (){
                          AuthStatus.isAnonymous = true;
                          FirebaseAuth.instance.signInAnonymously();
                        }
                      )
                    )
                )]
          ),
    ),
        );
  }


}