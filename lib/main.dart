import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: const ImageAnnotationApp(title: "Image Captioner"),
    );
  }
}

class ImageAnnotationApp extends StatefulWidget {
  const ImageAnnotationApp({super.key, required this.title});
  final String title;

  @override
  ImageAnnotationAppState createState() => ImageAnnotationAppState();
}

class ImageAnnotationAppState extends State<ImageAnnotationApp> {
  List<File> imageFiles = [];
  int currentImageIndex = 0;
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    requestStoragePermission();
  }

  Future<void> requestStoragePermission() async {
    final PermissionStatus status = await Permission.manageExternalStorage.request();
    if (status.isGranted) {
      getImagesFromDirectory();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> getImagesFromDirectory() async {
    final String? sourcePath = await FilePicker.platform.getDirectoryPath();
    //print("Source path: ${sourcePath}");
    if (sourcePath != null) {
      final Directory directory = Directory(sourcePath);
      List<FileSystemEntity> files = directory.listSync(recursive: false, followLinks: false);
      //print("Files: ${files}");
      List<File> selectedFiles = [];
      List<String> imageExtensions = ['.jpg', '.jpeg', '.png'];

      //print("A: For loop");
      for (FileSystemEntity file in files) {
        //print("B: ${file}");
        if (file is File) {
          //print("C: true");
          String extension = path.extension(file.path.toString()).toLowerCase();
          //print("D: Extension: $extension");
          if (imageExtensions.contains(extension)) {
            //print("E: true");
            selectedFiles.add(file);
          }
        }
      }
      //print("Selected files: ${selectedFiles}");
      if (selectedFiles.isNotEmpty) {
        setState(() {
          imageFiles = selectedFiles;
          currentImageIndex = 0;
        });
        loadTextFromFile(imageFiles[currentImageIndex].path).then((text) {
          textController.text = text ?? '';
        });
      }
    }
  }

  Future<void> saveTextToFile(String text, String imagePath) async {
    String fileName = path.basename(imagePath);
    String extension = path.extension(imagePath);
    String fileNameFixed = fileName.replaceAll(RegExp("$extension\$"), ".txt");
    String imageDirectory = path.dirname(imagePath);
    String textFilePath = path.join(imageDirectory, fileNameFixed);
    //print("Saving Text file: $textFilePath");
    File textFile = File(textFilePath);
    textFile.writeAsStringSync(text, mode: FileMode.write);
  }

  Future<String?> loadTextFromFile(String imagePath) async {
    String fileName = path.basename(imagePath);
    String imageDirectory = path.dirname(imagePath);
    String extension = path.extension(imagePath);
    String fileNameFixed = fileName.replaceAll(RegExp("$extension\$"), ".txt");
    String textFilePath = path.join(imageDirectory, fileNameFixed);
    File textFile = File(textFilePath);
    if (textFile.existsSync()) {
      return textFile.readAsStringSync();
    }
    return null;
  }

  void showNextImage() {
    if (currentImageIndex + 1 < imageFiles.length) {
      setState(() {
        currentImageIndex++;
        textController.clear();
      });
      loadTextFromFile(imageFiles[currentImageIndex].path).then((text) {
        textController.text = text ?? '';
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("All images have been processed!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  void showPreviousImage() {
    if (currentImageIndex - 1 >= 0) {
      setState(() {
        currentImageIndex--;
        textController.clear();
      });
      loadTextFromFile(imageFiles[currentImageIndex].path).then((text) {
        textController.text = text ?? '';
      });
    }
  }

  void goBackToFilePicker() {
    setState(() {
      imageFiles.clear();
      currentImageIndex = 0;
    });
    getImagesFromDirectory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Captioner"),
      ),
      body: imageFiles.isEmpty
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                "No image files found.\nPlease select a directory containing images."),
            ElevatedButton(
              onPressed: () {
                getImagesFromDirectory();
              },
              child: const Text("Retry"),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            child: Image.file(
              imageFiles[currentImageIndex],
              fit: BoxFit.contain,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: "Enter captions for this image:",
              ),
              maxLines: null, // Allow the input to wrap around when it flows past the edge of the screen.
              keyboardType: TextInputType.text,
              onSubmitted: (text) {
                saveTextToFile(text, imageFiles[currentImageIndex].path);
                showNextImage();
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  showPreviousImage();
                },
                child: const Text("Previous"),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  goBackToFilePicker();
                },
                child: const Text("Home"),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  saveTextToFile(textController.text, imageFiles[currentImageIndex].path);
                  showNextImage();
                },
                child: const Text("Next"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
