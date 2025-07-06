

import 'package:wuriproject/Configs/Database/DatabaseHelper.dart';
import 'package:wuriproject/Models/User.dart';

final DatabaseHelper dbHelper = DatabaseHelper();

///  Ajouter un nouvel utilisateur
Future<void> createUser(String firstName, String lastName) async {
  final user = User(
    firstName: firstName,
    lastName: lastName,
    createdAt: DateTime.now(),
  );

  await dbHelper.insertUser(user);
}

///  Récupérer tous les utilisateurs
Future<List<User>> fetchAllUsers() async {
  return await dbHelper.getAllUsers();
}

///  Mettre à jour un utilisateur (ex : mise à jour lastLogin)
Future<void> updateUserLastLogin(int userId) async {
  final user = await dbHelper.getUserById(userId);

  if (user != null) {
    user.lastLogin = DateTime.now();
    await dbHelper.updateUser(user);
  }
}

///  Récupérer un utilisateur par ID
Future<User?> fetchUserById(int userId) async {
  return await dbHelper.getUserById(userId);
}

/// Supprimer un utilisateur
Future<void> deleteUserById(int userId) async {
  await dbHelper.deleteUser(userId);
}




