
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';


class StoragePage extends StatefulWidget {
  @override
  _StoragePageState createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {

  final FirebaseStorage _storage = FirebaseStorage.instance;

  get path => null;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),

        ),
        centerTitle: true,
        title: Text("ADD FILES TO CLOUD"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _getFiles,
        icon: Icon(Icons.compare_arrows),
        label: Text("ADD FILES"),
        shape: RoundedRectangleBorder(),
      ),
    );
  }

  void _getFiles() async{

    try{
      File file = await FilePicker.getFile();
      _uploadFile(file);
    }catch(e){
      print(e.message);
    }

  }

  void _uploadFile(File file) async{
    String fileName = path.basename(file.path);

    _storage.ref().child("images").child(fileName).putFile(file);
  }
}
