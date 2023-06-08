import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import 'main.dart';

class DetectedImage extends StatefulWidget {
  const DetectedImage({Key? key}) : super(key: key);

  @override
  State<DetectedImage> createState() => _DetectedImageState();
}

class _DetectedImageState extends State<DetectedImage> {
  InputImage? imagee;
  String? fileImage;
  File? filee;
  String? speakerName;

@override
  void initState() {
    assignVariables();
    super.initState();
  }
Future assignVariables() async{

  fileImage = Get.arguments['file'] ;
  filee = File(fileImage!);
  print(fileImage);

  setState(() {});
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_outlined),onPressed: (){Get.off(()=>Home());},),
        title: Text("Face is detected"),
        ),
          body: Center(
            child: Column(
              children: [
                SizedBox(height: 70),
                Container(
                  height: 300,
                  width: 300,
                  child:filee==null? CircularProgressIndicator():
                  CircleAvatar(
                    backgroundImage: FileImage(filee!),
                    radius: 20,
                  ),
                ),
                SizedBox(height: 180),
                speakerName==null? Text("Name",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30),):Text("$speakerName")
              ],
            )
          ),
    );
  }
}
