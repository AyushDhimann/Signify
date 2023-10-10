import 'dart:convert';

import 'package:dropbox_sign/Pages/signing_webview.dart';
import 'package:dropbox_sign/Pages/summary_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:http/http.dart' as http;

class CheckPointsPage extends StatefulWidget {
  final Map<String, dynamic>? decodedJSON;
  const CheckPointsPage({super.key, required this.decodedJSON});

  @override
  State<CheckPointsPage> createState() => _CheckPointsPageState();
}

class _CheckPointsPageState extends State<CheckPointsPage> {
  Map<String, dynamic>? decodedData;

  late List<String> messages = [];

  List<ItemCheck> ?messageWidgets = <ItemCheck>[];

  String? iframeURL;

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
    print(decodedData!['Sign File Path']);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final message = responseData['message'];
        final data = responseData['data'];
        // ignore: avoid_print
        print('Received message: $message');
        // ignore: avoid_print
        print('Received data: $data');
        print('serverurl.split[2]: ${serverURL.split(':')[2]}');
        if(serverURL.split(':')[2] == '5001')
        {
          setState(() {
            iframeURL = data;
            print('iframeURL: $iframeURL');
          });
        }

      } else {
        final errorMessage = response.body.isNotEmpty ? response.body : 'Request failed with status: ${response.statusCode}';
        // ignore: avoid_print
        print('Error: $errorMessage');
      }
  }

  void sendDataToServer() async{
    final Map<String, dynamic> request = {
      'action' : 'Sign',
      'filePath' : decodedData!['Sign File Path'],
    };
    List<String> serverURLs = [
      'http://notology.me:5000',
      'http://notology.me:5001', // returns iframe url
      // 'http://notology.me:5002',
    ]; 
    // serverURLs.map((e) => fetchDataFromServer(e, request));
    fetchDataFromServer(serverURLs[0], request);
    await fetchDataFromServer(serverURLs[1], request);
    // fetchDataFromServer(serverURLs[2], request);
    // ignore: use_build_context_synchronously
    print('send data to server iframe url ; $iframeURL');

    // ignore: use_build_context_synchronously
    await Future.delayed(const Duration(milliseconds: 9 * 755))
      .then((value) => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SigningPage(iframeURL: iframeURL, filePath: decodedData!['Sign File Path'],))
              ));
  }

  void addItemsToList() async{
    for(String message in messages){
      if(mounted){
        setState(() {
          messageWidgets?.add(ItemCheck(message: message));
        });
        await Future.delayed(const Duration(milliseconds: 750));
      }
    }
  }

  final List<String> decodedItems = [
    'File',
    'Security Level',
    'Modification Date',
  ];

  final List<String> decodeTextValueItems = [
    'Empty values',
    'Actual values',
    'Full values',
    'Sentiments',
  ];

  @override
  void initState() {
    decodedData = widget.decodedJSON!;
    for(String i in decodedItems){
      messages.add('$i=${decodedData![i]}');
    }

    for(String j in decodeTextValueItems){
      messages.add('$j=${decodedData!['Text File Values'][j]}');
    }
    messages.add('Taking you to the signing page=@');
    addItemsToList();
    // print(widget.decodedJSON);
    // print(decodedData!['Text File Values']['Empty values']);
    sendDataToServer();
    // ignore: avoid_print
    print('iFrameURL - $iframeURL');

    super.initState();
  }

  final ThemeColors themeColors = ThemeColors(darkMode: true);

  @override
  Widget build(BuildContext context) {
    EdgeInsets devicePadding = MediaQuery.of(context).padding;
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.only(left: 12, right: 12, top: devicePadding.top + 12 + size.height/5),
        child: Align(
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: messageWidgets!,
          ),
        ),
      ),
    );
  }
}

class ItemCheck extends StatefulWidget {
  final String message;
  const ItemCheck({super.key, required this.message});

  @override
  State<ItemCheck> createState() => _ItemCheckState();
}

class _ItemCheckState extends State<ItemCheck> {
  bool isVisible = false;



  @override
  Widget build(BuildContext context) {
    return PlayAnimationBuilder(
      tween: ColorTween(begin: Colors.transparent, end: const Color.fromARGB(255, 235, 235, 235)),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
            return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SizedBox(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.message.split('=')[0],
                  style: TextStyle(
                    color: value,
                    fontSize: 14
                  ),
                ),
                const SizedBox(width: 4,),
                Text(
                  widget.message.split('=')[1] != '@' ?widget.message.split('=')[1] : '',
                  style: TextStyle(
                    color: value,
                    fontWeight: FontWeight.bold,
                    fontSize: 14
                  ),
                ),
                widget.message.split('=')[1] == '@' ?
                Padding(
                  padding: const EdgeInsets.only(left: 6.0),
                  child: CupertinoActivityIndicator(color: value, radius: 8,) 
                ) : const SizedBox()
              ],
            ), 
          ),
        );
      },
    );
  }
}