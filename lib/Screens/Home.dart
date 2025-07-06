import 'package:flutter/material.dart';
import 'package:wuriproject/Configs/Database/DatabaseHelper.dart';
import 'package:wuriproject/Models/User.dart';
import 'package:wuriproject/Screens/EnrolledUser.dart';

class AuthHomePage extends StatefulWidget {
  const AuthHomePage({super.key});

  @override
  _AuthHomePageState createState() => _AuthHomePageState();
}

class _AuthHomePageState extends State<AuthHomePage> {
  late Future<List<User>> futureUsers;
  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  void loadUsers() {
    futureUsers = dbHelper.getAllUsers();
  }

  Future<void> _refreshUsers() async {
    setState(() {
      loadUsers();
    });
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Wuri-Biométrie'),
      backgroundColor: Colors.blue[800],
    ),
    body: RefreshIndicator(
      onRefresh: _refreshUsers, // Méthode à définir pour recharger les utilisateurs
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Section ID Auth
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: const [
                    Icon(Icons.fingerprint, size: 60, color: Colors.blue),
                    SizedBox(height: 12),
                    Text(
                      'ID Auth',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Système d\'authentification biométrique',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.blueGrey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Boutons S'enrôler et S'authentifier
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/enroll');
                      },
                      icon: const Icon(Icons.person_add, size: 24),
                      label: const Column(
                        children: [
                          Text('S\'enrôler'),
                          Text('Nouvel utilisateur', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, "/authentification");
                      },
                      icon: const Icon(Icons.login, size: 24),
                      label: const Column(
                        children: [
                          Text('S\'authentifier'),
                          Text('Accès sécurisé', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Section utilisateurs enrôlés
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FutureBuilder<List<User>>(
                  future: futureUsers,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Erreur : ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Column(
                        children: const [
                          Row(
                            children: [
                              Icon(Icons.people, color: Colors.blue),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Utilisateurs enrôlés (0)',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Icon(Icons.list),
                              SizedBox(width: 4),
                              Text('Voir tout'),
                            ],
                          ),
                          SizedBox(height: 24),
                          Icon(Icons.people_outline, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Aucun utilisateur enrôlé'),
                        ],
                      );
                    } else {
                      final users = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.people, color: Colors.blue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Utilisateurs enrôlés (${users.length})',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                             InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AllUsersPage(),
                              ),
                            );
                          },
                          child: Row(
                            children: const [
                              Icon(Icons.list, color: Colors.blue),
                              SizedBox(width: 4),
                              Text(
                                'Voir tout',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: users.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final user = users[index];
                        return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                leading: user.photoPath != null
                                    ? CircleAvatar(
                                        backgroundImage: AssetImage(user.photoPath!),
                                      )
                                    : const CircleAvatar(
                                        child: Icon(Icons.person),
                                      ),
                                title: Text(
                                  '${user.firstName} ${user.lastName}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  'Enrôlé le ${user.createdAt.toLocal().toString().split(' ')[0]}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                trailing: user.fingerprintData != null && user.fingerprintData!.isNotEmpty
                                    ? const Icon(Icons.fingerprint, color: Colors.green)
                                    : null,
                              ),
                            );


                            },
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

}