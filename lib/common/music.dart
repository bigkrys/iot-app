import 'package:audioplayers/audioplayers.dart';
class Music{
  AudioPlayer audioPlayer = AudioPlayer();
  playMusic(String musicaddr) async{

    await audioPlayer.setUrl(musicaddr);
    var result = await audioPlayer.play(musicaddr);
    print(result.toString());

  }

  pauseMusic() async {

    await audioPlayer.pause();

  }
  replayMusic() async{
    await audioPlayer.resume();


  }
  stopPlayMusic() async{
    await audioPlayer.stop();

  }

}
