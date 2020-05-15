import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todoapp/storefile.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _taskTxt = TextEditingController();

  // FireBase User Instance and Cloud Instance
  // to add task

  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;

  final Firestore _db = Firestore.instance;

  @override
  void initState() {
    getUid();
    // TODO: implement initState
    super.initState();
  }

  void getUid() async {
    FirebaseUser u = await _auth.currentUser();
    setState(() {
      user = u;
    });
  }

  bool done = false;

  //SnackBar Use
  final snackBar = SnackBar(content: Text('ADDED TO DONE TASK LIST'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.tag_faces),
            onPressed: changeBrightness,
          )
        ],
        title: Text(
          "TASKS",
          style: TextStyle(color: Colors.white, letterSpacing: 2),
        ),
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      body: StreamBuilder(
        stream: _db
            .collection("users")
            .document(user.uid)
            .collection("tasks")
            .orderBy("date", descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            return ListView(
              children: snapshot.data.documents.map((snap) {
                return ListTile(
                  title: Text(snap.data["task"]),
                  onTap: () {},
                  leading: Checkbox(
                    value: done,
                    onChanged: (bool newValue) {
                      setState(() {
                        done = newValue;
                        if(done){
                          Scaffold.of(context).showSnackBar(snackBar);
                        }
                      });
                    },
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      _db
                          .collection("users")
                          .document(user.uid)
                          .collection("tasks")
                          .document(snap.documentID)
                          .delete();
                    },
                  ),
                );
              }).toList(),
            );
          }
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.green,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog();
        },
        child: Icon(Icons.add),
        elevation: 0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Navigator.of(context).push(new MaterialPageRoute(builder: (context){
                  return StoragePage();
                }));
              },
            ),
            IconButton(
              icon: Icon(Icons.perm_identity),
              onPressed: () {
                _showProfile();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog() {
    showDialog(
        context: context,
        builder: (cxt) {
          return SimpleDialog(
            contentPadding: EdgeInsets.all(10),
            title: Text("Add Task"),
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(2),
                child: TextField(
                  controller: _taskTxt,
                  decoration: InputDecoration(
                    hintText: "Write task here",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(20),
                child: Row(
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () async {
                        String task = _taskTxt.text.trim();

//                        final FirebaseUser user = await FirebaseAuth.instance.currentUser();

                        _db.collection("users").document(user.uid)
                          ..collection("tasks").add({
                            "task": task,
                            "date": DateTime.now(),
                          });

                        _taskTxt.clear();

                        Navigator.of(cxt).pop();
                      },
                      color: Colors.green[300],
                      child: Text("ADD"),
                    )
                  ],
                ),
              ),
              SafeArea(
                child: InkWell(
                  child: Icon(
                    Icons.close,
                    color: Colors.red[300],
                  ),
                  splashColor: Color(0x00000000),
                  onTap: () {
                    Navigator.of(cxt).pop();
                  },
                ),
              )
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          );
        });
  }

  void _showProfile() {
    showDialog(
      context: context,
      builder: (cxt) {
        return SimpleDialog(
          contentPadding: EdgeInsets.all(50),
          children: <Widget>[
            Center(
                child: Image(
              image: NetworkImage(user.photoUrl),
              width: 100,
              height: 100,
            )),
            Container(
              height: 10,
            ),
            Center(
                child: Text(
              user.displayName,
              style: TextStyle(color: Colors.green[300], fontSize: 20),
            )),
            Container(
              height: 30,
            ),
            Container(
              width: 70,
              height: 50,
              child: RaisedButton(
                color: Colors.red[300],
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context).pop();
                },
                child: Text("Logout"),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  void changeBrightness() {
    DynamicTheme.of(context).setBrightness(
        Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark);
  }
}

// Dynamic theme

// To do Completed task to be move in Menu
