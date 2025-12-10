import 'package:flutter/material.dart';

class Drawers extends StatefulWidget {
  const Drawers({super.key});

  @override
  State<Drawers> createState() => _DrawersState();
}

class _DrawersState extends State<Drawers> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [

          // 🌙 --- HEADER AVEC IMAGE ASSET ---
          SizedBox(
            height: 220,
            child: DrawerHeader(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/mosque.jpeg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5), // effet sombre
                ),
                child: const Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    "MP3 Quran",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
         

          ListTile(
            leading: const Icon(Icons.settings, color: Colors.green),
            title: const Text("Paramètres"),
            onTap: () {
            },
          ),
           ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.blueAccent),
            title: const Text("À propos"),
            onTap: () {
              // action ici
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text("Quitter"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
