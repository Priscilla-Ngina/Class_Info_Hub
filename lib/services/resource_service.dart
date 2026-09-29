import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResourceService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> uploadResource({
    required String classId,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    final user = FirebaseAuth.instance.currentUser!;

    final filePath =
        'classes/$classId/resources/$fileName';

    await supabase.storage
        .from('class-resources')
        .uploadBinary(
      filePath,
      fileBytes,
      fileOptions: const FileOptions(
        upsert: false,
      ),
    );

    final downloadUrl = supabase.storage
        .from('class-resources')
        .getPublicUrl(filePath);

    await firestore
        .collection('classes')
        .doc(classId)
        .collection('resources')
        .add({
      'fileName': fileName,
      'fileUrl': downloadUrl,
      'storagePath': filePath,
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

  Future<void> deleteResource({
    required String classId,
    required String resourceId,
    required String storagePath,
  }) async {
    // Delete the actual file from Supabase Storage.
    await supabase.storage
        .from('class-resources')
        .remove([
      storagePath,
    ]);

    // Delete the resource record from Firestore.
    await firestore
        .collection('classes')
        .doc(classId)
        .collection('resources')
        .doc(resourceId)
        .delete();
  }
}