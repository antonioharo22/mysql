import 'package:mysql1/mysql1.dart';

class Mysql {
  static String host = '91.200.100.51',
      user = 'u4_ueHRu5IDq9',
      password = 'vbFl+C1AblfRf0Us0bu=V6F@';
  static int port = 3306;

  Mysql();

  Future<MySqlConnection> getConnection() async {
    var settings = new ConnectionSettings(
        host: host, port: port, user: user, password: password);
    return await MySqlConnection.connect(settings);
  }
}
