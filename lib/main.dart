import 'package:fface_detection_testing/detected_image.dart';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;


late List<CameraDescription> _cameras;


void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();

  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}




class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}



class _HomeState extends State<Home> {
  File? imageFile;
  CameraController? controller;
  // InputImage? converteddimage;
  late InputImage? inputImage;
  bool isCapturing =false;
  List<Face> faces=[];



@override
  void dispose(){
  stopController();
  faceDetector.close();

    super.dispose();
  }





@override
  initState() {
    // TODO: implement initState
  _initializeCamera();
  super.initState();

}





final faceDetector = GoogleMlKit.vision.faceDetector(
  FaceDetectorOptions(
    enableClassification: true,
    enableLandmarks: true,
    enableContours: true,
    enableTracking: true,
  ),
);



void _initializeCamera()async {
  controller = CameraController(_cameras[1], ResolutionPreset.max);
  await controller!.initialize().then((_) async {
    if (!mounted) {
      return;
    }
    setState(() {});

    controller!.startImageStream((CameraImage? image)async{

      print("before processing ==========================================================================");

      var converteddimage= await _processCameraImage(image!);

      print("after processing ===========================================================================");

      print(converteddimage!.filePath);

      await _detectFaces(converteddimage);

      // faces = await faceDetector.processImage(converteddimage!);

      if (faces.isNotEmpty){

        print("Faces Detected ===========================================================================");

        faces=[];
        converteddimage=null;
        inputImage=null;


        if (isCapturing) {
          return;
        }

        isCapturing = true;

        try {
          controller?.stopImageStream();
          // Take the picture using the camera controller
          final image = await controller!.takePicture();
          // Save the picture to a file
          imageFile = File(image.path);
        } catch (e) {
          print(e);
        } finally {
          isCapturing = false;
        }






        Get.off(()=>DetectedImage(),arguments: {
          'file':imageFile!.path,
        });
      }
      else{
        print("No Faces Detected");

      }

    });

  });
}



Future stopController()async{
  await controller?.dispose();
  controller = null;
}

Future _detectFaces(InputImage? converteddimage)async{
  faces = await faceDetector.processImage(converteddimage!);
}


Future _processCameraImage(CameraImage image) async {
  final WriteBuffer allBytes = WriteBuffer();
  for (final Plane plane in image.planes) {
    allBytes.putUint8List(plane.bytes);
  }
  final bytes = allBytes.done().buffer.asUint8List();

  final Size imageSize =
  Size(image.width.toDouble(), image.height.toDouble());

  final camera = _cameras[1];
  final imageRotation =
  InputImageRotationValue.fromRawValue(camera.sensorOrientation);
  if (imageRotation == null) return;

  final inputImageFormat =
  InputImageFormatValue.fromRawValue(image.format.raw);
  if (inputImageFormat == null) return;

  final planeData = image.planes.map(
        (Plane plane) {
      return InputImagePlaneMetadata(
        bytesPerRow: plane.bytesPerRow,
        height: plane.height,
        width: plane.width,
      );
    },
  ).toList();

  final inputImageData = InputImageData(
    size: imageSize,
    imageRotation: imageRotation,
    inputImageFormat: inputImageFormat,
    planeData: planeData,
  );

  inputImage =
  InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

  print("processing image ===============================================================");
  return inputImage;
  // converteddimage=inputImage;
}








  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Face Detector"),
      ),
      body: CameraPreview(controller!)
    );
  }
}
