import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class ConnectionCrud {
  final db = Firestore.instance;
  static bool check = true;

  Future<bool> getConnectionById(String uid) async {
    return await Firestore.instance
        .collection('connections')
        .where('id', isEqualTo: uid)
        .getDocuments()
        .then((value) => value.documents.isEmpty ? true : false);
  }

  void updateConnection(String uid, ConnectionModel connection) {
    try {
      db
          .collection("connections")
          .document(uid)
          .setData({
        'id': connection.id,
        'model': connection.connectionModel,
        'type': connection.connectionType,
        'host': connection.connectionHost,
        'port': connection.connectionPort,
      })
          .then((documentReference) {})
          .catchError((e) {
        print(e);
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<ConnectionModel> getConnectionModel(String uid) async {
    return await db.
    collection('connections').
    where('id', isEqualTo: uid).
    getDocuments()
        .then((value) =>
    value.documents.isNotEmpty ? new ConnectionModel(
        value.documents[0].data['id'], value.documents[0].data['model'],
        value.documents[0].data['type'],
        value.documents[0].data['host'], value.documents[0].data['port']) : new ConnectionModel('', '', '', '', 0));
  }

  Future<bool> deleteConnectionSetting(ConnectionModel connectionModel) async {
    if (connectionModel != null) {
      db.collection('connections').document(connectionModel.id).delete();
    }

    return Future.value(true);
  }

  Future<void> getConnectionSetting(String uid) async {
    var query = db.collection('connections').getDocuments();
    await query.then((snap) {
      if (snap.documents.length > 0) {
        for (var doc in snap.documents) {
          if (ConnectionModel.fromFireSnapshot(doc).id == uid) {
            print("here");
            check = false;
          }
        }
      }
    });
    print(check);
  }

  Future<void> addConnection(ConnectionModel connection) async {
    db
        .collection("connections")
        .add({
          'id': connection.id,
          'model': connection.connectionModel,
          'type': connection.connectionType,
          'host': connection.connectionHost,
          'port': connection.connectionPort,
        })
        .then((documentReference) {})
        .catchError((e) {
          print(e);
        });
  }

  Future<void> editConnection(
      ConnectionModel connection, DocumentSnapshot doc) async {
    await db
        .collection("connections")
        .document(doc.documentID)
        .updateData({
          'id': connection.id,
          'model': connection.connectionModel,
          'type': connection.connectionType,
          'host': connection.connectionHost,
          'port': connection.connectionPort,
        })
        .then((documentReference) {})
        .catchError((e) {
          print(e);
        });
  }

  Future<void> deleteConnection(DocumentSnapshot doc) async {
    db.collection("connections").document(doc.documentID).delete();
  }

  Future<void> deleteAll() async {
    db.collection("connections").document().delete();
  }

  getAllData() async {
    return await db.collection('connections').getDocuments();
  }

  ConnectionModel getSingleConnectionSettings(String id) {
    ConnectionModel connectionModel;
    getAllData().getData().then((results) {
      if (results['id'] == id) connectionModel = results;
    });
    return connectionModel;
  }

  List<ConnectionModel> getConnectionSettings() {
    List<ConnectionModel> userSettings;
    getAllData().getData().then((results) {
      userSettings = results;
    });
    return userSettings;
  }

  /*ConnectionModel getConnectionById(String uuid) {
    ConnectionModel cn;
    String connectionModel;
    String connectionType;
    String connectionHost;
    int connectionPort;
    bool get = false;
    int count = 0;
    db.collection("connections").getDocuments().then((querySnapshot) {
      querySnapshot.documents.forEach((result) {
        result.data.forEach((key, value) {
          if (value == uuid)
            ++count;
          if (count != 0 && count <= 5) {
            if (count == 2)
              connectionModel = value;
            else if (count == 3)
              connectionType = value;
            else if (count == 4)
              connectionHost = value;
            else if (count == 5) {
              connectionPort = int.parse(value);
              cn = new ConnectionModel(uuid, connectionModel, connectionType, connectionHost, connectionPort, do);
              get = true;
            }
            ++count;
          }
        });
      });
    });
    if (get == true)
    return cn;
    return null;
  }*/

  bool checkConnection(String uid) {
    print(uid);
    bool check = false;
    db.collection("connections").getDocuments().then((querySnapshot) {
      querySnapshot.documents.forEach((result) {
        result.data.forEach((key, value) {
          print(value);
          if (value == uid) {
            print(value);
            check = true;
            print(uid);
          }
        });
      });
    });
    return check;
  }
}
