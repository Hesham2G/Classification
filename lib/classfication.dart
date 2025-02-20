import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class Classfication extends StatefulWidget {
  const Classfication({super.key});

  @override
  State<Classfication> createState() => _ClassficationState();
}

class _ClassficationState extends State<Classfication> {
  File? image;
  late ImagePicker imagePicker;
  late ImageLabeler labeler;
  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
    ImageLabelerOptions options = ImageLabelerOptions(confidenceThreshold: 0.6);
    labeler = ImageLabeler(options: options);
  }

  chooseImage() async {
    XFile? selectedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      image = File(selectedImage.path);
      performImageLabeling();
      setState(() {
        image;
      });
    }
  }

  captureImage() async {
    XFile? selectedImage =
        await imagePicker.pickImage(source: ImageSource.camera);
    if (selectedImage != null) {
      image = File(selectedImage.path);
      performImageLabeling();
      setState(() {
        image;
      });
    }
  }

  String results = "";
  performImageLabeling() async {
    results = "";

    InputImage inputImage = InputImage.fromFile(image!);

    final List<ImageLabel> labels = await labeler.processImage(inputImage);

    for (ImageLabel label in labels) {
      final String text = label.label;
      final int index = label.index;
      final double confidence = label.confidence;
      print(text + "  " + confidence.toString());
      results += text + "  " + confidence.toStringAsFixed(2) + "\n";
    }

    setState(() {
      results;
    });
  }
 
   
   loadModel()async{
    final interpreter = await Interpreter.fromAsset('assets/ml/model.tflite');
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Classfication'),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                color: Colors.grey[200],
                margin: EdgeInsets.all(10),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 2,
                  child: image == null
                      ? Icon(
                          Icons.image_outlined,
                          size: 150,
                        )
                      : Image.file(image!),
                ),
              ),
              Card(
                margin: EdgeInsets.all(10),
                color: Colors.indigo,
                child: Container(
                  height: 100,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InkWell(
                        child: Icon(
                          Icons.image,
                          size: 50,
                        ),
                        onTap: () {
                          chooseImage();
                        },
                      ),
                      InkWell(
                        child: Icon(
                          Icons.camera_alt,
                          size: 50,
                        ),
                        onTap: () {
                          captureImage();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                  child: Container(
                    
                child: Text(results,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(10),
              ),
              margin: EdgeInsets.all(10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
