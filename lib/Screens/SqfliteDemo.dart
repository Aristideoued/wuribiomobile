import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Note {
  final int? id;
  final String content;
  Note({this.id, required this.content});

  Map<String, dynamic> toMap() => {'id': id, 'content': content};
  static Note fromMap(Map<String, dynamic> map) =>
      Note(id: map['id'], content: map['content']);
}

class SqfliteDemo extends StatefulWidget {
  const SqfliteDemo({super.key});

  @override
  _SqfliteDemoState createState() => _SqfliteDemoState();
}

class _SqfliteDemoState extends State<SqfliteDemo> {
  Database? _db;
  List<Note> _notes = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initDb();
  }

  Future<void> _initDb() async {
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, 'notes.db'),
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE notes(id INTEGER PRIMARY KEY AUTOINCREMENT, content TEXT)');
      },
      version: 1,
    );
    _refreshNotes();
  }

  Future<void> _refreshNotes() async {
    final List<Map<String, dynamic>> maps = await _db!.query('notes');
    setState(() {
      _notes = maps.map((e) => Note.fromMap(e)).toList();
    });
  }

  Future<void> _addNote(String content) async {
    await _db!.insert('notes', {'content': content});
    _controller.clear();
    _refreshNotes();
  }

  Future<void> _deleteNote(int id) async {
    await _db!.delete('notes', where: 'id = ?', whereArgs: [id]);
    _refreshNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sqflite Demo'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration:
                        const InputDecoration(hintText: 'Nouvelle note'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _addNote(_controller.text),
                  child: const Text('Ajouter'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  final note = _notes[index];
                  return ListTile(
                    title: Text(note.content),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteNote(note.id!),
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
