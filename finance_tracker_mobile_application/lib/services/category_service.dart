import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryService {
  final _db = FirebaseFirestore.instance;

  Stream<Map<String, bool>> watchCategoryTypes(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('settings')
        .doc('categoryTypes')
        .snapshots()
        .map((snap) {
      if (!snap.exists || snap.data() == null) return <String, bool>{};
      return Map<String, bool>.from(
        snap.data()!.map((k, v) => MapEntry(k, v as bool)),
      );
    });
  }

  Future<void> setCategoryType(
      String uid, String category, bool isEssential) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('settings')
        .doc('categoryTypes')
        .set({category: isEssential}, SetOptions(merge: true));
  }
}
