import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reevy/activity/comment.dart';
import 'package:reevy/activity/commentDatabase.dart';
import 'package:reevy/globals.dart';
import '../account/LoginView.dart';
class CommentView extends StatefulWidget{
  final String activityID;
  final List<String> forbiddenWords = ["merde" ,"con", "putain", "chier", "chié", "connard", "pute", "salope", "salaud", "salop", "enculer", "enculé", "couillon", "bite"];
  CommentView({Key key, @required this.activityID}) : super(key: key);

  @override
  _CommentViewState createState() => _CommentViewState();

}
class _CommentViewState extends State<CommentView> {
  TextEditingController _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  void _postComment() async {
    if (_formKey.currentState.validate()){
      Comment(AuthStatus.currentUserNickname, widget.activityID, _commentController.text, Timestamp.now()).saveToDatabase();
      _commentController.text = "";
      (context as Element).reassemble();
    }
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

  Widget commentCard(List<Comment> comments, int index){
    return Card(
      color: AppColors.commentGrey,
        margin: EdgeInsets.only(left : 20, right: 20, bottom: 20, top: 10),
        shape: RoundedRectangleBorder(borderRadius: new BorderRadius.all(Radius.circular(14))),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: comments[index].toRichText(),
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
                "Commentaires"
                ,style: TextStyle(color: Colors.black, fontSize: 16,fontFamily: "Poppins", fontWeight: FontWeight.bold),
              ),
            ],
          ), centerTitle: true,
        ),
        body:Column(
          crossAxisAlignment:CrossAxisAlignment.stretch,
          children: <Widget>[
            FutureBuilder(
              future: CommentDatabaseService().getActivityComments(widget.activityID),
              builder: (BuildContext context, AsyncSnapshot<List<Comment>> snapshot){
                if(snapshot.hasData){
                  return Expanded(
                      child: ListView.builder(
                        itemBuilder: (context, index) => commentCard(snapshot.data, index),
                        itemCount: snapshot.data.length,
                        itemExtent: 110,
                      )
                  );
                }
                else{
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
            Visibility(
            visible: !AuthStatus.isAnonymous,
            child: Form(
              key: _formKey,
              child: TextFormField(
                maxLength: 144,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                controller: _commentController,
                validator: (text){
                  for(String forbiddenWord in widget.forbiddenWords){
                    if(_commentController.text.toLowerCase().contains(forbiddenWord)){
                      return "Contient un mot interdit";
                    }
                  }
                  return null;
                },
                decoration: new InputDecoration(
                hintText: "Commentaire",
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _postComment,
                    color: AppColors.salmon,
                  ),
                ),
              ),
              )
            ),
            Visibility(
              visible: AuthStatus.isAnonymous,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
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
            )

          ],
        )

    );
  }




}