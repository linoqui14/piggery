


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../transactions/baboy.dart';

class CustomTable extends StatefulWidget{
  const CustomTable({Key? key,required this.baboy,required this.index}) : super(key: key);
  final Baboy baboy;
  final int index;
  @override
  State<CustomTable> createState() => CustomTableState();

}

class CustomTableState extends State<CustomTable>{
  late Baboy baboy = Baboy(id: '',area: [0],weight: [0],date: [0]);
  double avrArea = 0,avrWeight = 0;
  @override
  void initState() {
    double totalWeight = 0;
    double totalArea = 0;
    baboy = widget.baboy;
    baboy.area.forEach((element) {
      totalArea+=element;
    });
    baboy.weight.forEach((element) {
      totalWeight+=element;
    });
    avrArea = totalArea/baboy.area.length;
    avrWeight = totalWeight/baboy.weight.length;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            children: [
              Text("ID",style: GoogleFonts.exo(color: Colors.black54,fontSize: 15,fontWeight: FontWeight.bold),),
              Text(baboy.id,style: GoogleFonts.exo(color: Colors.black54,fontSize: 30,fontWeight: FontWeight.bold),),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [

              Text("Date saved",style: GoogleFonts.exo(color: Colors.black54,fontSize: 15,fontWeight: FontWeight.bold),),
              Container(
                constraints: BoxConstraints(
                  minWidth: 100,
                  maxWidth: 300,
                  minHeight: 100,
                  maxHeight: 100,

                ),
                child: ListView(
                  children: baboy.date.map((e) {
                    return Expanded(
                      child: Container(
                          alignment: Alignment.center,
                          margin:EdgeInsets.symmetric(vertical: 1) ,
                          padding:EdgeInsets.symmetric(vertical: 1) ,
                          color: Colors.black12,
                          child: Text(DateFormat.yMMMMd().add_jm().format(DateTime.fromMillisecondsSinceEpoch(e)),style: GoogleFonts.exo(color: Colors.black54,fontSize: 15,fontWeight: FontWeight.bold),),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [

              Text("Predicted areas",style: GoogleFonts.exo(color: Colors.black54,fontSize: 15,fontWeight: FontWeight.bold),),
              Container(
                constraints: BoxConstraints(
                  minWidth: 100,
                  maxWidth: 300,
                  minHeight: 100,
                  maxHeight: 100,

                ),
                child: ListView(
                  children: baboy.area.map((e) {
                    return Container(
                        alignment: Alignment.center,
                        margin:EdgeInsets.symmetric(vertical: 1) ,
                        padding:EdgeInsets.symmetric(vertical: 1) ,
                        color: Colors.black12,
                        child: Text(e.toString(),style: GoogleFonts.exo(color: Colors.black54,fontSize: 15,fontWeight: FontWeight.bold),)
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [

              Text("Predicted weights",style: GoogleFonts.exo(color: Colors.black54,fontSize: 15,fontWeight: FontWeight.bold),),
              Container(

                constraints: BoxConstraints(
                  minWidth: 100,
                  maxWidth: 300,
                  minHeight: 100,
                  maxHeight: 100,

                ),
                child: ListView(
                  children: baboy.weight.map((e) {
                    return Container(
                        alignment: Alignment.center,
                        margin:EdgeInsets.symmetric(vertical: 1) ,
                        padding:EdgeInsets.symmetric(vertical: 1) ,
                        color: Colors.black12,
                        child: Text(e.toString(),style: GoogleFonts.exo(color: Colors.black54,fontSize: 15,fontWeight: FontWeight.bold),)
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        // Column(
        //   children: [
        //
        //     Text("Predicted areas average",style: GoogleFonts.exo(color: Colors.black54,fontSize: 15,fontWeight: FontWeight.bold),),
        //     Text(avrArea.toStringAsFixed(1),style: GoogleFonts.exo(color: Colors.black54,fontSize: 30,fontWeight: FontWeight.bold),),
        //   ],
        // ),
        Expanded(
          child: Column(
            children: [

              Text("Predicted weight average",style: GoogleFonts.exo(color: Colors.black54,fontSize: 15,fontWeight: FontWeight.bold),),
              Text(avrWeight.toStringAsFixed(1),style: GoogleFonts.exo(color: Colors.black54,fontSize: 30,fontWeight: FontWeight.bold),),
            ],
          ),
        ),
      ],
    );

  }

}