import 'package:flutter/material.dart';
import 'package:mp3quran/pages/acceuil.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();

    // ⏳ Attendre 5 secondes puis rediriger
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return; // IMPORTANT : éviter "setState after dispose"
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Acceuil()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // 🌙 Dégradé moderne
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0D1B2A),
              Color(0xFF1B263B),
              Color(0xFF415A77),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 📷 Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                "assets/images.jpeg",
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            // 🕌 Titre
            const Text(
              "MP3 Quran",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 10),

            // 🔄 Animation des points
            const _LoadingDots(),
          ],
        ),
      ),
    );
  }
}

// ============================
//   ANIMATION "Chargement..."
// ============================

class _LoadingDots extends StatefulWidget {
  const _LoadingDots({super.key});

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots> {
  String dots = "";

  @override
  void initState() {
    super.initState();

    // 🔁 Animation toutes les 400 ms
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 400));

      // Stopper proprement si le widget n’est plus affiché
      if (!mounted) return false;

      setState(() {
        dots = dots.length == 3 ? "" : dots + ".";
      });

      return true; // Continue la boucle
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      "Chargement$dots",
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 18,
      ),
    );
  }
}
