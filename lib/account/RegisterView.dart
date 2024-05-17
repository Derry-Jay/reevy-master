import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/svg.dart';
import '../globals.dart';
import 'LoginView.dart';
import 'MyAccountView.dart';
import 'userDatabase.dart';
class Register extends StatefulWidget{
  @override
  _RegisterState createState() => _RegisterState();

}

class _RegisterState extends State<Register> {

  TextEditingController emailController;
  TextEditingController passwordController;
  TextEditingController displayNameController;
  TextEditingController confirmPasswordController;

  @override
  void initState(){
    super.initState();
    emailController = new TextEditingController();
    passwordController = new TextEditingController();
    displayNameController = new TextEditingController();
    confirmPasswordController = new TextEditingController();
  }

  void _register() async{
    if(emailController.text == "" || passwordController.text == "" || displayNameController.text == ""){
      //TODO: Mettre en évidence les champs incorrects
      return;
    }

    if(!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(emailController.text)){
      //TODO: Indiquez que l'adresse mail est incorrecte
      return;
    }

    if(confirmPasswordController.text != passwordController.text){
      //TODO: Mettre en évidence les champs de mot de passe et indiquez qu'ils ne sont pas les mêmes
      return;
    }

    await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailController.text.trim(), password: passwordController.text).then((value) async{
      if(value != null){
        Navigator.of(context).pop();
        AuthStatus.isAnonymous = false;
        AuthStatus.currentUserId = value.user.uid;
        AuthStatus.currentUserNickname = value.user.displayName;
        UserDatabaseService().addNewUser(value.user.uid);
        UserUpdateInfo updateInfo = UserUpdateInfo();
        updateInfo.displayName = displayNameController.text;
        await value.user.updateProfile(updateInfo);
        await value.user.reload();
      }
    });

  }

  void _goToLogin(){
    Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context){
            return Login(unverified: false);
          },
        )
    );
  }

    @override
    Widget build(BuildContext context) {
      return Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,colors: [AppColors.salmon,AppColors.cleanGrey],)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: ListView(children: <Widget>[
            Center(child: SizedBox(height: 40,
                child: SvgPicture.asset(
                  "assets/Reevy.svg",
                  color: Colors.white,

                ) ),),
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
                children: [
                  Text("J'ai déjà un compte",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: "Heebo"),),
              FlatButton(
                color: Colors.white,
                shape: RoundedRectangleBorder(side: BorderSide(
                  color: AppColors.salmon,
                  width: 1,
                  style: BorderStyle.solid),
                  borderRadius: BorderRadius.all(Radius.circular(10)),),
                child: Text("Se connecter",
                  style: TextStyle(
                    color: AppColors.salmon,
                    fontSize: 16.0,
                    fontFamily: 'Heebo',
                  ),
                ),
                onPressed: _goToLogin,)
                ],
              ),
            ),
            Container(
            padding: EdgeInsets.all(25),
            margin: EdgeInsets.fromLTRB(25,10,25,0),
            decoration: BoxDecoration(color: Colors.white,
              borderRadius: new BorderRadius.all(Radius.circular(20)),
            ),
            child: Column(
              children: <Widget>[
                  Text('Créer un compte',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: "Heebo"),),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: new InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                          hintText: "E-mail"
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: TextField(
                      controller: displayNameController,
                      decoration: new InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                          hintText: "Pseudonyme"
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: new InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                          hintText: "Mot de passe"
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                    child: TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: new InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                          hintText: "Confirmer le mot de passe"
                      ),
                    ),
                  ),
                  FlatButton(
                    color: AppColors.salmon,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                    child: Padding(padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                      child:Text("S'inscrire",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontFamily: 'Heebo',
                      ),
                    ),
                    ),
                    onPressed: _register,
                  )
                ],
              ),
            ),
          ]
          )
        ),
      );
    }


  }