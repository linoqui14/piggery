import 'dart:async';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_dart/firebase_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:piggery/custom_widgets/custom_texfield.dart';
import 'package:piggery/custom_widgets/custom_textbutton.dart';
import 'package:piggery/transactions/commands.dart';
import 'package:piggery/transactions/controller.dart';
import 'package:intl/intl.dart';
import 'package:process_run/shell.dart';
import '../main.dart';
import '../tools/variables.dart';
import '../transactions/baboyan.dart';
import 'package:process_run/process_run.dart';



class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int test = 0;
  var storage = FirebaseStorage.instanceFor(app: app);
  TextEditingController count = TextEditingController(text: '0');
  String currentImageURL = "";
  String oldImageURL = "";
  bool canStream = true;

  @override
  void initState() {
    // storage.ref('/').list().then((value) {
    //   value.items.forEach((element) {
    //     element.getDownloadURL().then((url) {
    //       Tools.downloadFile(url, element.name).then((path) {
    //         print(path.path);
    //       });
    //     });
    //   });
    // });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          child: Row(
            children: [
              Expanded(
                  child: StreamBuilder<Event>(
                      stream: CommandController.get(),
                      builder: (context, snapshot) {
                        if(!snapshot.hasData) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text("Loading image..."),
                              CircularProgressIndicator()
                            ],
                          );
                        }
                        Command command = Command.toObject((snapshot.data!.snapshot.value as Map<String,dynamic>));

                        return Container(
                            alignment: Alignment.center,
                            height: double.infinity,
                            color: Colors.black.withAlpha(10),
                            child:StreamBuilder<ListResult>(
                                stream: storage.ref('/').list().asStream(),
                                builder: (context, snapshot) {
                                  if(!snapshot.hasData) {
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Text("Loading image..."),
                                        CircularProgressIndicator()
                                      ],
                                    );
                                  }
                                  snapshot.data!.items.forEach((element) {
                                    String imageId = element.name.split('.')[0];
                                    BaboyanController.get(imageId).then((value) {
                                      if(value == null){
                                        print(value.toString()+" - "+imageId);
                                        Baboyan baboyan = Baboyan(id: imageId,time: DateTime.now().millisecondsSinceEpoch);
                                        BaboyanController.set(baboyan);
                                      }
                                    });
                                  });
                                  return Column(
                                    children: [
                                      FutureBuilder<String>(
                                          future: snapshot.data!.items.last.getDownloadURL(),
                                          builder:(context,snapshot){

                                            if(!snapshot.hasData) {
                                              return Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: const [
                                                  Text("Loading image..."),
                                                  Padding(padding: EdgeInsets.all(5)),
                                                  CircularProgressIndicator()
                                                ],
                                              );
                                            }
                                            if(oldImageURL!=snapshot.data!){
                                              currentImageURL = snapshot.data!;
                                              oldImageURL =  snapshot.data!;
                                            }
                                            String imageId = currentImageURL.split('/')[7].split('?')[0].split('.')[0];

                                            return Column(
                                              mainAxisAlignment: MainAxisAlignment.center,

                                              children: [
                                                if(command.command.contains('capture'))
                                                  Text(command.command.split('-')[1],style: GoogleFonts.exo(fontWeight: FontWeight.bold,fontSize: 30),),
                                                FutureBuilder(
                                                  future:BaboyanController.get(imageId),
                                                  builder: (context, snapshot) {
                                                    if(!snapshot.hasData)return Center();
                                                    Baboyan baboyan = Baboyan.toObject((snapshot.data as Map<String,dynamic> ));

                                                    return Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(baboyan.id,style: GoogleFonts.exo(fontWeight: FontWeight.w300),),
                                                        Text(DateFormat.yMMMMd().add_jm().format(DateTime.fromMillisecondsSinceEpoch(baboyan.time)),style: GoogleFonts.exo(fontWeight: FontWeight.bold),),
                                                      ],
                                                    );
                                                  },
                                                ),
                                                SizedBox(
                                                    height: MediaQuery. of(context). size. height*0.8,
                                                    child: Image.network(currentImageURL,fit: BoxFit.fitHeight,)
                                                ),
                                              ],
                                            );
                                          }
                                      ),
                                      CarouselSlider(
                                        options: CarouselOptions(
                                            enableInfiniteScroll: false,
                                            viewportFraction: 0.1,
                                            height: MediaQuery. of(context). size. height*0.15,
                                            aspectRatio: 0
                                        ),
                                        items: snapshot.data!.items.map((i) {

                                          return FutureBuilder<String>(
                                            future: i.getDownloadURL(),
                                            builder: (context,snapshot) {
                                              if(!snapshot.hasData) {
                                                return Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: const [
                                                    Text("Loading image..."),
                                                    Padding(padding: EdgeInsets.all(5)),
                                                    CircularProgressIndicator()
                                                  ],
                                                );
                                              }
                                              // File? image = NetworkToFileImage(
                                              //     url: snapshot.data
                                              // ).file;
                                              // print(image);

                                              return Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [

                                                   GestureDetector(
                                                        onTap: (){
                                                          setState(() {
                                                            currentImageURL = snapshot.data!;
                                                            var shell = Shell();
                                                            shell.run('''
                                                            cd yolov5
                                                            python yolov5/detect.py --weights yolov5/runs/train/yolov5s_results3/weights/best.pt --img 416 --conf 0.4 --source $currentImageURL --name results
                                                            ''').then((value) {
                                                              print(value.outText);
                                                              shell.kill();
                                                            });

                                                          });
                                                        },
                                                       child: Column(
                                                         children: [
                                                           SizedBox(
                                                             height:30,
                                                             child: FutureBuilder(
                                                               future:BaboyanController.get(i.name.split('.')[0]),
                                                               builder: (context, snapshot) {
                                                                 if(!snapshot.hasData)return Center();
                                                                 Baboyan baboyan = Baboyan.toObject((snapshot.data as Map<String,dynamic> ));

                                                                 return Column(
                                                                   crossAxisAlignment: CrossAxisAlignment.start,
                                                                   children: [
                                                                     Text(baboyan.id,style: GoogleFonts.exo(fontWeight: FontWeight.w300,fontSize: 12),),
                                                                     Text(DateFormat.yMMMMd().add_jm().format(DateTime.fromMillisecondsSinceEpoch(baboyan.time)),style: GoogleFonts.exo(fontWeight: FontWeight.bold,fontSize: 10),),
                                                                   ],
                                                                 );
                                                               },
                                                             ),
                                                           ),
                                                           Image.network(snapshot.data!,height:90,),
                                                         ],
                                                       )
                                                   )



                                                ],
                                              );
                                            },
                                          );
                                        }).toList(),
                                      )
                                    ],
                                  );
                                }
                            )

                        );
                      }
                  )
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                    minWidth: 100,
                    maxWidth: 300
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomTextButton(
                        icon: Icon(Icons.photo_camera,color: Colors.white,size: 20,),
                        style: GoogleFonts.exo(color: Colors.white),
                        text: "Snap",
                        width: 150,
                        allRadius: 25,
                        color: Colors.black54,
                        onPressed: (){
                          Command command = Command(command: 'snap',from: Constants.hostname,to: '001');
                          CommandController.set(command);
                        },
                      ),
                      Padding(padding: EdgeInsets.all(10)),
                      CustomTextButton(
                        icon: Icon(Icons.add_a_photo,color: Colors.white,size: 20,),
                        width: 150,
                        style: GoogleFonts.exo(color: Colors.white),
                        text: "Capture multiple",
                        allRadius: 25,
                        color: Colors.redAccent,
                        onPressed:canStream? (){
                          Command command = Command(command: 'capture-'+count.text,from: Constants.hostname,to: '001');
                          CommandController.set(command);

                        }:null,
                      ),
                      Padding(padding: EdgeInsets.all(10)),
                      CustomTextField(
                        onChange: (text){
                          setState(() {
                            if(text.isEmpty) {
                              canStream = false;
                            }else {
                              canStream = true;
                            }
                          });
                        },
                        hint: "count",
                        padding: EdgeInsets.all(10),
                        controller:count ,
                        keyBoardType: TextInputType.number,)
                    ],
                  ),
                ),
              ),

            ],
          ),
        )
    );
  }
}
