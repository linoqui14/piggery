import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_dart/firebase_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
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
import 'dart:core';


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
  TextEditingController area = TextEditingController(text: "0");
  TextEditingController id = TextEditingController(text: "N/A");
  TextEditingController weight = TextEditingController(text: "N/A");
  String currentImageURL = "";
  String oldImageURL = "";
  bool canStream = true;
  bool isLoading = false;
  File? currentSelectedImageFile;
  File? currentSelectedPigFile;
  List<File> standings = [],laying = [];
  String currentLoadingMessage = "";
  String currentSelectedLoadingMessage = "";

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
  void analyzePig(File i){
    setState(() {
      currentSelectedLoadingMessage = "Analyzing pig...";
      this.area.text = "0";
      this.id.text = "N/A";
      var shell = Shell();
      shell.run("python yolov5/area.py --source "+i.path).then((value) {
        double area = double.parse(value.outText);
        setState(() {

          String name = i.path.split("\\").last;
          Directory(i.parent.parent.path+"\\selectedpigs\\"+name.split(".")[0]+"-"+Random().nextInt(10).toString()).create(recursive: true).then((createPath) {
            shell.run('python yolov5/detect.py --weights yolov5/id.pt --img 360 --conf 0.6  --hide-conf --source '+i.path+' --name '+createPath.path).then((id) {
              shell.kill();
              this.area.text = area.toString();
              shell.run('python yolov5/weight_predict.py --area '+double.parse(this.area.text).toString()).then((weight_value) {
                print(weight_value.outText);
                setState((){
                  currentSelectedLoadingMessage = i.path.split("\\").last.split(".")[0];
                  currentSelectedPigFile = File(createPath.path+"\\"+name);

                  this.id.text = id.outText.split('\n').last;
                  this.weight.text = double.parse((weight_value.outText)).toStringAsPrecision(3);
                });

              });

            });
          });

        });
      });

      currentSelectedPigFile = i;
    });
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
                                            if(!snapshot.hasData||isLoading) {
                                              return Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(currentLoadingMessage),
                                                  const Padding(padding: EdgeInsets.all(5)),
                                                  const CircularProgressIndicator()
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
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment:MainAxisAlignment.spaceEvenly,
                                                  children: [

                                                    Column(
                                                      children: [
                                                        FutureBuilder(
                                                          future:BaboyanController.get(imageId),
                                                          builder: (context, snapshot) {
                                                            if(!snapshot.hasData)return Center();
                                                            Baboyan baboyan = Baboyan.toObject((snapshot.data as Map<String,dynamic> ));
                                                            if(currentSelectedImageFile!=null){
                                                              // print("yesssssss");
                                                            }
                                                            return Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(baboyan.id,style: GoogleFonts.exo(fontWeight: FontWeight.w300),),
                                                                Text(DateFormat.yMMMMd().add_jm().format(DateTime.fromMillisecondsSinceEpoch(baboyan.time)),style: GoogleFonts.exo(fontWeight: FontWeight.bold),),
                                                              ],
                                                            );
                                                          },
                                                        ),
                                                        if(currentSelectedPigFile!=null)
                                                          SizedBox(
                                                              height: MediaQuery. of(context). size. height*0.55,
                                                              child: currentSelectedImageFile!=null?Image.file(currentSelectedImageFile!):Image.network(currentImageURL,fit: BoxFit.fitHeight,)
                                                          ),
                                                      ],
                                                    ),
                                                    // if(laying.isNotEmpty&&standings.isNotEmpty)
                                                    Column(
                                                      // crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text("Selected Pig",style: GoogleFonts.exo(fontWeight: FontWeight.w300)),
                                                        Text(currentSelectedLoadingMessage,style: GoogleFonts.exo(fontWeight: FontWeight.bold)),
                                                        if(currentSelectedPigFile!=null)
                                                          SizedBox(
                                                              width:300,
                                                              child: Image.file(currentSelectedPigFile!,height: 300,fit: BoxFit.contain,)
                                                          ),

                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(vertical: 5),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                            children: [
                                                              SizedBox(
                                                                height:50,
                                                                width:140,
                                                                child: CustomTextField(
                                                                    readonly: true,
                                                                    color: Colors.black54,
                                                                    hint: "Area", padding: EdgeInsets.zero, controller: area
                                                                ),

                                                              ),
                                                              Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
                                                              SizedBox(
                                                                height:50,
                                                                width:140,
                                                                child: CustomTextField(
                                                                    color: Colors.black54,
                                                                    hint: "ID", padding: EdgeInsets.zero, controller: id
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(vertical: 5),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              SizedBox(
                                                                height:50,
                                                                width:140,
                                                                child: CustomTextField(
                                                                    // readonly: true,
                                                                    color: Colors.black54,
                                                                    hint: "Predicted Weight", padding: EdgeInsets.zero, controller: weight
                                                                ),
                                                              ),
                                                              Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
                                                              CustomTextButton(
                                                                height: 50,
                                                                width: 125,
                                                                color: Colors.indigoAccent,
                                                                text: "Save",
                                                                onPressed: (){
                                                                  print(id.text);
                                                                  print(area.text);
                                                                  print(weight.text);
                                                                },
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),

                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Divider(),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: [
                                                        // Text("  Pigs",style: GoogleFonts.exo(fontWeight: FontWeight.bold,fontSize: 20),),
                                                        Text("  Laying",style: GoogleFonts.exo(fontWeight: FontWeight.bold,fontSize: 20),),
                                                        Text("  Standing",style: GoogleFonts.exo(fontWeight: FontWeight.bold,fontSize: 20),),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: CarouselSlider(
                                                            options: CarouselOptions(
                                                              // enlargeCenterPage: true,
                                                                enableInfiniteScroll: false,
                                                                viewportFraction: 0.1,
                                                                height: MediaQuery. of(context). size. height*0.15,
                                                                aspectRatio: 0
                                                            ),
                                                            items: laying.map((i) {
                                                              return Column(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  GestureDetector(
                                                                      onTap: (){
                                                                        analyzePig(i);
                                                                      },
                                                                      child: SizedBox(
                                                                          child: Image.file(i,height:90,)
                                                                      )
                                                                  )
                                                                ],
                                                              );
                                                            }).toList(),
                                                          ),
                                                        ),
                                                        Container(
                                                          color: Colors.black54,
                                                          child: SizedBox(
                                                            width: 2,
                                                            height:100,
                                                            child: Center(),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: CarouselSlider(
                                                            options: CarouselOptions(
                                                              // enlargeCenterPage: true,
                                                                enableInfiniteScroll: false,
                                                                viewportFraction: 0.1,
                                                                height: MediaQuery. of(context). size. height*0.15,
                                                                aspectRatio: 0
                                                            ),
                                                            items: standings.map((i) {

                                                              return Column(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [

                                                                  GestureDetector(
                                                                      onTap: (){
                                                                        analyzePig(i);
                                                                      },
                                                                      child: Column(
                                                                        children: [

                                                                          Image.file(i,height:90,),
                                                                        ],
                                                                      )
                                                                  )



                                                                ],
                                                              );


                                                            }).toList(),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                )
                                              ],
                                            );
                                          }
                                      ),


                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Divider(),
                                          Text("  Images",style: GoogleFonts.exo(fontWeight: FontWeight.bold,fontSize: 20),),
                                          CarouselSlider(
                                            options: CarouselOptions(
                                              // enlargeCenterPage: true,
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
                                                        Text("Loading image......."),
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
                                                              isLoading = true;
                                                              currentImageURL = snapshot.data!;
                                                              getApplicationDocumentsDirectory().then((path) {
                                                                var shell = Shell();
                                                                setState(() {
                                                                  currentLoadingMessage = "Detecting pigs...";
                                                                });
                                                                shell.run('python yolov5/detect.py --weights yolov5/body.pt --img 416 --conf 0.4 --overwrite --save-crop --hide-conf --source  $currentImageURL --name '+path.path+"\\result"
                                                                ).then((value) {
                                                                  shell.kill();
                                                                  currentSelectedImageFile = File(path.path+"\\result\\"+i.name);
                                                                  currentSelectedImageFile!.exists().then((ex)
                                                                  {
                                                                    setState(() {
                                                                      standings.clear();
                                                                      laying.clear();
                                                                      currentLoadingMessage = "Identifying ID's...";
                                                                    });
                                                                    shell.run('python yolov5/detect.py --weights yolov5/id.pt --img 416 --conf 0.4 --save-crop --save-txt --hide-conf --source '+currentSelectedImageFile!.path+' --name '+path.path+"\\result").then((value) {
                                                                      setState(() {
                                                                        currentSelectedImageFile = File(path.path+"\\result\\"+i.name);
                                                                        List<FileSystemEntity> filesStanding = [];
                                                                        List<FileSystemEntity> filesLaying = [];
                                                                        try{
                                                                          filesLaying = Directory(path.path+"\\result\\crops\\laying").listSync();
                                                                          filesLaying.forEach((element) {
                                                                            laying.add(File(element.path));
                                                                          });
                                                                          currentSelectedPigFile = laying.first;
                                                                        }catch(r){

                                                                        }
                                                                        try{
                                                                          filesStanding = Directory(path.path+"\\result\\crops\\standing").listSync();
                                                                          filesStanding.forEach((element) {
                                                                            standings.add(File(element.path));
                                                                          });
                                                                          currentSelectedPigFile = currentSelectedPigFile==null?laying.first:currentSelectedPigFile;
                                                                        }catch(r){

                                                                        }



                                                                        isLoading = false;

                                                                      });
                                                                      shell.kill();
                                                                    });
                                                                  });


                                                                });
                                                                // file.exists().then((value) => print(value));
                                                              });
                                                            });
                                                          },
                                                          child: Column(
                                                            children: [
                                                              SizedBox(
                                                                height:29,
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
                                          ),
                                        ],
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
  Directory findRoot(FileSystemEntity entity) {
    final Directory parent = entity.parent;
    if (parent.path == entity.path) return parent;
    return findRoot(parent);
  }
}
