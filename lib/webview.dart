import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  String ip;
  WebViewScreen({Key? key, required this.ip}) : super(key: key);
  @override
  WebViewExampleState createState() => WebViewExampleState();
}

class WebViewExampleState extends State<WebViewScreen> {
  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    //if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    Fluttertoast.showToast(
        msg: widget.ip.replaceAll("%3", ''),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
    return WillPopScope(
      onWillPop: () async => false,
      child: WebView(
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: (widget.ip.contains("http://") ? "" : "http://") +
            widget.ip.replaceAll("%3", ''),
      ),
    );
  }
}
