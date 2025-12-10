import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mp3quran/pages/drawer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Acceuil extends StatefulWidget {
  const Acceuil({super.key});

  @override
  State<Acceuil> createState() => _AcceuilState();
}

class _AcceuilState extends State<Acceuil> with WidgetsBindingObserver {
  final payer = AudioPlayer();

  List<dynamic> sourate = [];
  bool jouer = false;
  bool lectureContinue = false;
  bool lectureMeme = false;
  bool termine = false;

  String Nom_ar = "";
  String Nom_fr = "";
  int? id;

  Duration _durer = Duration.zero;
  Duration _position = Duration.zero;

  Future<void> recup() async {
    final String response = await rootBundle.loadString("assets/mp3/coran.json");
    final List<dynamic> data = jsonDecode(response);

    setState(() {
      sourate = data;
    });
    if(id!=null){
      final s = sourate[id! - 1];
      setState(() {
        Nom_fr = s["nom_fr"]??"";
        Nom_ar = s["nom_ar"]??"";
        termine=true;
      });
    }else{
      id=1;
    }
    
  }

  String format(Duration d) {
    String two(int n) => n.toString().padLeft(2, "0");

    if (d.inHours > 0) {
      return "${d.inHours}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}";
    } else {
      return "${two(d.inMinutes)}:${two(d.inSeconds % 60)}";
    }
  }

  void suivanArrier(int nb) {
    if (id == null) return;

    id = (id! + nb).clamp(1, 114);

    final s = sourate[id! - 1];
    audio(s["audio"], s["nom_fr"], s["nom_ar"]);
  }

  Future<void> audio(String url, String nom_fr, String nom_ar) async {
    await payer.stop();
    await payer.play(AssetSource("mp3/$url"));

    setState(() {
      Nom_fr = nom_fr;
      Nom_ar = nom_ar;
      jouer = true;
      termine = false;
    });
  }

  void toutLire() {
    if (id == null) return;

    setState(() => lectureContinue = !lectureContinue);

    if (lectureContinue) {
      lectureMeme = false;
    }
  }

  void recupdebut() async {
    final pref = await SharedPreferences.getInstance();
    final point = pref.getInt("dernier_id");
    final lecteurcon = pref.getBool("lectureContinue");
    final lecteurme = pref.getBool("lectureMeme");
    setState(() {
      id = point ?? 1;
      lectureContinue = lecteurcon ?? false;
      lectureMeme = lecteurme ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    recup();
    recupdebut();

    payer.onDurationChanged.listen((d) {
      setState(() => _durer = d);
    });

    payer.onPositionChanged.listen((p) {
      setState(() => _position = p);
    });

    payer.onPlayerComplete.listen((event) {
      setState(() {
        jouer = false;
        termine = true;
      });

      if (lectureContinue && id != null) {
        if (id! < 114) {
          id = id! + 1;
          final s = sourate[id! - 1];
          audio(s["audio"], s["nom_fr"], s["nom_ar"]);
        } else {
          lectureContinue = false;
        }
      } else if (lectureMeme && id != null) {
        final s = sourate[id! - 1];
        audio(s["audio"], s["nom_fr"], s["nom_ar"]);
      }
    });
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    payer.dispose();
    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {

      if (id != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt("dernier_id", id!);
        await prefs.setBool("lectureMeme", lectureMeme);
        await prefs.setBool("lectureContinue", lectureContinue);
      }
    }
  }


  void partager() {
    Share.share(
      "Voici une application de Quran MP3 que je te recommande.",
      subject: "Partage du Quran MP3",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        title: const Text("Quran", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(onPressed: partager, icon: const Icon(Icons.share)),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            color: const Color(0xFF1B263B),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: "parametres",
                child: Text("Paramètres", style: TextStyle(color: Colors.white)),
              ),
              PopupMenuItem(
                value: "apropos",
                child: Text("À propos", style: TextStyle(color: Colors.white)),
              ),
            ],
            onSelected: (value) {},
          ),
        ],
      ),

      drawer: const Drawers(),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D1B2A), Color(0xFF1B263B), Color(0xFF415A77)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: sourate.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white))
                  : ListView.builder(
                      itemCount: sourate.length,
                      itemBuilder: (context, index) {
                        final s = sourate[index];

                        return Card(
                          color: Colors.white.withOpacity(0.10),
                          margin:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF415A77),
                              child: Text(s["id"].toString(),
                                  style: const TextStyle(color: Colors.white)),
                            ),
                            title: Text(s["nom_fr"],
                                style: const TextStyle(color: Colors.white)),
                            subtitle: Text(s["nom_ar"],
                                style: const TextStyle(color: Colors.white70)),
                            trailing: Icon(
                              id == s["id"] && jouer
                                  ? Icons.pause_circle_filled
                                  : Icons.play_arrow,
                              color: Colors.white,
                            ),
                            onTap: () {
                              setState(() => id = s["id"]);
                              audio(s["audio"], s["nom_fr"], s["nom_ar"]);
                            },
                          ),
                        );
                      },
                    ),
            ),

            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(25)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            "assets/images.jpeg",
                            width: 55,
                            height: 55,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Nom_fr.isNotEmpty ? "Sourate $Nom_fr" : "",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(Nom_ar,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 15)),
                            ],
                          ),
                        ),
                      ],
                    ),

                    Slider(
                      min: 0,
                      max: _durer.inSeconds.toDouble().clamp(0, 999999),
                      value: _position.inSeconds
                          .toDouble()
                          .clamp(0, _durer.inSeconds.toDouble()),
                      onChanged: (value) async {
                        final pos = Duration(seconds: value.toInt());
                        await payer.seek(pos);
                      },
                      activeColor: Colors.white,
                      inactiveColor: Colors.white24,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(format(_position),
                            style:
                                const TextStyle(color: Colors.white70, fontSize: 12)),
                        Text(format(_durer),
                            style:
                                const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: toutLire,
                          icon: Icon(Icons.loop,
                              color: lectureContinue
                                  ? Colors.greenAccent
                                  : Colors.white),
                        ),
                        IconButton(
                          onPressed: () => suivanArrier(-1),
                          icon: const Icon(Icons.skip_previous_rounded,
                              size: 35, color: Colors.white),
                        ),
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                                jouer ? Icons.pause : Icons.play_arrow_rounded,
                                size: 45,
                                color: Colors.white),
                            onPressed: () async {
                              if (jouer) {
                                await payer.pause();
                              } else {
                                if (termine && id != null) {
                                  final s = sourate[id! - 1];
                                  audio(s["audio"], s["nom_fr"], s["nom_ar"]);
                                } else {
                                  await payer.resume();
                                }
                              }
                              setState(() => jouer = !jouer);
                            },
                          ),
                        ),
                        IconButton(
                          onPressed: () => suivanArrier(1),
                          icon: const Icon(Icons.skip_next_rounded,
                              size: 35, color: Colors.white),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() => lectureMeme = !lectureMeme);
                            if (lectureMeme) lectureContinue = false;
                          },
                          icon: Icon(Icons.repeat,
                              color: lectureMeme
                                  ? Colors.greenAccent
                                  : Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(height: 30,)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
