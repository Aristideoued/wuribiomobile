import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wuriproject/Services/firebase_service.dart';


class FirebaseDemo extends StatefulWidget {
  const FirebaseDemo({super.key});

  @override
  _FirebaseDemoState createState() => _FirebaseDemoState();
}

class _FirebaseDemoState extends State<FirebaseDemo> {
  // Variables pour l'authentification
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String authMessage = "";
  User? currentUser;
  bool showSignIn = true; // true = Connexion, false = Inscription

  // Variables pour Firestore
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  List<Map<String, dynamic>> posts = [];
  List<Map<String, dynamic>> users = [];
  bool isLoadingPosts = false;
  bool isLoadingUsers = false;

  // Contrôleurs pour l'ajout manuel d'utilisateur
  final TextEditingController addUserEmailController = TextEditingController();
  final TextEditingController addUserNameController = TextEditingController();
  bool isAddingUser = false;

  @override
  void initState() {
    super.initState();
    // Initialiser avec des valeurs de test
    emailController.text = "test@bado.com";
    passwordController.text = "password123";
    titleController.text = "Mon premier post sur Bado";
    contentController.text = "Contenu du post pour la base de données Bado";

    // Vérifier si un utilisateur est déjà connecté
    currentUser = FirebaseService.currentUser;
    if (currentUser != null) {
      _loadPosts();
      _loadUsers();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    titleController.dispose();
    contentController.dispose();
    addUserEmailController.dispose();
    addUserNameController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    setState(() {
      authMessage = ""; // Efface l'ancien message
    });
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() {
        authMessage = "Veuillez remplir tous les champs";
      });
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      final userCredential = await FirebaseService.signUpWithEmailAndPassword(
        emailController.text,
        passwordController.text,
      );
      await FirebaseService.addUser({
        'uid': userCredential.user!.uid,
        'email': userCredential.user!.email,
        'displayName': userCredential.user!.displayName ?? 'Utilisateur Bado',
        'createdAt': DateTime.now().toIso8601String(),
        'lastLogin': DateTime.now().toIso8601String(),
      });
      setState(() {
        currentUser = FirebaseService.currentUser;
        authMessage = "Inscription réussie dans Bado !";
      });
      _loadUsers();
      _showMessage("Inscription réussie dans Bado !");
    } catch (e) {
      setState(() {
        authMessage = "Erreur d'inscription: $e";
      });
      _showMessage("Erreur d'inscription: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _signIn() async {
    setState(() {
      authMessage = ""; // Efface l'ancien message
    });
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() {
        authMessage = "Veuillez remplir tous les champs";
      });
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      await FirebaseService.signInWithEmailAndPassword(
        emailController.text,
        passwordController.text,
      );
      setState(() {
        currentUser = FirebaseService.currentUser;
        authMessage = "Connexion réussie à Bado !";
      });
      _loadPosts();
      _loadUsers();
      _showMessage("Connexion réussie à Bado !");
    } catch (e) {
      setState(() {
        authMessage = "Erreur de connexion: $e";
      });
      _showMessage("Erreur de connexion: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseService.signOut();
      setState(() {
        currentUser = null;
        posts.clear();
        users.clear();
        authMessage = "Déconnexion réussie de Bado";
      });
      _showMessage("Déconnexion réussie de Bado");
    } catch (e) {
      _showMessage("Erreur de déconnexion: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // ===== FIRESTORE - BASE "BADO" =====

  Future<void> _addPost() async {
    if (titleController.text.isEmpty || contentController.text.isEmpty) {
      _showMessage("Veuillez remplir le titre et le contenu");
      return;
    }

    if (currentUser == null) {
      _showMessage("Vous devez être connecté pour ajouter un post");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseService.addPost({
        'title': titleController.text,
        'content': contentController.text,
        'authorId': currentUser!.uid,
        'authorEmail': currentUser!.email,
        'createdAt': DateTime.now().toIso8601String(),
        'database': 'bado',
      });

      // Vider les champs
      titleController.clear();
      contentController.clear();

      _loadPosts();
      _showMessage("Post ajouté avec succès dans Bado !");
    } catch (e) {
      _showMessage("Erreur lors de l'ajout du post: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadPosts() async {
    setState(() {
      isLoadingPosts = true;
    });

    try {
      final querySnapshot = await FirebaseService.getPosts();
      setState(() {
        posts = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            ...data,
          };
        }).toList();
      });
    } catch (e) {
      _showMessage("Erreur lors du chargement des posts: $e");
    } finally {
      setState(() {
        isLoadingPosts = false;
      });
    }
  }

  Future<void> _loadUsers() async {
    setState(() {
      isLoadingUsers = true;
    });

    try {
      final querySnapshot = await FirebaseService.getUsers();
      setState(() {
        users = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            ...data,
          };
        }).toList();
      });
    } catch (e) {
      _showMessage("Erreur lors du chargement des utilisateurs: $e");
    } finally {
      setState(() {
        isLoadingUsers = false;
      });
    }
  }

  Future<void> _deletePost(String postId) async {
    try {
      await FirebaseService.deleteDocument('posts', postId);
      _loadPosts();
      _showMessage("Post supprimé avec succès de Bado");
    } catch (e) {
      _showMessage("Erreur lors de la suppression: $e");
    }
  }

  Future<void> _editPost(Map<String, dynamic> post) async {
    final TextEditingController editTitleController =
        TextEditingController(text: post['title']);
    final TextEditingController editContentController =
        TextEditingController(text: post['content']);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier la note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editTitleController,
                decoration: const InputDecoration(labelText: 'Titre'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: editContentController,
                decoration: const InputDecoration(labelText: 'Contenu'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
    if (result == true) {
      try {
        await FirebaseService.updateDocument(
          'posts',
          post['id'],
          {
            'title': editTitleController.text,
            'content': editContentController.text,
          },
        );
        _showMessage('Note modifiée avec succès');
        _loadPosts();
      } catch (e) {
        _showMessage('Erreur lors de la modification : $e');
      }
    }
  }

  // Ajout d'un utilisateur manuel
  Future<void> _addUserManually() async {
    if (addUserEmailController.text.isEmpty ||
        addUserNameController.text.isEmpty) {
      _showMessage("Veuillez remplir l'email et le nom");
      return;
    }
    setState(() {
      isAddingUser = true;
    });
    try {
      await FirebaseService.addUser({
        'email': addUserEmailController.text,
        'displayName': addUserNameController.text,
        'createdAt': DateTime.now().toIso8601String(),
        'lastLogin': null,
      });
      addUserEmailController.clear();
      addUserNameController.clear();
      _showMessage('Utilisateur ajouté avec succès');
      _loadUsers();
    } catch (e) {
      _showMessage('Erreur lors de l\'ajout de l\'utilisateur : $e');
    } finally {
      setState(() {
        isAddingUser = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase - Base Bado'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle("FIREBASE"),
            if (currentUser == null) ...[
              // Boutons Connexion/Inscription
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showSignIn = true;
                        authMessage = "";
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          showSignIn ? Colors.blue : Colors.grey[300],
                      foregroundColor: showSignIn ? Colors.white : Colors.black,
                    ),
                    child: const Text('Connexion'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showSignIn = false;
                        authMessage = "";
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          !showSignIn ? Colors.blue : Colors.grey[300],
                      foregroundColor:
                          !showSignIn ? Colors.white : Colors.black,
                    ),
                    child: const Text('Inscription'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Formulaire selon le mode
              if (showSignIn) ...[
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : _signIn,
                  icon: const Icon(Icons.login),
                  label: const Text('Se connecter'),
                ),
              ] else ...[
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : _signUp,
                  icon: const Icon(Icons.person_add),
                  label: const Text("S'inscrire"),
                ),
              ],
              if (authMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: authMessage.contains('Erreur')
                        ? Colors.red[50]
                        : Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    authMessage,
                    style: TextStyle(
                      color: authMessage.contains('Erreur')
                          ? Colors.red[800]
                          : Colors.green[800],
                    ),
                  ),
                ),
              ],
            ] else ...[
              // Utilisateur connecté
              Row(
                children: [
                  const Text("Bienvenue, ",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(currentUser!.email ?? '',
                      style: const TextStyle(color: Colors.blue)),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle("Ajouter un utilisateur"),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: addUserEmailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: addUserNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nom',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: isAddingUser ? null : _addUserManually,
                        icon: const Icon(Icons.person_add),
                        label: isAddingUser
                            ? const Text('Ajout...')
                            : const Text('Ajouter utilisateur'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle("Liste des utilisateurs"),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Utilisateurs enregistrés:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: _loadUsers,
                            icon: const Icon(Icons.refresh),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (isLoadingUsers)
                        const Center(child: CircularProgressIndicator())
                      else if (users.isEmpty)
                        const Center(
                          child: Text(
                            'Aucun utilisateur trouvé',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      else
                        ...users.map((user) => _buildUserCard(user)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle("Ajouter une note"),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Titre du post',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: contentController,
                        decoration: const InputDecoration(
                          labelText: 'Contenu du post',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.content_paste),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: isLoading ? null : _addPost,
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter un post'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle("Mes notes"),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Notes enregistrées:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: _loadPosts,
                            icon: const Icon(Icons.refresh),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (isLoadingPosts)
                        const Center(child: CircularProgressIndicator())
                      else if (posts.isEmpty)
                        const Center(
                          child: Text(
                            'Aucune note trouvée',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      else
                        ...posts.map((post) => _buildPostCard(post)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    user['email'] ?? 'Email inconnu',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Nom: ${user['displayName'] ?? 'Non défini'}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'Créé: ${user['createdAt'] ?? 'Inconnu'}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.note, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    post['title'] ?? 'Titre inconnu',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                // Bouton éditer
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  tooltip: 'Modifier',
                  onPressed: () => _editPost(post),
                ),
                // Bouton supprimer
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Supprimer',
                  onPressed: () => _deletePost(post['id']),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              post['content'] ?? '',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'Créé: ${post['createdAt'] ?? 'Inconnu'}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
