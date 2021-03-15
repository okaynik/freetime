import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth.dart';

class DatabaseService {

  final String uid;
  DatabaseService({ this.uid});

  Future updateUserData(String email, String name, eventList) async {
    final CollectionReference userCollection = Firestore.instance.collection(
        'users');
    await getEventList();
    return;
  }

  Future updateUserEvents(email, name, eventList) async {
    final CollectionReference userCollection = Firestore.instance.collection(
        'users');
    return await userCollection.document(uid).setData({"email": email, "name": name, "events": eventList});
  }
}

