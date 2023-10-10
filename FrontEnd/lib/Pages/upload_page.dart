import 'package:dropbox_sign/Pages/summary_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../Services/services.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {

  PlatformFile? selectedFile;
  Uint8List? fileBytes;
  bool isUploading = false;
  bool isUploaded = false;

  /*
  0 - Not uploaded and not uploading
  1 - is uploding but not uploaded
  2 - not uploading and uploaded
  */
  int uploadStatus(){
    if(!isUploaded && !isUploading){
      return 0;
    } else if (isUploading && !isUploaded){
      return 1;
    }
    return 2;
  }


  Future<void> setContinueButtonFunction(){
    if(uploadStatus() == 0){
      return uploadFile(); 
    } 
    // else if (uploadStatus() == 1){
    //   return () async => Void;
    // } 
    return moveToSummary();
  }


  Future<void> openFiles() async {
    FilePickerResult? resultFile 
              = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowMultiple: false,
                allowedExtensions: ['pdf', 'png', 'docx', 'txt']
              );
    if(resultFile != null){
      PlatformFile file = resultFile.files.first;
      // ignore: avoid_print
      // print(file.name);
      // // ignore: avoid_print
      // print(file.size);
      // // ignore: avoid_print
      // print(file.extension);
      // ignore: avoid_print
      // print("Path of the file selected is - ${file.path}");

      setState(() {
        selectedFile = file;
        fileBytes = resultFile.files.first.bytes;

      });
    } else {
      // will give a message that user has cancelled file picking
    }
  }

  Future<void> uploadFile() async {
    setState(() {
      isUploading = true;
    });
    var uri = Uri.parse('http://notology.me:4000/uploads');
    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file',  selectedFile!.path.toString()));
    // request.files.add(http.MultipartFile.fromBytes('file', fileBytes!));
    var response = await request.send();
    if(response.statusCode == 200){
      // ignore: avoid_print
      print('Uploaded...');
      setState(() {
        isUploaded = true;
        isUploading = false;
      });

    } else {  
      // ignore: avoid_print
      print('Something went wrong!');
    }
  }
  
  Future<dynamic> moveToSummary() async{
    final authenticate = await LocalAuth.authenticate();
    if(authenticate) {
      return Navigator
        .of(context)
          .push(
            MaterialPageRoute(
              builder: (BuildContext context){
                return SummaryPage(fileName: selectedFile?.name,);
              }
          )
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    EdgeInsets devicePadding = MediaQuery.of(context).padding;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: devicePadding.top + 12,),
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    splashColor: Colors.white38,
                    onTap: () => Navigator.pop(context),
                    child: Ink(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 40, 40, 40),
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      child: const Icon(Icons.arrow_back),
                    ),
                  ),
                ),
                const SizedBox(height: 15,),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Upload',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 32
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "To upload a file, simply tap the camera icon to capture photos using your phone's camera, or click on the folder icon to access and select a file from your phone's local storage.",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                SelectFileButton(type: 'Select', function: () => openFiles(),),
                // const SizedBox(height: 15,),
                // SelectFileButton(type: 'Scan', function: (){},),
                const SizedBox(height: 20,),
                Align(
                  alignment: Alignment.centerLeft,
                  child:  selectedFile==null? 
                              const SizedBox():
                                SelectedFileDisplay(file: selectedFile!)
                ),
                  const SizedBox(height: 20,),
                isUploaded?
                const Text(
                  "Uploaded Successfully! You may now click on the 'Proceed' button to continue with the process",
                    style: TextStyle(color: Colors.grey),
                  ) :
                  const SizedBox(),
            
                const SizedBox(height: 15,),
            
                  selectedFile == null ?
                    const SizedBox():
                      ContinueButton(
                        function: () => setContinueButtonFunction(), uploadStatus: uploadStatus(),
                ),
            
            
              ],
          ),
        ),
      ),
    );
  }
}



