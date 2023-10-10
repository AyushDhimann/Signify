import 'dart:ui';
import 'dart:convert';
// import 'package:dropbox_sign/Pages/checkpoints.dart';
// import 'package:dropbox_sign/Pages/signing_webview.dart';
// import 'package:dropbox_sign/Pages/upload_page.dart';
import 'package:dropbox_sign/Pages/checkpoints.dart';
// import 'package:dropbox_sign/Pages/signing_webview.dart';
// import 'package:dropbox_sign/Pages/upload_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:local_auth/local_auth.dart';
// import 'package:local_auth_android/local_auth_android.dart';
// import 'package:local_auth_ios/local_auth_ios.dart';
// import 'package:simple_animations/simple_animations.dart';

// import '../Services/services.dart';

class SummaryPage extends StatefulWidget {
  final String? fileName;
  const SummaryPage({super.key, required this.fileName}); 

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {

  String reversedFileName(String filename) 
    => filename.split('').reversed.join();

  String serverUrl = 'http://notology.me:4000';

  String? summaryDoc;
  Map<String, dynamic>? decodedJSON;

  Future getSummary() async{
    // await Future.delayed(const Duration(seconds: 2));
    final Uri fileUri = Uri.parse('$serverUrl/download/process2-${reversedFileName(widget.fileName!)}');
    final jsonData = await http.get(fileUri);
    Map<String, dynamic> dJSON = jsonDecode(jsonData.body);
    if(mounted) {
      setState(() {
        decodedJSON = dJSON;
        summaryDoc = dJSON['Summary'];
      });
    }
    // ignore: avoid_print
    print(summaryDoc);
  }
  @override
  void initState() {
    getSummary();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
  double fontSize = 16;

  void increasefontSize(){
    setState(() {
      fontSize += fontSize < 101 ? 2 : 0;
    });
  }

  void decreasefontSize(){
    setState(() {
      fontSize -= fontSize > 5 ? 2 : 0;
    });
  }

  bool darkMode = true;
  void changeColorMode(){
    setState(() {
      darkMode = !darkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeColors themeColors = ThemeColors(darkMode: darkMode);
    EdgeInsets devicePadding = MediaQuery.of(context).padding;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 700),
      color: themeColors.backgroundColor,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.transparent,
        body: BlurryAppBar(
          increasefontSize: increasefontSize,
          decreasefontSize: decreasefontSize,
          changeColorMode: changeColorMode,
          themeColors: themeColors,
          decodedJSON: decodedJSON,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: ListView(
              padding: const EdgeInsets.all(0),
              physics: const BouncingScrollPhysics(),
              children: [
                SizedBox(height: devicePadding.top + 12 + 40 + 15 + 10,),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Overview',
                    style: TextStyle(
                      color: themeColors.mainTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                Text(
                  'Given below is an AI generated summary of the document you\'ve uploaded!',
                  style: TextStyle(color: themeColors.subTextColor, fontSize: 12),
                  ),
                const SizedBox(height: 10,),
                summaryDoc !=null ?
                  SelectableText(
                    summaryDoc!,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontFamily: 'Times New Roman',
                      color: themeColors.mainTextColor,
                      // fontWeight: FontWeight.bold
                    ),
                  ) 
                    : const CupertinoActivityIndicator(color: Colors.white, radius: 10,),
                const SizedBox(height: 15,),
              ],
            ),
          ),
        ),
      // floatingActionButton: BottomButtons(themeColors: themeColors,),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}

class BlurryAppBar extends StatelessWidget {
  final Widget child;
  final VoidCallback increasefontSize;
  final VoidCallback decreasefontSize;
  final VoidCallback changeColorMode;
  final ThemeColors themeColors;
  final Map<String, dynamic>? decodedJSON;
  const BlurryAppBar({super.key, required this.child, required this.increasefontSize, required this.decreasefontSize, required this.changeColorMode, required this.themeColors, required this.decodedJSON});
  @override
  Widget build(BuildContext context) {
    EdgeInsets devicePadding = MediaQuery.of(context).padding;
    return Stack(
      children: [
        child,
        ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2000, sigmaY: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              width: double.infinity,
              height: devicePadding.top + 12 + 40 + 15,
              padding: EdgeInsets.only(top: devicePadding.top + 12, bottom: 15, left: 12, right: 12),
              color: themeColors.topAppBarColor,
              child: Row(
                children: [
                  TopButton(icon: Icons.arrow_back, function: () => Navigator.pop(context), themeColors: themeColors,),
                  const Expanded(child: SizedBox()),
                  TopButton(icon: themeColors.colorModeIcon, function: changeColorMode, themeColors: themeColors,),
                  const SizedBox(width: 8,),
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      color: themeColors.defaultButtonColor
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      TopButton(icon: Icons.remove, function: decreasefontSize,themeColors: themeColors),
                      Container(height: 22, color: Colors.grey, width: 1),
                      TopButton(icon: Icons.add, function: increasefontSize,themeColors: themeColors,)
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: BottomButtons(
            themeColors: themeColors,
            ccontext: context,
            decodedJSON: decodedJSON,
            filePath: decodedJSON?['Sign File Path']??'',
          )
        )
      ],
    );
  }
}

class TopButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback function;
  final ThemeColors themeColors;
  const TopButton({super.key, required this.icon, required this.function, required this.themeColors});

  @override
  State<TopButton> createState() => _TopButtonState();
}

class _TopButtonState extends State<TopButton> {
  bool isPressed = false;
  Color setColor(){
    return isPressed ? widget.themeColors.pressedButtonColor : widget.themeColors.defaultButtonColor;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.function,
      onTapDown: (details) => setState(() {isPressed = true;}),
      onTapUp: (details) => setState(() {isPressed = false;}),
      onTapCancel: () => setState(() {isPressed = false;}),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 700),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: widget.themeColors.defaultButtonColor,
            borderRadius: const BorderRadius.all(Radius.circular(15))
          ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(3),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: setColor(),
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          child: Icon(widget.icon,color: widget.themeColors.iconColor,),
        ),
      ),
    );
  }
}


