import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ResourceService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<void> uploadResource({
    required String classId,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    final user = FirebaseAuth.instance.currentUser!;

    final storageReference = storage
        .ref()
        .child('classes')
        .child(classId)
        .child('resources')
        .child(fileName);

    await storageReference.putData(fileBytes);

    final downloadUrl = await storageReference.getDownloadURL();

    await firestore
        .collection('classes')
        .doc(classId)
        .collection('resources')
        .add({
      'fileName': fileName,
      'fileUrl': downloadUrl,
      'uploadedBy': user.uid,
      'uploadedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<QuerySnapshot> getResources(String classId) async {
    return await firestore
        .collection('classes')
        .doc(classId)
        .collection('resources')
        .orderBy('uploadedAt', descending: true)
        .get();
  }
}