class SelectFileButton extends StatefulWidget {
  final String type;
  final VoidCallback function;
  const SelectFileButton({super.key, required this.type, required this.function});

  @override
  State<SelectFileButton> createState() => _SelectFileButtonState();
}

class _SelectFileButtonState extends State<SelectFileButton> {
  bool isPressed = false;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => setState(() => isPressed = true),
      onTapUp: (details) => setState(() => isPressed = false),
      onTapCancel: () => setState(() => isPressed = false),
      onTap: widget.function,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        height: 80,
        decoration: BoxDecoration(
          color: !isPressed?Colors.transparent:Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          border: Border.all(width: 1, color: const Color.fromARGB(150, 158, 158, 158))
        ),
        child: Row(
          children: [
            Icon(
              widget.type.toLowerCase() == 'select'?
              Icons.file_open_outlined:
              Icons.camera_alt_outlined,
              color: !isPressed?
                        Colors.white:
                          Colors.black,
            ),
            const SizedBox(width: 20,),
            Text(
              widget.type.toLowerCase() == 'select'?
              'Select From Device':
              'Start Scanning Now',
              style: TextStyle(
                color: 
                !isPressed?
                  Colors.white:
                    Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SelectedFileDisplay extends StatelessWidget {
  final PlatformFile file;
  const SelectedFileDisplay({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width/4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size.width/4 ,
            height: size.width/4 ,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://upload.wikimedia.org/wikipedia/commons/thumb/0/01/Google_Docs_logo_%282014-2020%29.svg/1481px-Google_Docs_logo_%282014-2020%29.svg.png'),
                fit: BoxFit.contain
              )
            ),
          ),
          const SizedBox(height: 10,),
          RichText(
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: file.name,
                  style: const TextStyle(color: Colors.white, fontSize: 14)
                ),
                TextSpan(
                  text: '\n${(file.size/1000).toStringAsFixed(2)} KB',
                  style: const TextStyle(color: Colors.grey, fontSize: 11)
                ),
              ]
            )
          )
        ],
      ),
    );
  }
}

class ContinueButton extends StatefulWidget {
  final VoidCallback function;
  final int uploadStatus;
  const ContinueButton({super.key, required this.function, required this.uploadStatus});

  List<Widget> reverseEm(List<Widget> l){
    if (uploadStatus != 2) return l;
    return l.reversed.toList();
  }

  IconData setIcon(){
    if (uploadStatus == 0) return Icons.upload_file;
    return Icons.arrow_forward;
    
  }

  Color setColor(){
    if(uploadStatus == 0){
      return Colors.white;
    } else if (uploadStatus == 1){
      return Colors.transparent;
    } 
    return Colors.white;
  }

  String setMessage(){
        if (uploadStatus == 0){
      return "Start Uploading";
    } else if (uploadStatus == 1){
      return "";
    } else{
      return "Proceed";
    }
  }
  @override
  State<ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<ContinueButton> {
  bool isPressed = false;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => setState(() => isPressed = true),
      onTapUp: (details) => setState(() => isPressed = false),
      onTapCancel: () => setState(() => isPressed = false),
      onTap: widget.function,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.fastLinearToSlowEaseIn,
        height: 60,
        width: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: !isPressed?
                widget.setColor():
                  const Color.fromARGB(255, 40, 40, 40),
          borderRadius: const BorderRadius.all(Radius.circular(15))
        ),
        child: widget.uploadStatus != 1 ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: widget.reverseEm([
            Icon(
              widget.setIcon(),
              color: !isPressed?
                      Colors.black:
                          Colors.white,
            ),
            Text(
              widget.setMessage(),
              style: TextStyle(
                color: !isPressed?
                        Colors.black:
                            Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18
              ),
            ),
            Icon(
              widget.setIcon(), color: Colors.transparent,
            ),
          ]),
        ) :
          const CupertinoActivityIndicator(color: Colors.white, radius: 8),
      ),
    );
  }
}

