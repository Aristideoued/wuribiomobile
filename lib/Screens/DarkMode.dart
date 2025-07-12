import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Api/theme_notifier.dart';

class SharedPreferencesDemo extends StatefulWidget {
  final ThemeNotifier themeNotifier;
  const SharedPreferencesDemo({super.key, required this.themeNotifier});
  @override
  _SharedPreferencesDemoState createState() => _SharedPreferencesDemoState();
}

class _SharedPreferencesDemoState extends State<SharedPreferencesDemo> {
  bool isDarkMode = false;
  String username = '';
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('darkMode') ?? false;
      username = prefs.getString('username') ?? '';
      _controller.text = username;
    });
  }

  Future<void> _saveDarkMode(bool value) async {
    await widget.themeNotifier.setDarkMode(value);
    setState(() {
      isDarkMode = value;
    });
  }

  Future<void> _saveUsername(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', value);
    setState(() {
      username = value;
    });
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('SharedPreferences Demo'),
      backgroundColor: Colors.deepPurple,
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Espace entre contenu haut et bas
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                title: const Text('Mode sombre'),
                value: isDarkMode,
                onChanged: (val) => _saveDarkMode(val),
              ),
              const SizedBox(height: 24),
              const Text('Nom d\'utilisateur :',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(hintText: 'Entrer un nom'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _saveUsername(_controller.text),
                    child: const Text('Enregistrer'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Nom sauvegardé : $username'),
              const SizedBox(height: 32),
              Text(
                'SharedPreferences permet de stocker des données simples (clé-valeur) de façon persistante.',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),

          // Boutons en bas
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/fire');
                  },
                  icon: const Icon(Icons.local_fire_department, color: Colors.white),
                  label: const Text('Fire', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                   Navigator.pushNamed(context, '/lite');
                  },
                  icon: const Icon(Icons.light_mode, color: Colors.white),
                  label: const Text('Lite', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

}