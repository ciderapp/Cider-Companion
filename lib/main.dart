import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cider_remote/webview.dart';
import 'package:flutter/material.dart';
import 'package:nsd/nsd.dart';

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
      title: 'Cider Remote',
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
        primarySwatch: Colors.pink,
      ),
      darkTheme: _darkTheme,
      home: MyHomePage(title: 'Cider'),
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
  void _scanMDNS() async {
    final discovery = await startDiscovery('_cider-remote._tcp');
    discovery.addListener(() {
      String ip =
          utf8.decode(base64.decode(discovery.services[0].name!.toString()));
      stopDiscovery(discovery).then((_) => {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WebViewScreen(
                        ip: ip,
                      )),
            )
          });
    });
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
            'Scanning Cider Remote instance',
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
