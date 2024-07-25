import 'dart:io';

class SocketClient {
  static Socket socket;
  static Socket socketParameters;
  String ipAddress;
  int port;

  SocketClient(String ipAddress, int port) {
    this.ipAddress = ipAddress;
    this.port = port;
    connectToServer1();
    connectToServer2();
  }

  Future<void> connectToServer1() async {
    Socket.connect(this.ipAddress, this.port).then((Socket sock) {
      socket = sock;
    });
  }

  Future<void> connectToServer2() async {
    Socket.connect(this.ipAddress, this.port).then((Socket sock) {
      socketParameters = sock;
    });
  }

  static String dataHandlerVoice() {
    socketParameters.listen((data){
      return data;
    });
    return '';
  }

  static String dataHandler() {
    socketParameters.listen((data){
      return data;
    });
    return '';
  }

  static String errorHandler(error, StackTrace trace) {
    return error;
  }

  static String errorHandlerVoice(error, StackTrace trace) {
    return error;
  }

  static void doneHandlerVoice() {
    socket.destroy();
  }

  static void doneHandler() {
    socketParameters.destroy();
  }
}
