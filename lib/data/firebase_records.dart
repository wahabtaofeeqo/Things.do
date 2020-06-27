import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mytodo/user.dart';

class FirebaseRecords {

  static final _db = Firestore.instance;

  Future<bool> emailExists(email) async {

    try {
      var ref = _db.collection("users");
      var doc = ref.document(email);
      if(doc != null)
        return true;
    }
    catch(e) {
      print("Error");
    }
    return false;
  }

  Future<bool> addUser(User user, String email) async {
    try {
      var ref = _db.collection("users");
      await ref.document(email).setData(user.toMap());
      return true;
    }
    catch(e) {
      print(e);
    }
    return false;
  }

  login(email, password) async {
    try {
      var ref = _db.collection("users");
      var docs = await ref.where("email", isEqualTo: email).getDocuments();
      return docs.documents.first.data;
    }
    catch(e) {}
    return null;
  }
}