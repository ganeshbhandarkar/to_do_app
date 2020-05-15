import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;


  // Google Sign object

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );


  @override
  Widget build(BuildContext context) {
    // Get Email and Pass from Textfield
    // Use of Text Editing Controller



    final width = MediaQuery
        .of(context)
        .size
        .width;
    final height = MediaQuery
        .of(context)
        .size
        .height;




    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.only(top: 100),
//        decoration: BoxDecoration(
////          boxShadow: [
////            BoxShadow(
////              color: Color(0x44000000),
////              blurRadius: (40),
////              offset: Offset(
////                10,10
////              ),
////              spreadRadius: 0
////            )
////          ]
////        ),
        width: width,
        child: Column(
          children: <Widget>[
            Image(
              image: AssetImage(
                "assets/logo.png",
              ),
              height: 200,
              width: 200,
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Email",
                  hintText: "Email",
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Password",
                  hintText: "Enter Pin",
                ),
                obscureText: true,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: RaisedButton(
                  onPressed: () {
                    _signIn();
                  },
                  padding: EdgeInsets.all(20),
                  child: Center(
                      child: Text(
                        "LOGIN",
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      )),
                  color: Colors.green[400],
                ),
              ),
            ),
            Center(
              child: FlatButton(
                onPressed: () {},
                child: Text("Sign Up"),
              ),
            ),
            Container(
              width: width,
              margin: EdgeInsets.only(top: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  InkWell(
                    onTap: () {},
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Icon(
                          Icons.phone,
                        ),
                        Container(
                          width: 20,
                        ),
                        Text(
                          "Phone",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Colors.blueGrey),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  InkWell(
                    onTap: () {
                      _signInWithGoogle();
                    },
                    child: Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Icon(
                            Icons.perm_identity,
                          ),
                          Container(
                            width: 20,
                          ),
                          Text(
                            "Google",
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Colors.blueGrey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );


  }

  void _signIn() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {


      _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
      ).then((user){

        showDialog(
            context: context,
            builder: (cxt){
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Text("SignIn Success"),
                content: Text("Done"),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Cancel"),
                    onPressed: (){
                      Navigator.of(cxt).pop();
                    },
                  ),
                  FlatButton(
                    child: Text("Ok"),
                    onPressed: (){
                      _emailController.text = "";
                      _passwordController.text = "";
                      Navigator.of(cxt).pop();
                    },
                  ),
                ],
              );
            }
        );

      })
          .catchError((e){
        showDialog(
            context: context,
            builder: (cxt){
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Text("${e.message}"),
                content: Text("Pls provide Email and Pass"),
                actions: <Widget>[
                  FlatButton(
                    child: Text("Cancel"),
                    onPressed: (){
                      Navigator.of(cxt).pop();
                    },
                  ),
//                    FlatButton(
//                      child: Text("Ok"),
//                      onPressed: (){
//                        _emailController.text = "";
//                        _passwordController.text = "";
//                        Navigator.of(cxt).pop();
//                      },
//                    ),
                ],
              );
            }
        );
      });

    } else {
      showDialog(
          context: context,
          builder: (cxt){
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text("Error"),
              content: Text("Pls provide Email and Pass"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancel"),
                  onPressed: (){
                    Navigator.of(cxt).pop();
                  },
                ),
                FlatButton(
                  child: Text("Ok"),
                  onPressed: (){
                    _emailController.text = "";
                    _passwordController.text = "";
                    Navigator.of(cxt).pop();
                  },
                ),
              ],
            );
          }
      );
    }
  }

  void _signInWithGoogle() async{

    try{
      final GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

//    final AuthResult authResult = await _auth.signInWithCredential(credential);
//    final FirebaseUser user = authResult.user;
//
//    assert(!user.isAnonymous);
//    assert(await user.getIdToken() != null);
//
//    final FirebaseUser currentUser = await _auth.currentUser();
//    assert(user.uid == currentUser.uid);

      final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
      print(user.displayName);

      if(user != null){
          _db.collection("users").document(user.uid).setData({
            "displayName": user.displayName,
            "email" : user.email,
            "lastSeen" : DateTime.now(),
            "photoUrl" : user.photoUrl,
          });
      }

    }catch(e){

      showDialog(
          context: context,
          builder: (cxt){
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text("${e.message}"),
              content: Text("Pls provide Email and Pass"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancel"),
                  onPressed: (){
                    Navigator.of(cxt).pop();
                  },
                ),
//                    FlatButton(
//                      child: Text("Ok"),
//                      onPressed: (){
//                        _emailController.text = "";
//                        _passwordController.text = "";
//                        Navigator.of(cxt).pop();
//                      },
//                    ),
              ],
            );
          }
      );

    }

  }
}
