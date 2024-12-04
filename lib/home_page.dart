import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

enum AudioSourceOption { Network, Asset }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _player = AudioPlayer();

//ERRO AQUI NA INICIALIZAÇAO

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    _setupAudioPlayer(AudioSourceOption.Network);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Center(
        child: const Text(
          'Music Player PNT3',
        ),
      )),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 25.0,
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                _sourceSelect(),
                _progressBar(),
                Row(
                  children: [
                    _controlButtons(),
                    _playbackControlButton(),
                  ],
                )
              ]),
        ),
      ),
    );
  }

//CONFIGURAÇÕES DO PLAYER

  Future<void> _setupAudioPlayer(AudioSourceOption option) async {
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stactrace) {
      print("Arquivo não encontrado: $e");
    });
//SE DER ERRO A MENSAGEM É 'E'

    //PQ O LINK TA GRIFADO????
    try {
      if (option == AudioSourceOption.Network) {
        await _player.setAudioSource(AudioSource.uri(Uri.parse(
            "https://orangefreesounds.com/wp-content/uploads/2015/05/Forgiven-electronic-lounge-music.mp3")));
      } else if (option == AudioSourceOption.Asset) {
        await _player
            .setAudioSource(AudioSource.asset("assets/Across the Lines.mp3"));
      }
    } catch (e) {
      print("Erro ao buscar o arquivo de audio: $e");
    }
  }

// escolher qual a fonte de media

  Widget _sourceSelect() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      MaterialButton(
        color: Colors.blue,
        child: Text('Som on line: digite o endereço:(em breve)'),
        onPressed: () => _setupAudioPlayer(AudioSourceOption.Network),
      ),
      MaterialButton(
        color: Colors.yellow,
        child: Text('Som local: Buscar'),
        onPressed: () => _setupAudioPlayer(AudioSourceOption.Asset),
      ),
    ]);
  }

//CURSOR

  Widget _progressBar() {
    return StreamBuilder<Duration?>(
      stream: _player.positionStream,
      builder: (context, snapshot) {
        return ProgressBar(
          progress: snapshot.data ?? Duration.zero,
          buffered: _player.bufferedPosition,
          total: _player.duration ?? Duration.zero,
          onSeek: (duration) {
            _player.seek(duration);
          },
        );
      },
    );
  }

//PLAYBACK

  Widget _playbackControlButton() {
    return StreamBuilder<PlayerState>(
        stream: _player.playerStateStream,
        builder: (context, snapshot) {
          final processingState = snapshot.data?.processingState;
          final playing = snapshot.data?.playing;
          if (processingState == ProcessingState.loading ||
              processingState == ProcessingState.buffering) {
            return Container(
              margin: const EdgeInsets.all(8.0),
              width: 64,
              height: 64,
              child: const CircularProgressIndicator(),
            );
          } else if (playing != true) {
            return IconButton(
              icon: const Icon(Icons.play_arrow),
              iconSize: 64,
              onPressed: _player.play,
            );
          } else if (processingState != ProcessingState.completed) {
            return IconButton(
              icon: const Icon(Icons.pause),
              iconSize: 64,
              onPressed: _player.pause,
            );
          } else {
            return IconButton(
                icon: const Icon(Icons.replay),
                iconSize: 64,
                onPressed: () => _player.seek(Duration.zero));
          }
        });
  }

  Widget _controlButtons() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      StreamBuilder(
          stream: _player.speedStream,
          builder: (context, snapshot) {
            return Row(children: [
              const Icon(
                Icons.speed,
              ),
              Slider(
                  min: 1,
                  max: 5,
                  value: snapshot.data ?? 1,
                  divisions: 5,
                  onChanged: (value) async {
                    await _player.setSpeed(value);
                  })
            ]);
          }),
      StreamBuilder(
          stream: _player.volumeStream,
          builder: (context, snapshot) {
            return Row(children: [
              const Icon(
                Icons.volume_up,
              ),
              Slider(
                  min: 0,
                  max: 3,
                  value: snapshot.data ?? 1,
                  divisions: 4,
                  onChanged: (value) async {
                    await _player.setVolume(value);
                  })
            ]);
          }),
    ]);
  }
}



//add nova dependencia
// proble3ma de icone: usando a dependencia cupertino: nao aparece em certo sistemas(feitos pra ios)