import 'package:flutter/material.dart';
import 'package:piggery/pages/home.dart';
import 'package:piggery/transactions/controller.dart';

import '../custom_widgets/CustomTable.dart';
import '../custom_widgets/custom_textbutton.dart';
import '../transactions/baboy.dart';
class Record extends StatefulWidget{
  const Record({Key? key,}) : super(key: key);
  @override
  State<Record> createState() => RecordState();

}

class RecordState extends State<Record>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: FutureBuilder<dynamic>(
          future: BaboyController.getAll(),
          builder: (context, snapshot) {

            if(!snapshot.hasData) return Center(child: CircularProgressIndicator(),);
            if(snapshot.connectionState == ConnectionState.waiting)return Center(child: CircularProgressIndicator(),);
            Map<dynamic,dynamic> data =( snapshot.data as  Map<dynamic,dynamic>);
            List<Baboy> baboys = [];
            data.values.forEach((element) {
              List<double> tempWeight = [];
              List<double> tempArea = [];
              List<int> tempDate = [];
              Map<String,dynamic> _data = (element as Map<String,dynamic>);
              var dataWeight =  Map<String, dynamic>.from(_data['weight']);
              var dataArea =  Map<String, dynamic>.from(_data['area']);
              var dataDate =  Map<String, dynamic>.from(_data['date']);
              dataWeight.values.forEach((element) {
                tempWeight.add(element);
              });
              dataArea.values.forEach((element) {
                tempArea.add(element);
              });
              dataDate.values.forEach((element) {
                tempDate.add(element);
              });

              Baboy baboy = Baboy(id: _data['id'],weight: tempWeight,area: tempArea,date: tempDate);
              baboys.add(baboy);
            });

            return Column(
              children: [
               
                Container(
                  padding: EdgeInsets.all(15),
                  height:  MediaQuery. of(context). size. height-50,
                  width: MediaQuery. of(context). size. width,
                  child: ListView(
                    children: baboys.map((e) {
                      return CustomTable(baboy:e,index: baboys.indexOf(e),);
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: CustomTextButton(
        icon: Icon(Icons.arrow_back,color: Colors.white,size: 20,),
        allRadius: 0,
        color: Colors.deepOrangeAccent,
        text: "Back",
        width: 150,
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyHomePage()),
          );
        },
      ),
    );
  }

}