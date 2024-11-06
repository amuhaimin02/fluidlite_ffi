import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:fluidlite/fluidlite.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pcm_sound/flutter_pcm_sound.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final FluidLiteSynth synth;

  static const sampleRate = 44100;

  @override
  void initState() {
    super.initState();

    synth = FluidLiteSynth();

    (() async {
      final storageDir = await getApplicationSupportDirectory();
      final soundfontFile = File('${storageDir.path}/soundfont.sf2');

      var soundfontBytes = await rootBundle.load("assets/8MBGMSFX.SF2");
      soundfontFile.writeAsBytesSync(soundfontBytes.buffer.asUint8List());

      final soundFontId = synth.loadSoundfont(soundfontFile.path);
      synth.gain = 1;

      synth.programSelect(
          channel: 0, soundfontId: soundFontId, bankNumber: 0, presetNumber: 5);

      await FlutterPcmSound.setFeedThreshold(1024);
      FlutterPcmSound.setFeedCallback(_onPcmFeed);
      await FlutterPcmSound.setup(sampleRate: sampleRate, channelCount: 2);
    })();
  }

  @override
  void dispose() {
    synth.dispose();
    super.dispose();
  }

  int _counter = 0;

  void _onPcmFeed(int remainingFrames) async {
    const notes = [60, 62, 64, 65, 67, 69, 71, 72];

    if (_counter > 0) {
      synth.noteOff(channel: 0, key: notes[(_counter - 1) % notes.length]);
    }
    synth.noteOn(
        channel: 0, key: notes[_counter % notes.length], velocity: 127);

    final samples = synth.renderPCM16Bit(length: sampleRate ~/ 2);

    await FlutterPcmSound.feed(
        PcmArrayInt16(bytes: ByteData.view(samples.buffer)));

    _counter++;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('FluidLite Demo'),
        ),
        body: Center(
          child: Column(
            children: [
              FilledButton(
                onPressed: () async {
                  await FlutterPcmSound.play();
                },
                child: const Text('Start'),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () async {
                  await FlutterPcmSound.pause();
                },
                child: const Text('Stop'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
