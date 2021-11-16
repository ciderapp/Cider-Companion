import 'dart:convert';

import 'package:ame_remote/webview.dart';
import 'package:flutter/material.dart';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:convert/convert.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ThemeData _darkTheme = ThemeData(
      brightness: Brightness.dark,
      hintColor: Colors.grey[400],
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Color(0xFFFAFAFA),
        selectionColor: Color(0x55FFFFFF),
        selectionHandleColor: Color(0xFFFAFAFA),
      ),
      scaffoldBackgroundColor: Colors.black,
    );
    return MaterialApp(
      title: 'AME Remote',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      darkTheme: _darkTheme,
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int _counter = 0;

  void _incrementCounter() {}

  void _scanMDNS() async {
    const String name = '_ame-lg-client._tcp.local';
    final MDnsClient client = MDnsClient();
    // Start the client with default options.
    await client.start();

    // Get the PTR record for the service.
    await for (final PtrResourceRecord ptr in client
        .lookup<PtrResourceRecord>(ResourceRecordQuery.serverPointer(name))) {
      // Use the domainName from the PTR record to get the SRV record,
      // which will have the port and local hostname.
      // Note that duplicate messages may come through, especially if any
      // other mDNS queries are running elsewhere on the machine.
      try {
        await for (final SrvResourceRecord srv
            in client.lookup<SrvResourceRecord>(
                ResourceRecordQuery.service(ptr.domainName))) {
          final String bundleId = ptr.domainName;
          String ip =
              utf8.decode(base64.decode(srv.name.replaceAll("." + name, ''))) +
                  ":8090";

          print('Web Remote found at: ' + ip);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WebViewScreen(
                      ip: ip,
                    )),
          );
          client.stop();
        }
      } catch (e) {}
    }
  }

  late AnimationController animationController;
  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
  }

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: new Duration(seconds: 2), vsync: this);
    animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    _scanMDNS();
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Scanning Apple Music Electron Remote instance',
          ),
          Container(height: 20),
          CircularProgressIndicator(
            valueColor: animationController
                .drive(ColorTween(begin: Colors.blueAccent, end: Colors.red)),
          ),
        ],
      ),
    ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