class ThemeColors{
  final bool darkMode;
  ThemeColors({
    required this.darkMode
  });

  late bool isDarkMode = darkMode;
  late Color backgroundColor = darkMode ?Colors.black : Colors.white;
  late Color mainTextColor = darkMode ?Colors.white : Colors.black;
  late Color topAppBarColor = darkMode ?Colors.black45 : Colors.transparent;
  late Color iconColor = darkMode ? Colors.white : Colors.black;
  late Color defaultButtonColor = darkMode ? const Color.fromARGB(255, 40, 40, 40) : const Color.fromARGB(255, 225, 225, 225);
  late Color pressedButtonColor = darkMode ? const Color.fromARGB(255, 60, 60, 60) : const Color.fromARGB(255, 245, 245, 245);
  late Color subTextColor = darkMode ? Colors.grey : const Color.fromARGB(255, 90, 90, 90);
  late IconData colorModeIcon = darkMode ? Icons.light_mode : Icons.dark_mode;
}




class BottomButton extends StatelessWidget {
  final ThemeColors themeColors;
  final VoidCallback function;
  const BottomButton({super.key, required this.themeColors, required this.function, });
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        splashColor: Colors.black45,
        onTap: function,
        child: Container(
          height: 55,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: themeColors.iconColor,
            borderRadius: const BorderRadius.all(Radius.circular(30))
          ),
          child: Text(
            'Proceed',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeColors.backgroundColor
            ),
          ),
        )
      ),
    );
  }
}

class BottomButtons extends StatelessWidget {
  final BuildContext ccontext;
  final ThemeColors themeColors;
  final String filePath;
  final Map<String, dynamic>? decodedJSON;
  const BottomButtons({super.key, required this.themeColors, required this.ccontext, required this.decodedJSON, required this.filePath});

  void _showModalBottomSheet(){
    showModalBottomSheet(
      context: ccontext,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      isScrollControlled: true,
      elevation: 10,
      builder: (BuildContext context){
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: ChatWindow(filePath: filePath)
        );
      }
    );
  }

  void _goToCheckpointsPage(){
    Navigator.of(ccontext).push(
      MaterialPageRoute(builder: (context) => CheckPointsPage(decodedJSON: decodedJSON,),
      )
    );
  }
  @override
  Widget build(BuildContext context) {
    EdgeInsets devicePadding = MediaQuery.of(context).padding;
    return Padding(
      padding: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: devicePadding.bottom + 5),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(40)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              // color: Colors.greenAccent,
              borderRadius: BorderRadius.all(Radius.circular(40))
            ),
            child: Row(
              children: [
                ChatButton(themeColors : themeColors, function: _showModalBottomSheet,),
                const SizedBox(width: 10,),
                BottomButton(function: _goToCheckpointsPage, themeColors: themeColors,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChatButton extends StatelessWidget {
  final ThemeColors themeColors;
  final VoidCallback function;
  const ChatButton({super.key, required this.themeColors, required this.function});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: function,
      child: Container(
        width: 55,
        height: 55,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: themeColors.iconColor,
          borderRadius: const BorderRadius.all(Radius.circular(30)),
        ),
        child: Icon(
          Icons.chat_bubble_outline,
          color: themeColors.backgroundColor,
        ),
      ),
    );
  }
}
class ChatWindow extends StatefulWidget {
  final String filePath;
  const ChatWindow({super.key, required this.filePath});

