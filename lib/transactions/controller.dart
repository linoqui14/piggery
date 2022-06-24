import 'package:firebase_dart/core.dart';
import 'package:firebase_dart/database.dart';
import 'package:firebase_dart/implementation/pure_dart.dart';
import 'package:firebase_dart/implementation/testing.dart';
import 'package:piggery/transactions/baboyan.dart';
import 'package:piggery/transactions/commands.dart';
import 'package:piggery/tools/variables.dart';

import '../main.dart';
import 'baboy.dart';



// var app = await Firebase.initializeApp(options: options);
//
// var backend = FirebaseTesting.getBackend(app.options);
class CommandController{

  static void set(Command command)async{
    var db = FirebaseDatabase(app: app,databaseURL: 'https://esp32cam-41b21-default-rtdb.asia-southeast1.firebasedatabase.app/');
    // db.reference().set(command.toMap());
    db.reference().update(command.toMap());

  }
  static Stream<Event> get(){
    var db = FirebaseDatabase(app: app,databaseURL: 'https://esp32cam-41b21-default-rtdb.asia-southeast1.firebasedatabase.app/');
    return db.reference().child('Commands').onValue;
  }
}

class BaboyanController{

  static void set(Baboyan baboyan)async{
    var db = FirebaseDatabase(app: app,databaseURL: 'https://esp32cam-41b21-default-rtdb.asia-southeast1.firebasedatabase.app/');
    // db.reference().set(command.toMap());
    db.reference().child('Baboyan').update(baboyan.toMap());

  }
  static Future<dynamic> get(String id){
    var db = FirebaseDatabase(app: app,databaseURL: 'https://esp32cam-41b21-default-rtdb.asia-southeast1.firebasedatabase.app/');
    return db.reference().child('Baboyan').child(id).get();
  }
}

class BaboyController{

  static void set(Baboy baboy)async{
    var db = FirebaseDatabase(app: app,databaseURL: 'https://esp32cam-41b21-default-rtdb.asia-southeast1.firebasedatabase.app/');
    // db.reference().set(command.toMap());
    db.reference().child('Baboy').update(baboy.toMap());

  }
  static Future<dynamic> get(String id){
    var db = FirebaseDatabase(app: app,databaseURL: 'https://esp32cam-41b21-default-rtdb.asia-southeast1.firebasedatabase.app/');
    return db.reference().child('Baboy').child(id).get();
  }
  static Future<dynamic> getAll(){
    var db = FirebaseDatabase(app: app,databaseURL: 'https://esp32cam-41b21-default-rtdb.asia-southeast1.firebasedatabase.app/');
    return db.reference().child('Baboy').get();
  }
}