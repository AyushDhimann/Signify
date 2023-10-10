import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:simple_animations/animation_builder/play_animation_builder.dart';
import 'package:url_launcher/url_launcher.dart';

class SharingPage extends StatefulWidget {
  final String? downloadLink;
  const SharingPage({super.key, required this.downloadLink});

  @override
  State<SharingPage> createState() => _SharingPageState();
}

class _SharingPageState extends State<SharingPage> {
  @override
  void initState() {
    print(widget.downloadLink);
    super.initState();
  }
  Future<void> _launchUrl() async {
    final Uri _url = Uri.parse(widget.downloadLink??'');
    if (await canLaunchUrl(_url)) {
      launchUrl(_url);
    } else {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  Widget build(BuildContext context) {
    String shareSheetQuote = "Here's the Signed Document\n${widget.downloadLink}\n\n\tSigned Using SIGNIFY";
    EdgeInsets devicePadding = MediaQuery.of(context).padding;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // SizedBox(height: devicePadding.top, width: double.infinity,),
              Expanded(child: Container()),
              const SuccessfulAnimation(),
              Expanded(child: Container()),
              const SizedBox(height: 20,),
              const Text(
                'Your document is signed and ready! You may now proceed to save the signed document to your device or share it using the buttons given below.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12
                ),
              ),
              BottomButton(isPrimaryButton: false, function: () => _launchUrl(),),
              BottomButton(isPrimaryButton: true, function: () => Share.share(shareSheetQuote),),
              const SizedBox(height: 10,),
              const Text(
                'Made w/ ❤️ by Ayush & Parth',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: devicePadding.bottom,),
            ],
          ),
        ),
      ),
    );
  }
}

class SuccessfulAnimation extends StatefulWidget {
  const SuccessfulAnimation({super.key});

  @override
  State<SuccessfulAnimation> createState() => _SuccessfulAnimationState();
}

class _SuccessfulAnimationState extends State<SuccessfulAnimation> {
  @override
  Widget build(BuildContext context) {
    return PlayAnimationBuilder(
      tween: Tween(begin: 0.01, end: 1.0),
      duration: const Duration(milliseconds: 2500),
      curve: Curves.fastOutSlowIn,
      builder: (context, value, child) => 
        Opacity(
          opacity: value,
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.done,
              color: Colors.green,
              size: 45,
            ),
            SizedBox(height: 5,),
            Text(
              'Successful!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 40
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomButton extends StatelessWidget {
  // final String text;
  // final IconData primaryIcon;
  final bool isPrimaryButton;
  final VoidCallback function;
  const BottomButton({super.key, required this.isPrimaryButton, required this.function});
  

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: function,
              splashColor: !isPrimaryButton? Colors.black87 : Colors.white54,
              borderRadius: const BorderRadius.all(Radius.circular(25)),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: !isPrimaryButton? Colors.transparent : Colors.white, width: 1),
                  borderRadius: const BorderRadius.all(Radius.circular(26))
                ),
                child: Ink(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: !isPrimaryButton ? Colors.white : Colors.black,
                    borderRadius: const BorderRadius.all(Radius.circular(25))
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        !isPrimaryButton? CupertinoIcons.square_arrow_down : CupertinoIcons.square_arrow_up,
                        color: !isPrimaryButton ? Colors.black : Colors.white,
                      ),
                      Text(
                        !isPrimaryButton ? 
                        'Save to Device' : 'Share',
                        style: TextStyle(
                          color: !isPrimaryButton ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      const Icon(
                        CupertinoIcons.square_arrow_up,
                        color: Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}