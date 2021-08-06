import 'package:flutter_tts/flutter_tts.dart';
 class Voice {
   FlutterTts flutterTts = FlutterTts();

   Future Speak(String text) async{
     var result = await flutterTts.speak(text);
   }
 }