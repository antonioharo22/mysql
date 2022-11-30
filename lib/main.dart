import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mysql/logic/models/mysql.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // whenever your initialization is completed, remove the splash screen:

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const MyHomePage(title: 'Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Crea un controlador de texto. Lo usaremos para recuperar el valor actual del TextField!
  final myController = TextEditingController();
  final emailController = TextEditingController();
  final sugerenciaController = TextEditingController();
  @override
  void dispose() {
    // Limpia el controlador cuando el Widget se descarte
    myController.dispose();
    super.dispose();
  }

  int cont = 0;
  var db = new Mysql();
  var result = '';
  var palabra = '';
  var correcion = '';
  void _getCustomer() {
    result = myController.text;
    db.getConnection().then((conn) {
      String sql = 'SELECT palabra, correcion from s4_antonio.Glosario;';
      conn.query(sql).then((results) {
        for (var row in results) {
          setState(() {
            palabra = row[0];
            correcion = row[1];
            result = result.replaceAll(palabra, correcion);
          });
        }
      });
      conn.close();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false, // set it to false
        appBar: AppBar(
          title: Text('Home'),
          backgroundColor: Color.fromARGB(255, 23, 49, 165),
        ),
        body: SingleChildScrollView(
          child: Column(children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10), //apply padding horizontal or vertical only
              child: TextField(
                decoration: const InputDecoration(
                  hintText: "Texto a corregir",
                  border: OutlineInputBorder(),
                ),
                maxLines: 10,
                maxLength: 5000,
                controller: myController,
              ),
            ),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: ElevatedButton(
                  child: Text('Corregir texto'),
                  onPressed: (_getCustomer),
                )),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              width: 350,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  border: Border.all(color: Colors.blueGrey, width: 2.0)),
              child: Text(
                "$result",
                style: TextStyle(fontSize: 15.0),
              ),
            ),
            Container(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                  Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                      child: ElevatedButton(
                        child: Text('Copiar texto'),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: result));
                        },
                      )),
                  Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                      child: ElevatedButton(
                        child: Text('Sugerencias'),
                        onPressed: () {
                          SugerirCorrecion();
                        },
                      )),
                ])),
            Container(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                  Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                      child: ElevatedButton(
                        child: Text('Enviar como email'),
                        onPressed: () async {
                          EnviarComoEmail();
                        },
                      )),
                ])),
          ]),
        ),
        drawer: Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 23, 49, 165),
                ),
                child: Text(''),
              ),

              // ignore: prefer_const_constructors
              AboutListTile(
                // <-- SEE HERE
                icon: const Icon(
                  Icons.info,
                ),
                child: Text('About app'),
                applicationIcon: FlutterLogo(),
                applicationName: 'UCOIncluyente\n',
                applicationVersion: 'Version 0.1',
                applicationLegalese: '© 2022 Company\n',
                aboutBoxChildren: [
                  Text(
                      '\nGlosarios utilizados:\n\n-Lilia D. Tapia Mariscal. "Guia y Glosario"'),
                ],
              ),
            ],
          ),
        ));
  }

  Future SugerirCorrecion() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text('Sugerir Correción'),
            content: SingleChildScrollView(
              child: Column(children: <Widget>[
                Container(
                  //apply padding horizontal or vertical only
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Sugerencia",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 10,
                    maxLength: 500,
                    controller: sugerenciaController,
                  ),
                ),
                Container(
                    child: ElevatedButton(
                  child: Text('Enviar'),
                  onPressed: () async {
                    String recipient = 'ucoincluyente@gmail.com';
                    String date = DateFormat("yyyy-MM-dd hh:mm:ss")
                        .format(DateTime.now());
                    String subject = 'Sugerencia UCOIncluyente ' + date;
                    String body = sugerenciaController.text;

                    final Uri email = Uri(
                      scheme: 'mailto',
                      path: recipient,
                      query: 'subject=' +
                          Uri.encodeComponent(subject) +
                          '&body=' +
                          Uri.encodeComponent(body),
                    );
                    if (await canLaunchUrl(email)) {
                      await launchUrl(email);
                    } else {
                      debugPrint('error');
                    }
                  },
                )),
              ]),
            ),
          ));
  Future EnviarComoEmail() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text('Enviar correción como email'),
            content: SingleChildScrollView(
              child: Column(children: <Widget>[
                Container(child: Text('Correo\n')),
                Container(
                  //apply padding horizontal or vertical only

                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "aaaaa@aaaa.com",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 1,
                    maxLength: 50,
                    controller: emailController,
                  ),
                ),
                Container(
                    child: ElevatedButton(
                  child: Text('Enviar'),
                  onPressed: () async {
                    String recipient = emailController.text;
                    String date = DateFormat("yyyy-MM-dd hh:mm:ss")
                        .format(DateTime.now());
                    String subject = 'Correción UCOIncluyente ' + date;
                    String body = result + '\n\nUCOIncluyente by Flutter';

                    final Uri email = Uri(
                      scheme: 'mailto',
                      path: recipient,
                      query: 'subject=' +
                          Uri.encodeComponent(subject) +
                          '&body=' +
                          Uri.encodeComponent(body),
                    );
                    if (await canLaunchUrl(email)) {
                      await launchUrl(email);
                    } else {
                      debugPrint('error');
                    }
                  },
                )),
              ]),
            ),
          ));
}
