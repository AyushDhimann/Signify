import 'package:dropbox_sign/Pages/upload_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    // return const UploadPage();
    EdgeInsets devicePadding = MediaQuery.of(context).padding;
    Size size = MediaQuery.of(context).size;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SizedBox(height: devicePadding.top, width: double.infinity,),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1603796846097-bee99e4a601f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=3174&q=80'),
                      fit: BoxFit.cover
                    ),
                  ),
                )
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Signatures.',
                      style: TextStyle(
                        color: Color.fromARGB(255, 84, 84, 84),
                        fontSize: 40,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const Text(
                      'Secured.',
                      style: TextStyle(
                        color: Color.fromARGB(255, 143, 143, 143),
                        fontSize: 40,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const Text(
                      'Signify.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 30,),
                    InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(30)),
                      splashColor: Colors.black45,
                      onTap: () => Navigator
                      .of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (BuildContext context){
                              return const UploadPage();
                            }
                        )
                    ),
                      child: Ink(
                        width: double.infinity,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(30))
                        ),
                        child: const Center(
                          child: Text(
                            'Get Started',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: devicePadding.bottom + 8),
    
            ],
          ),
        ),
      ),
    );
  }
}