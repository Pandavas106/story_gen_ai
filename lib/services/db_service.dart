import 'package:cloud_firestore/cloud_firestore.dart';

class DbService {
  static DbService instance = DbService();
  late FirebaseFirestore _db;

  DbService() {
    _db = FirebaseFirestore.instance;
  }

  Future<void> createUserInDB(String uid, String name, String email) async {
    try {
      await _db.collection("EVUsers").doc(uid).set({
        "uid": uid,
        "name": name,
        "email": email,
      });
    } catch (e) {
      print(e);
    }
  }
}
