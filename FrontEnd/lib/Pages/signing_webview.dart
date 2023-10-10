import 'dart:convert';

import 'package:dropbox_sign/Pages/sharingpage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class SigningPage extends StatefulWidget {
  final String? iframeURL;
  final String? filePath;
  const SigningPage({super.key, required this.iframeURL, required this.filePath});

  @override
  State<SigningPage> createState() => _SigningPageState();
}

class _SigningPageState extends State<SigningPage> {
  late final WebViewController webViewController;
  bool loading = false;
  bool downloadLinkRec = false;
  String? downloadLink;
  @override
  void initState() {
    print('signing page : ${widget.iframeURL}');
    webViewController = WebViewController()
    ..clearLocalStorage()
    ..clearCache()
    ..loadRequest(
      Uri.dataFromString('''
        <html>
          <body>
            <iframe 
            src="${widget.iframeURL}"
            style="width:100%;height:100%;scrolling="no";top:0;left:0;right:0:bottom:0;position:absolute;">
            </iframe>
          </body>
        </html>
      ''', 
      mimeType: 'text/html')
      // Uri.parse('http://143.244.158.53/lol.html')
      // Uri.https('143.244.158.53.html', '/lol')
    )
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..enableZoom(false)
    ;
    sendRequest();
    super.initState();
  } 
  
  Future<void> fetchDataFromServer(String serverURL, Map<String, dynamic> requestData) async {
    final response = await(
      http.post(
        Uri.parse('$serverURL/sign'),
        headers: <String, String>{
          'Content-Type' : 'application/json'
        },
        body: jsonEncode(requestData)
      )
    );
    if(response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final message = responseData['message'];
      final data = responseData['data'];
              // ignore: avoid_print
      print('Received message: $message');
      // ignore: avoid_print
      print('Received data: $data');

      if(serverURL.split(':')[2] == '5002'){
        setState(() {
          downloadLink = data;
        print('downloadLink : $downloadLink');
        });
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => SharingPage(downloadLink: downloadLink),)
        );
      }   
      if(serverURL.split(':')[2] == '5003'){
        print('loading started :::');
        setState(() {
          loading = true;
        });
      }   
    } else{
      final errorMessage = response.body.isNotEmpty ? response.body : 'Request failed with status: ${response.statusCode}';
      // ignore: avoid_print
      print('Error: $errorMessage');
    }
  }

  void sendRequest() async{
    final Map<String, dynamic> request = {
    'action' : 'Sign',
    'filePath' : widget.filePath,
    };
    List<String> serverURLs = [
      'http://notology.me:5003', // for confirmation
      'http://notology.me:5002' // for download link
    ];

    fetchDataFromServer(serverURLs[0], request);
    fetchDataFromServer(serverURLs[1], request);
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets devicePadding = MediaQuery.of(context).padding;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 0,
        // actions: [
        //   WebViewNavigationBar(webViewController: webViewController)
        // ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: devicePadding.bottom),
            child: WebViewWidget(
              controller: webViewController,
            ),
          ),
        ],
      ),
    );
  }
}

class WebViewNavigationBar extends StatelessWidget {
  final WebViewController webViewController;
  const WebViewNavigationBar({super.key, required this.webViewController});

  goBackFunction() async{
    if(await webViewController.canGoBack()){
      webViewController.goBack();
    }
  }
  goForwardFunction() async{
    if(await webViewController.canGoForward()){
      webViewController.goForward();
    }
  }
  @override
  Widget build(BuildContext context) {
    EdgeInsets devicePadding = MediaQuery.of(context).padding;
    Size size = MediaQuery.of(context).size;
    return Container(
      // height: 50 + devicePadding.top,
      height: 50,
      width: size.width,
      padding: EdgeInsets.only(left: 12, right: 12, bottom: 12, top: devicePadding.top),
      color: Colors.white,
      child: Row(
        children: [
          WebViewNavigationButton(icon: Icons.cancel_outlined, function: (){}, colored: true),
          const Expanded(child: SizedBox()),
          Container(
            decoration: const BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.all(Radius.circular(12))
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
              WebViewNavigationButton(icon: Icons.arrow_back, function: goBackFunction, colored: false,),
              Container(height: 20, width: 1, color: Colors.grey,),
              WebViewNavigationButton(icon: Icons.arrow_forward, function: goForwardFunction, colored: false,),
              ],
            ),
          ),
          const SizedBox(width: 7,),
          WebViewNavigationButton(icon: Icons.refresh, function: webViewController.reload,colored: true,),
        ],
      ),
    );
  }
}

class WebViewNavigationButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback function;
  final bool colored;
  const WebViewNavigationButton({super.key, required this.icon, required this.function, required this.colored});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        onTap: function,
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: colored ? Colors.black12 : Colors.transparent,
            borderRadius: const BorderRadius.all(Radius.circular(12))
          ),
          child: Icon(icon, color: Colors.black,),

        ),
      ),
    );
  }
}