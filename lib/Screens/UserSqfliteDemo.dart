import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class User {
  final int? id;
  final String nom;
  final String prenom;
  final String pays;
  User({this.id, required this.nom, required this.prenom, required this.pays});

  Map<String, dynamic> toMap() => {
        'id': id,
        'nom': nom,
        'prenom': prenom,
        'pays': pays,
      };
  static User fromMap(Map<String, dynamic> map) => User(
        id: map['id'],
        nom: map['nom'],
        prenom: map['prenom'],
        pays: map['pays'],
      );
}

class UserSqfliteDemo extends StatefulWidget {
  const UserSqfliteDemo({super.key});

  @override
  _UserSqfliteDemoState createState() => _UserSqfliteDemoState();
}

class _UserSqfliteDemoState extends State<UserSqfliteDemo> {
  Database? _db;
  List<User> _users = [];
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _paysController = TextEditingController();
  int? _editingId;

  @override
  void initState() {
    super.initState();
    _initDb();
  }

  Future<void> _initDb() async {
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, 'users.db'),
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, nom TEXT, prenom TEXT, pays TEXT)');
      },
      version: 1,
    );
    _refreshUsers();
  }

  Future<void> _refreshUsers() async {
    final List<Map<String, dynamic>> maps = await _db!.query('users');
    setState(() {
      _users = maps.map((e) => User.fromMap(e)).toList();
    });
  }

  Future<void> _addOrUpdateUser() async {
    if (!_formKey.currentState!.validate()) return;
    final nom = _nomController.text.trim();
    final prenom = _prenomController.text.trim();
    final pays = _paysController.text.trim();
    if (_editingId == null) {
      await _db!.insert('users', {'nom': nom, 'prenom': prenom, 'pays': pays});
    } else {
      await _db!.update('users', {'nom': nom, 'prenom': prenom, 'pays': pays},
          where: 'id = ?', whereArgs: [_editingId]);
    }
    _clearForm();
    _refreshUsers();
  }

  void _editUser(User user) {
    setState(() {
      _editingId = user.id;
      _nomController.text = user.nom;
      _prenomController.text = user.prenom;
      _paysController.text = user.pays;
    });
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _nomController.clear();
      _prenomController.clear();
      _paysController.clear();
    });
  }

  Future<void> _deleteUser(int id) async {
    await _db!.delete('users', where: 'id = ?', whereArgs: [id]);
    _refreshUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD Utilisateurs (Sqflite)'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nomController,
                    decoration: const InputDecoration(labelText: 'Nom'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Champ requis' : null,
                  ),
                  TextFormField(
                    controller: _prenomController,
                    decoration: const InputDecoration(labelText: 'Prénom'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Champ requis' : null,
                  ),
                  TextFormField(
                    controller: _paysController,
                    decoration: const InputDecoration(labelText: 'Pays'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _addOrUpdateUser,
                        child: Text(
                            _editingId == null ? 'Ajouter' : 'Mettre à jour'),
                      ),
                      const SizedBox(width: 8),
                      if (_editingId != null)
                        ElevatedButton(
                          onPressed: _clearForm,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey),
                          child: const Text('Annuler'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return ListTile(
                    title: Text('${user.nom} ${user.prenom}'),
                    subtitle: Text('Pays : ${user.pays}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => _editUser(user),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteUser(user.id!),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
