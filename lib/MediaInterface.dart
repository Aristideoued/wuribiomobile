import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

/*void main() {
  runApp(MediaPlay());
}

class MediaPlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Media Player',
      debugShowCheckedModeBanner: false,
      home: MediaTutorialScreen(),
    );
  }
}*/

class MediaTutorialScreen extends StatefulWidget {
  @override
  _MediaTutorialScreenState createState() => _MediaTutorialScreenState();
}

class _MediaTutorialScreenState extends State<MediaTutorialScreen> {
  // Variables pour AUDIOPLAYERS
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  String audioStatus = "Audio non chargé";

  // Variables pour VIDEO_PLAYER
  VideoPlayerController? videoController;
  bool isVideoReady = false;

  // Variables pour IMAGE_PICKER
  File? selectedImage;
  final ImagePicker imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // Écouter les changements d'état de l'audio
    audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
        if (state == PlayerState.playing) {
          audioStatus = "Audio en cours de lecture";
        } else if (state == PlayerState.paused) {
          audioStatus = "Audio en pause";
        } else if (state == PlayerState.stopped) {
          audioStatus = "Audio arrêté";
        }
      });
    });
  }

  @override
  void dispose() {
    // IMPORTANT: Nettoyer les ressources
    audioPlayer.dispose();
    videoController?.dispose();
    super.dispose();
  }

  Future<void> playAudioFromAssets() async {
    try {
      // Jouer un fichier audio depuis les assets
      await audioPlayer.play(AssetSource('audio/sample.mp3'));
      setState(() {
        audioStatus = "Lecture depuis assets";
      });
    } catch (e) {
      print("Erreur audio assets: $e");
      setState(() {
        audioStatus = "Erreur: Vérifiez le fichier audio/sample.mp3";
      });
    }
  }

  Future<void> playAudioFromUrl() async {
    try {
      // Jouer un fichier audio depuis Internet
      String audioUrl =
          'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav';
      await audioPlayer.play(UrlSource(audioUrl));
      setState(() {
        audioStatus = "Lecture depuis URL";
      });
    } catch (e) {
      print("Erreur audio URL: $e");
      setState(() {
        audioStatus = "Erreur réseau audio";
      });
    }
  }

  Future<void> pauseAudio() async {
    await audioPlayer.pause();
  }

  Future<void> stopAudio() async {
    await audioPlayer.stop();
  }

  Future<void> loadVideoFromAssets() async {
    try {
      // Charger une vidéo depuis les assets
      videoController = VideoPlayerController.asset('video/vid.mp4');
      await videoController!.initialize();
      setState(() {
        isVideoReady = true;
      });
    } catch (e) {
      print("Erreur vidéo assets: $e");
      _showMessage("Erreur: Vérifiez le fichier video/vid.mp4");
    }
  }

  Future<void> loadVideoFromUrl() async {
    try {
      // Charger une vidéo depuis Internet
      String videoUrl =
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';

      // Nettoyer l'ancien contrôleur
      if (videoController != null) {
        await videoController!.dispose();
      }

      videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await videoController!.initialize();
      setState(() {
        isVideoReady = true;
      });
    } catch (e) {
      print("Erreur vidéo URL: $e");
      _showMessage("Erreur réseau vidéo");
    }
  }

  void playPauseVideo() {
    if (videoController != null && isVideoReady) {
      if (videoController!.value.isPlaying) {
        videoController!.pause();
      } else {
        videoController!.play();
      }
      setState(() {});
    }
  }

  Future<void> takePhotoFromCamera() async {
    try {
      final XFile? photo = await imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          selectedImage = File(photo.path);
        });
      }
    } catch (e) {
      print("Erreur caméra: $e");
      _showMessage("Erreur d'accès à la caméra");
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
        });
      }
    } catch (e) {
      print("Erreur galerie: $e");
      _showMessage("Erreur d'accès à la galerie");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ressources Multimédias'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // SECTION AUDIO

            _buildSectionTitle("AUDIO (audioplayers)"),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      audioStatus,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: playAudioFromAssets,
                            child: Text('Assets Audio'),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: playAudioFromUrl,
                            child: Text('URL Audio'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isPlaying ? pauseAudio : null,
                            child: Text('Pause'),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: stopAudio,
                            child: Text('Stop'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // SECTION VIDEO

            _buildSectionTitle("VIDEO (video_player)"),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: loadVideoFromAssets,
                            child: Text('Assets Vidéo'),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: loadVideoFromUrl,
                            child: Text('URL Vidéo'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Affichage de la vidéo
                    if (isVideoReady && videoController != null)
                      Column(
                        children: [
                          Container(
                            height: 200,
                            width: double.infinity,
                            child: AspectRatio(
                              aspectRatio: videoController!.value.aspectRatio,
                              child: VideoPlayer(videoController!),
                            ),
                          ),
                          SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: playPauseVideo,
                            icon: Icon(
                              videoController!.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                            ),
                            label: Text(
                              videoController!.value.isPlaying
                                  ? 'Pause'
                                  : 'Jouer',
                            ),
                          ),
                        ],
                      )
                    else
                      Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: Center(
                          child: Text(
                            'Chargez une vidéo',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // SECTION IMAGE

            _buildSectionTitle(" IMAGE (image_picker)"),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: takePhotoFromCamera,
                            icon: Icon(Icons.camera_alt),
                            label: Text('Caméra'),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: pickImageFromGallery,
                            icon: Icon(Icons.photo_library),
                            label: Text('Galerie'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Affichage de l'image
                    if (selectedImage != null)
                      Container(
                        height: 200,
                        width: double.infinity,
                        child: Image.file(
                          selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: Center(
                          child: Text(
                            'Aucune image sélectionnée',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
        ),
      ),
    );
  }
}