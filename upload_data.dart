import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class UploadDataPage extends StatefulWidget {
  const UploadDataPage({Key? key}) : super(key: key);

  @override
  State<UploadDataPage> createState() => _UploadDataPageState();
}

class _UploadDataPageState extends State<UploadDataPage> {
  final picker = ImagePicker();

  File? imageFile;
  String imageName = '';
  String imageUrl = '';

  void _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
        imageName = pickedFile.name;
      });
      _showImage();
    }
  }

  _showImage() {
    if (imageFile == null) {
      return Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          height: 300,
          color: Colors.grey.shade200,
          child: const Text('Image not found!'));
    } else if (imageFile != null) {
      return InkWell(
        onTap: () {
          _pickImage();
        },
        child: imageUrl == ''
            ? Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                height: 300,
                color: Colors.grey.shade100,
                child: Image.file(imageFile!, fit: BoxFit.fitWidth),
              )
            : Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                height: 300,
                color: Colors.grey.shade100,
                child: Image.network(imageUrl, fit: BoxFit.fitWidth),
              ),
      );
    }
  }

  void _uploadImage(File localFile, imageName) async {
    final firebaseStorageRef =
        FirebaseStorage.instance.ref().child('products/images/$imageName');

    await firebaseStorageRef.putFile(localFile).whenComplete(() async {
      String url = await firebaseStorageRef.getDownloadURL();
      setState(() {
        imageUrl = url;
      });
      upload();
    });
  }

  final TextEditingController _controller = TextEditingController();
  void upload() async {
    var docReference = FirebaseFirestore.instance.collection('products').doc();
    await docReference.set({
      'title': _controller.text,
      'image': imageUrl,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1.5,
        backgroundColor: Color.fromARGB(255, 246, 181, 82),
        title: const Text('UPLOAD IMAGE'),
      ),
      body: Container(
        margin: const EdgeInsets.all(25.0),
        child: ListView(
          children: [
            const SizedBox(height: 20.0),
            TextField(
              controller: _controller,
              onChanged: (v) {
                setState(() {});
              },
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            const SizedBox(height: 20.0),
            _showImage(),
            const SizedBox(height: 20.0),
            imageFile == null
                ? ElevatedButton(
                    onPressed: () {
                      _pickImage();
                    },
                    child: const Text('PICK IMAGE'))
                : ElevatedButton(
                    onPressed: () {
                      _uploadImage(imageFile!, imageName);
                    },
                    child: const Text('UPLOAD IMAGE')),
          ],
        ),
      ),
    );
  }
}
