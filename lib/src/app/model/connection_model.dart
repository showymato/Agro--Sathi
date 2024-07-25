import 'package:cloud_firestore/cloud_firestore.dart';

class ConnectionModel {
  String id;
  String connectionModel;
  String connectionType;
  String connectionHost;
  int connectionPort;

  ConnectionModel(this.id, this.connectionModel, this.connectionType,
      this.connectionHost, this.connectionPort);

  ConnectionModel.fromFireSnapshot(DocumentSnapshot snap)
      : connectionModel = snap.data['model'],
        connectionType = snap.data['type'],
        connectionHost = snap.data['host'],
        connectionPort = snap.data['port'],
        id = snap.data['id'];

  toJson() {
    return {
      'model': connectionModel,
      'type': connectionType,
      'host': connectionHost,
      'port': String.fromCharCode(connectionPort),
      'id': id,
    };
  }

  @override
  String toString() {
    return 'ConnectionModel{id: $id, connectionModel: $connectionModel, connectionType: $connectionType, connectionHost: $connectionHost, connectionPort: $connectionPort}';
  }
}
