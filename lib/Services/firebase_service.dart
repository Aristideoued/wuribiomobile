import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static FirebaseAuth? _auth;
  static FirebaseFirestore? _firestore;

  // Initialisation de Firebase
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;

    // Configuration spécifique pour la base "bado"
    print('Firebase initialisé - Base de données: bado');
  }

  // GETTERS
  static FirebaseAuth get auth => _auth!;
  static FirebaseFirestore get firestore => _firestore!;
  static User? get currentUser => _auth?.currentUser;

  // ===== AUTHENTIFICATION =====

  // Inscription avec email/mot de passe
  static Future<UserCredential> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Erreur lors de l\'inscription: $e');
    }
  }

  // Connexion avec email/mot de passe
  static Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Erreur lors de la connexion: $e');
    }
  }

  // Déconnexion
  static Future<void> signOut() async {
    try {
      await _auth!.signOut();
    } catch (e) {
      throw Exception('Erreur lors de la déconnexion: $e');
    }
  }

  // Vérifier si l'utilisateur est connecté
  static bool isUserLoggedIn() {
    return _auth?.currentUser != null;
  }

  // ===== FIRESTORE - BASE "BADO" =====

  // Ajouter un document dans la base "bado"
  static Future<DocumentReference> addDocument(
      String collection, Map<String, dynamic> data) async {
    try {
      return await _firestore!.collection(collection).add(data);
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du document dans bado: $e');
    }
  }

  // Obtenir un document par ID dans la base "bado"
  static Future<DocumentSnapshot> getDocument(
      String collection, String documentId) async {
    try {
      return await _firestore!.collection(collection).doc(documentId).get();
    } catch (e) {
      throw Exception(
          'Erreur lors de la récupération du document dans bado: $e');
    }
  }

  // Obtenir tous les documents d'une collection dans la base "bado"
  static Future<QuerySnapshot> getCollection(String collection) async {
    try {
      return await _firestore!.collection(collection).get();
    } catch (e) {
      throw Exception(
          'Erreur lors de la récupération de la collection dans bado: $e');
    }
  }

  // Mettre à jour un document dans la base "bado"
  static Future<void> updateDocument(
      String collection, String documentId, Map<String, dynamic> data) async {
    try {
      await _firestore!.collection(collection).doc(documentId).update(data);
    } catch (e) {
      throw Exception(
          'Erreur lors de la mise à jour du document dans bado: $e');
    }
  }

  // Supprimer un document dans la base "bado"
  static Future<void> deleteDocument(
      String collection, String documentId) async {
    try {
      await _firestore!.collection(collection).doc(documentId).delete();
    } catch (e) {
      throw Exception(
          'Erreur lors de la suppression du document dans bado: $e');
    }
  }

  // Écouter les changements d'une collection dans la base "bado"
  static Stream<QuerySnapshot> streamCollection(String collection) {
    return _firestore!.collection(collection).snapshots();
  }

  // Écouter les changements d'un document dans la base "bado"
  static Stream<DocumentSnapshot> streamDocument(
      String collection, String documentId) {
    return _firestore!.collection(collection).doc(documentId).snapshots();
  }

  // ===== MÉTHODES SPÉCIFIQUES POUR LA BASE "BADO" =====

  // Ajouter un utilisateur dans la collection "users"
  static Future<DocumentReference> addUser(
      Map<String, dynamic> userData) async {
    return await addDocument('users', userData);
  }

  // Ajouter un post dans la collection "posts"
  static Future<DocumentReference> addPost(
      Map<String, dynamic> postData) async {
    return await addDocument('posts', postData);
  }

  // Obtenir tous les utilisateurs
  static Future<QuerySnapshot> getUsers() async {
    return await getCollection('users');
  }

  // Obtenir tous les posts
  static Future<QuerySnapshot> getPosts() async {
    return await getCollection('posts');
  }

  // Obtenir les posts d'un utilisateur spécifique
  static Future<QuerySnapshot> getUserPosts(String userId) async {
    try {
      return await _firestore!
          .collection('posts')
          .where('authorId', isEqualTo: userId)
          .get();
    } catch (e) {
      throw Exception(
          'Erreur lors de la récupération des posts utilisateur dans bado: $e');
    }
  }
}
