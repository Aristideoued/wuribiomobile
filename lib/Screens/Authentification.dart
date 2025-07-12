
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wuriproject/Configs/Database/DatabaseHelper.dart';
import 'package:wuriproject/Models/User.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class BiometricAuthPage extends StatefulWidget {
  const BiometricAuthPage({super.key});

  @override
  State<BiometricAuthPage> createState() => _BiometricAuthPageState();
}

class _BiometricAuthPageState extends State<BiometricAuthPage> {
  final dbHelper = DatabaseHelper();
  bool isVerified = false;
  User? verifiedUser;
    Uint8List? _fingerToCompare;


     Future<void> _compareFingerprint() async {
    const channel = MethodChannel('sf370/sdk');
    try {
      final String base64 = await channel.invokeMethod('captureFingerprint');
      final Uint8List imageBytes = base64Decode(base64);
     Image.memory(imageBytes);
            setState(() async {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Empreinte capturée')));

        _fingerToCompare = base64Decode(base64);

      
        
         //await Future.delayed(const Duration(seconds: 5));

    


      });
    } catch (e) {
        //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur de capture')));

      print('Erreur SDK : $e');
    }
      final users = await dbHelper.getAllUsers();
        final matchedUser = users.firstWhere(
          (u) => u.fingerprintData != null && u.fingerprintData!.isNotEmpty,
          orElse: () => User(id: null, firstName: '', lastName: '', createdAt: DateTime(2000)),
        );
      if (matchedUser.id != null && _fingerToCompare != null) {
        setState(() {
          isVerified = true;
          verifiedUser = matchedUser;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucun utilisateur avec empreinte trouvé.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
  }


 Future<void> compareEmpreinte() async {
    final users = await dbHelper.getAllUsers();
    final matchedUser = users.firstWhere(
      (u) => u.fingerprintData != null && u.fingerprintData!.isNotEmpty,
      orElse: () => User(id: null, firstName: '', lastName: '', createdAt: DateTime(2000)),
    );

    if (matchedUser.id != null && _fingerToCompare!=null) {
      setState(() {
        isVerified = true;
        verifiedUser = matchedUser;
      });

   
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun utilisateur avec empreinte trouvé.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
  Future<void> verifierEmpreinte() async {
    final users = await dbHelper.getAllUsers();
    final matchedUser = users.firstWhere(
      (u) => u.fingerprintData != null && u.fingerprintData!.isNotEmpty,
      orElse: () => User(id: null, firstName: '', lastName: '', createdAt: DateTime(2000)),
    );

    if (matchedUser.id != null) {
      setState(() {
        isVerified = true;
        verifiedUser = matchedUser;
      });

     /* ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green[100],
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Empreinte vérifiée avec succès !',
                  style: TextStyle(color: Colors.green)),
            ],
          ),
        ),
      );*/
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun utilisateur avec empreinte trouvé.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Authentification",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isVerified) ...[
                // Section Auth sécurisée
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.shield, color: Colors.blue),
                    title: const Text("Authentification sécurisée"),
                    subtitle: const Text("Utilisez votre empreinte digitale ou Face ID"),
                  ),
                ),
                const SizedBox(height: 16),

                // Section Auth locale
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text("Authentification locale",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        const Text("Utilise l'API biométrique native de l'appareil",
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.fingerprint,
                              size: 60, color: Colors.blue),
                        ),
                        const SizedBox(height: 16),
                           if (_fingerToCompare != null)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Image.memory(_fingerToCompare!),
                           
                          ),
                            const SizedBox(height: 16),

                                    ElevatedButton.icon(
                           onPressed: _compareFingerprint,
                          icon: const Icon(Icons.login, color: Colors.white),
                          label: const Text("S'authentifier",
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                           
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Section Auth module externe
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text("Authentification via module",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        const Text("Utilise le module biométrique externe",
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.sensors,
                              size: 60, color: Colors.green),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: verifierEmpreinte,
                          icon: const Icon(Icons.login, color: Colors.white),
                          label: const Text("Vérifier empreinte",
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                // Notification succès + Affichage user
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Empreinte vérifiée avec succès !',
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600)),
                    ],
                              ),
                            ),
                    const SizedBox(height: 16),
                    if (verifiedUser != null)
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Utilisateur identifié",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: verifiedUser!.photoPath != null
                                  ? CircleAvatar(
                                      backgroundImage: FileImage(File(verifiedUser!.photoPath!)),
                                      radius: 30,
                                    )
                                  : const CircleAvatar(
                                      child: Icon(Icons.person),
                                      radius: 30,
                                    ),
                              title: Text(
                                '${verifiedUser!.firstName} ${verifiedUser!.lastName}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    'Enrôlé le : ${verifiedUser!.createdAt.toLocal().toString().split(' ')[0]}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  if (verifiedUser!.lastLogin != null)
                                    Text(
                                      'Dernière connexion : ${verifiedUser!.lastLogin!.toLocal().toString().split(' ')[0]}',
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  if (verifiedUser!.fingerprintData != null &&
                                      verifiedUser!.fingerprintData!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                                              'Empreinte enregistrée',
                                              style: TextStyle(color: Colors.green),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),


                          ],
                        ),
                      ),
                    ),


                const SizedBox(height: 12),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity, // plein largeur
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    isVerified = false;
                    verifiedUser = null;
                  });
                },
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  'Nouvelle authentification',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),


              ],
            ],
          ),
        ),
      ),
    );
  }
}
