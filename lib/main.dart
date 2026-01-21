import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const FakeCallApp());
}

class FakeCallApp extends StatelessWidget {
  const FakeCallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SetupScreen(),
    );
  }
}

/* ---------------- SETUP SCREEN ---------------- */

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final TextEditingController nameCtrl =
      TextEditingController(text: "Unknown Caller");

  int delay = 10;
  Timer? _timer;

  void startFakeCall() {
    _timer?.cancel();

    _timer = Timer(Duration(seconds: delay), () {
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => IncomingCallScreen(name: nameCtrl.text),
        ),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fake Call Setup")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: "Caller Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButton<int>(
              value: delay,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 5, child: Text("After 5 seconds")),
                DropdownMenuItem(value: 10, child: Text("After 10 seconds")),
                DropdownMenuItem(value: 30, child: Text("After 30 seconds")),
              ],
              onChanged: (v) => setState(() => delay = v!),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: startFakeCall,
              child: const Text("Start Fake Call"),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------------- INCOMING CALL SCREEN ---------------- */

class IncomingCallScreen extends StatefulWidget {
  final String name;
  const IncomingCallScreen({super.key, required this.name});

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  final AudioPlayer ringtonePlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    playRingtone();
  }

  Future<void> playRingtone() async {
    await ringtonePlayer.setReleaseMode(ReleaseMode.loop);
    await ringtonePlayer.play(AssetSource("ringtone.mp3"));
  }

  Future<void> stopRingtone() async {
    await ringtonePlayer.stop();
  }

  @override
  void dispose() {
    stopRingtone();
    ringtonePlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Incoming Call",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    backgroundColor: Colors.red,
                    onPressed: () {
                      stopRingtone();
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.call_end),
                  ),
                  FloatingActionButton(
                    backgroundColor: Colors.green,
                    onPressed: () {
                      stopRingtone();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CallConnectedScreen(),
                        ),
                      );
                    },
                    child: const Icon(Icons.call),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ---------------- CALL CONNECTED SCREEN ---------------- */

class CallConnectedScreen extends StatefulWidget {
  const CallConnectedScreen({super.key});

  @override
  State<CallConnectedScreen> createState() => _CallConnectedScreenState();
}

class _CallConnectedScreenState extends State<CallConnectedScreen> {
  final AudioPlayer voicePlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    playVoice();
  }

  Future<void> playVoice() async {
    await voicePlayer.play(AssetSource("voice.mp3"));
  }

  @override
  void dispose() {
    voicePlayer.stop();
    voicePlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Call Connected",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.call_end),
            ),
          ],
        ),
      ),
    );
  }
}
