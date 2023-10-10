import 'package:dropbox_sign/Pages/sharingpage.dart';
import 'package:dropbox_sign/Pages/signing_webview.dart';
import 'package:flutter/material.dart';

import 'Pages/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const HomePage(), 
      // home: const SigningPage(),
      // home: const SharingPage(downloadLink: 'https://s3.amazonaws.com/hellofax_uploads/super_groups/2023/10/10/8a10996b4c9db6651c644df59501835aeab8a128/merged-tamperproofed.pdf?response-content-disposition=attachment&response-content-type=application%2Fbinary&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAUMSXJYX53PEKO3SX%2F20231010%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20231010T163152Z&X-Amz-SignedHeaders=host&X-Amz-Expires=259200&X-Amz-Signature=1be965bd1b5b6339bd6ddc708c5443e388e0412491963ef6fbab4b9e66a21bd6',),
    );
  }
}