  @override
  State<ChatWindow> createState() => _ChatWindowState();
}

class _ChatWindowState extends State<ChatWindow> {

  String botMessage = '';

  Future<void> sendMessage(String message) async{
    const String serverChatUrl = 'http://notology.me:6000/chat';
    try{
      print('sending request');
      final response = await http.post(
        Uri.parse(serverChatUrl),
        body: jsonEncode({'message' : message, 'filePath' : widget.filePath}),
        headers: {'Content-Type' : 'application/json'},
      );

      if(response.statusCode == 200){
        final data = json.decode(response.body);
        final botResponse = data['message'];
        // ignore: avoid_print
        print('botResponse : $botResponse');
        setState(() {
          botMessage = botResponse;
        });
      } else {
        // ignore: avoid_print
        print('Server Error : ${response.statusCode}');
    }
  } catch (e){
      print('error : $e');
    }
  }

  void sendButtonFunction() async{
    String m = textEditingController.text;
    textEditingController.clear();
    setState(() { 
      messages.add([0,m]);
    });
    await sendMessage(m);
    setState(() {
      messages.add([1,botMessage.split('):')[1]]);
    });
  }
  List<dynamic> messages = [
    [1, 'You are allowed to ask up to three questions to the AI. Please ensure that your questions are clear and concise. Make the most out of your limited queries and ask questions that matter the most to you. Thank you for your understanding.']
  ];
  final TextEditingController textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
  // EdgeInsets devicePadding = MediaQuery.of(context).padding;
  // Size size = MediaQuery.of(context).size;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(15))
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(0),
              scrollDirection: Axis.vertical,
              reverse: true, 
              children: 
                [
                  ...messages.map((message) => ChatBubble(sender: message[0], message: message[1])),
              ].reversed.toList()
            ),
          ),
          ChatWindowTypingArea(
            controller: textEditingController,
            sendButtonFunction: sendButtonFunction,
          ),
          ],
        ),
      ),
    );
  }
}

class ChatWindowTypingArea extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback sendButtonFunction;
  const ChatWindowTypingArea({super.key, required this.controller, required this.sendButtonFunction});

  @override
  Widget build(BuildContext context) {
    EdgeInsets devicePadding = MediaQuery.of(context).padding;
    return Container(
      margin: EdgeInsets.only(bottom: devicePadding.bottom + 5, left: 12, right: 12, top: 5),
      height: 50,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 229, 229, 229),
        borderRadius: BorderRadius.all(Radius.circular(10))
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 12,),
          Expanded(
            child: TextField(
              controller: controller,
              cursorColor: const Color.fromARGB(255, 45, 45, 45),
              autocorrect: false,
              cursorHeight: 15,
              style: const TextStyle(
                color: Colors.black
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                fillColor: Colors.black,
                hintText: 'Ask Anything..',
                hintStyle: TextStyle(color: Colors.grey)
              ),
            )
          ),
          Container(
            height: 25,
            width: 1,
            color: Colors.grey,
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              splashColor: Colors.white,
              onTap: sendButtonFunction,
              child: Ink(
                width: 45,
                height: 50,
                child:  const Icon(
                  Icons.arrow_forward,
                  color: Colors.black,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final int sender;
  final String message;
  const ChatBubble({super.key, required this.sender, required this.message});

  @override
  Widget build(BuildContext context) {

    return Align(
      alignment: sender == 0 ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(left: sender == 0 ? 30 : 12 , right: sender == 0 ? 12 : 30, bottom: 8, top: 8),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: sender == 0 ? Colors.black : const Color.fromARGB(255, 231, 231, 231),
          borderRadius: BorderRadius.only(topLeft: const Radius.circular(12), topRight: const Radius.circular(12), bottomLeft: Radius.circular(sender == 0 ? 12 : 0), bottomRight: Radius.circular(sender == 0 ? 0 : 12))
        ),
        child: Text(
          message,
          textAlign: TextAlign.left,
          style: TextStyle(
            color: sender == 0 ? Colors.white : Colors.black,
          )
        )
      )
    );
  }
}