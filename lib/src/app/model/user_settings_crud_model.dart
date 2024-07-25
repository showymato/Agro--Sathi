import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drone_s500/src/app/model/user_settings_model.dart';

class UserSettingCrud {
  final db = Firestore.instance;
  UserSetting userSetting;
  static bool check = true;

  getUserById(String email, String uid, String name) {
    return Firestore.instance
        .collection('users')
        .where('id', isEqualTo: uid)
        .getDocuments()
        .then((value) {
      if (value.documents.isEmpty) {
        addUserSetting(new UserSetting(email, uid, name));
      }
    });
  }

  Future<void> addUserSetting(UserSetting user) async {
    await db
        .collection("users")
        .add({
          'email': user.email,
          'id': user.id,
          'name': user.name,
        })
        .then((documentReference) {})
        .catchError((e) {
          print(e);
        });
  }

  Future<bool> editUserSetting(
      UserSetting userSetting, DocumentSnapshot doc) async {
    if (userSetting != null) {
      await db
          .collection("users")
          .document(doc.documentID)
          .updateData({
            'id': userSetting.id,
            'name': userSetting.name,
            'age': userSetting.email,
          })
          .then((documentReference) {})
          .catchError((e) {
            print(e);
          });
    }

    return Future.value(true);
  }

  Future<bool> deleteUserSetting(UserSetting userSetting) async {
    if (userSetting != null) {
      db.collection('users').document(userSetting.documentID).delete();
    }

    return Future.value(true);
  }

  Future<void> getUserSetting(String uid) async {
    var query = db.collection('users').getDocuments();
    await query.then((snap) {
      if (snap.documents.length > 0) {
        for (var doc in snap.documents) {
          print(UserSetting.fromFireSnapshot(doc).id);
        }
      }
    });
  }

  getAllData() async {
    return await db.collection('connections').getDocuments();
  }

  void getConnectionSettings() {
    getAllData().getData().then((results) {
      // ignore: unnecessary_statements
      results.data;
    });
  }

  bool findUserSetting(String uid) {
    getUserSetting(uid);
    return check;
  }
}
