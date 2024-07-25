import 'package:cloud_firestore/cloud_firestore.dart';

class UserSetting {
  String email;
  String id;
  String name;
  String documentID;

  UserSetting(this.email, this.id, this.name);

  UserSetting.fromFireSnapshot(DocumentSnapshot snap)
      : documentID = snap.documentID,
        email = snap.data['email'],
        name = snap.data['name'],
        id = snap.data['id'];

  toJson() {
    return {
      'email': email,
      'name': name,
      'id': id,
    };
  }

  @override
  String toString() {
    return 'UserSetting{email: $email, id: $id, name: $name, documentID: $documentID}';
  }
}
