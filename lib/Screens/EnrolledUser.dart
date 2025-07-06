import 'package:flutter/material.dart';
import 'package:wuriproject/Models/User.dart';
import 'package:wuriproject/Configs/Database/DatabaseHelper.dart';
import 'package:intl/intl.dart';

final formatter = DateFormat('dd/MM/yyyy');

class AllUsersPage extends StatefulWidget {
  const AllUsersPage({Key? key}) : super(key: key);

  @override
  _AllUsersPageState createState() => _AllUsersPageState();
}

class _AllUsersPageState extends State<AllUsersPage> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<User> users = [];
  List<User> filteredUsers = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    getUsersWithFingerprintCount();
  
    searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    searchController.removeListener(_filterUsers);
    searchController.dispose();
    super.dispose();
  }

    int getUsersWithFingerprintCount() {
      return users.where((u) => u.fingerprintData != null && u.fingerprintData!.isNotEmpty).length;
        }
    Future<void> deleteFingerprint(User user) async {
      user.fingerprintData = null;
      await dbHelper.updateUser(user); // Assure-toi d’avoir une méthode updateUser dans ta DBHelper
    }

  Future<void> _loadUsers() async {
    try {
      final loadedUsers = await dbHelper.getAllUsers();
      setState(() {
        users = loadedUsers;
        filteredUsers = loadedUsers;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _confirmDeleteUser(User user) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Supprimer utilisateur'),
      content: Text(
        'Voulez-vous vraiment supprimer ${user.firstName} ${user.lastName} ?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await dbHelper.deleteUser(user.id!); // Ajuste selon ta DB
            _loadUsers(); // Recharge la liste
          },
          child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}


  void _filterUsers() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredUsers = users.where((user) {
        final fullName = '${user.firstName} ${user.lastName}'.toLowerCase();
        return user.firstName.toLowerCase().contains(query) ||
            user.lastName.toLowerCase().contains(query) ||
            fullName.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle:true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Utilisateurs enrollés',
        
         style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        
        ),
        backgroundColor: Colors.blue[800],
        actions: [
    IconButton(
      icon: const Icon(Icons.refresh),
      tooltip: 'Recharger',
      onPressed: () {
        _loadUsers(); // Recharge les utilisateurs depuis la base
      },
    ),
  ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text('Erreur: $error'))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          labelText: 'Rechercher un utilisateur...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${users.length} utilisateurs'
                             ,
                              style: const TextStyle(color: Colors.blue),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${getUsersWithFingerprintCount()} avec empreinte',
                              style: const TextStyle(color: Colors.green),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: filteredUsers.isEmpty
                          ? const Center(child: Text('Aucun utilisateur trouvé'))
                          : ListView.separated(
                              itemCount: filteredUsers.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, index) {
                                final user = filteredUsers[index];
                               return Card(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  elevation: 4,
  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  child: ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    leading: user.photoPath != null
        ? CircleAvatar(backgroundImage: AssetImage(user.photoPath!))
        : const CircleAvatar(child: Icon(Icons.person)),
    title: Text(
      '${user.firstName} ${user.lastName}',
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
    ),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enrôlé le ${user.createdAt.toLocal().toString().split(' ')[0]}',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Text(
          user.lastLogin != null
              ? 'Dernière connexion : ${user.lastLogin!.toLocal().toString().split(' ')[0]}'
              : '',
          style: const TextStyle(color: Colors.grey),
        ),
        if (user.fingerprintData != null && user.fingerprintData!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.fingerprint, size: 16, color: Colors.green),
                  SizedBox(width: 6),
                  Text(
                    'Empreinte',
                    style: TextStyle(color: Colors.green, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
    trailing: PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) async {
        if (value == 'details') {
          showDialog(
            context: context,
            builder: (_) => Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${user.firstName} ${user.lastName}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    user.photoPath != null
                        ? CircleAvatar(
                            radius: 50,
                            backgroundImage: AssetImage(user.photoPath!),
                          )
                        : const CircleAvatar(
                            radius: 50,
                            child: Icon(Icons.person, size: 50),
                          ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nom : ${user.lastName}'),
                        Text('Prénom : ${user.firstName}'),
                        Text('Enrôlé le : ${formatter.format(user.createdAt)}'),
                        Text(
                          user.lastLogin != null
                              ? 'Dernière connexion : ${formatter.format(user.lastLogin!)}'
                              : '',
                        ),
                      ],
                    ),
                    if (user.fingerprintData != null &&
                        user.fingerprintData!.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.fingerprint,
                                size: 16, color: Colors.green),
                            SizedBox(width: 6),
                            Text(
                              'Empreinte enregistrée',
                              style: TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Fermer'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (value == 'delete_fingerprint') {
            await deleteFingerprint(user);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Empreinte supprimée')),
            );
            setState(() {
              _loadUsers(); // Recharge la liste après modif
            });
          }
 else if (value == 'delete_user') {
          _confirmDeleteUser(user);
        }
      },
      itemBuilder: (BuildContext context) {
        final List<PopupMenuEntry<String>> items = [
          PopupMenuItem(
            value: 'details',
            child: Row(
              children: const [
                Icon(Icons.info, color: Colors.blue),
                SizedBox(width: 8),
                Text('Détails'),
              ],
            ),
          ),
        ];

        if (user.fingerprintData != null &&
            user.fingerprintData!.isNotEmpty) {
          items.add(
            PopupMenuItem(
              value: 'delete_fingerprint',
              child: Row(
                children: const [
                  Icon(Icons.fingerprint, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Supprimer empreinte'),
                ],
              ),
            ),
          );
        }

        items.add(
          PopupMenuItem(
            value: 'delete_user',
            child: Row(
              children: const [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 8),
                Text('Supprimer utilisateur'),
              ],
            ),
          ),
        );

        return items;
      },
    ),
  ),
);

                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}
