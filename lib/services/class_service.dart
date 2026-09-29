import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClassService {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> createClass({
    required String programme,
    required String year,
    required String classCode,
  }) async {
    final user = FirebaseAuth.instance.currentUser!;

    final classDocument =
    await firestore.collection('classes').add({
      'programme': programme,
      'year': year,
      'classCode': classCode,
      'createdBy': user.uid,
    });

    await firestore
        .collection('classes')
        .doc(classDocument.id)
        .collection('members')
        .doc(user.uid)
        .set({
      'userId': user.uid,
      'joinedAt': FieldValue.serverTimestamp(),
    });
  }
  Future<QuerySnapshot> findClassByCode(String classCode) async {
    return await firestore
        .collection('classes')
        .where('classCode', isEqualTo: classCode)
        .get();
  }

  Future<void> joinClass(String classId) async {
    final user = FirebaseAuth.instance.currentUser!;

    await firestore
        .collection('classes')
        .doc(classId)
        .collection('members')
        .doc(user.uid)
        .set({
      'userId': user.uid,
      'joinedAt': FieldValue.serverTimestamp(),
    });
  }
  Future<QuerySnapshot> getMyMemberships() async {
    final user = FirebaseAuth.instance.currentUser!;

    return await firestore
        .collectionGroup('members')
        .where('userId', isEqualTo: user.uid)
        .get();
  }

  Future<bool> isClassManager(String classId) async {
    final user = FirebaseAuth.instance.currentUser!;

    final classDocument =
    await firestore.collection('classes').doc(classId).get();

    if (!classDocument.exists) {
      return false;
    }

    final data = classDocument.data()!;

    return data['createdBy'] == user.uid;
  }

  Future<String?> getClassCode(String classId) async {
    final classDocument =
    await firestore.collection('classes').doc(classId).get();

    if (!classDocument.exists) {
      return null;
    }

    final data = classDocument.data()!;

    return data['classCode'];
  }

}