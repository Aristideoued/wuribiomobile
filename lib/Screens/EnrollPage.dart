import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:wuriproject/Configs/Database/DatabaseHelper.dart';
import 'package:wuriproject/Models/User.dart';
import 'package:wuriproject/Services/FingerPrintService.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EnrollPage extends StatefulWidget {
  const EnrollPage({super.key});

  @override
  State<EnrollPage> createState() => _EnrollPageState();
}

class _EnrollPageState extends State<EnrollPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  File? _photo;
  String? _fingerprintData;
  Uint8List? _fingerprintBytes;


  final dbHelper = DatabaseHelper();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);

    if (picked != null) {
      setState(() {
        _photo = File(picked.path);
      });
    }
  }

  
    Future<void> _captureFingerprint() async {
    const channel = MethodChannel('sf370/sdk');
    try {
      final String base64 = await channel.invokeMethod('captureFingerprint');
      final Uint8List imageBytes = base64Decode(base64);
      Image.memory(imageBytes);
            setState(() {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Empreinte capturée')));

        _fingerprintBytes = base64Decode(base64);
      });
    } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur de capture')));

      print('Erreur SDK : $e');
    }
  }
 /* Future<void>_captureFingerprint() async{
      final data = await FingerprintService.captureFingerprint();
    if (data != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Empreinte capturée')));
      print("Données : $data");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur de capture')));
    }
  }*/

  /*Future<void> _captureFingerprint() async {
    final LocalAuthentication auth = LocalAuthentication();
    final isAvailable = await auth.canCheckBiometrics;
    // _fingerprintData = 'authenticated';

    if (!isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biométrie non disponible')),
      );
      return;
    }
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biométrie disponible')),
      );

    final authenticated = await auth.authenticate(
      localizedReason: 'Veuillez scanner votre empreinte',
      options: const AuthenticationOptions(biometricOnly: true),
    );

    if (authenticated) {
      setState(() {
        _fingerprintData = 'authenticated';
      });
    }
  }*/

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = User(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      photoPath: _photo?.path,
      fingerprintData: _fingerprintBytes,
      createdAt: DateTime.now(),
    );

    await dbHelper.insertUser(user);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Utilisateur enrôlé avec succès')),
    );

    Navigator.pop(context); // retour à l’accueil
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enrôlement',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green,
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.person_add, size: 40, color: Colors.green),
                    SizedBox(height: 8),
                    Text(
                      "Enrôlement d'un nouvel utilisateur",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Remplissez les informations et capturez l'empreinte",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Informations personnelles",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Prénom *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Photo",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _photo != null ? FileImage(_photo!) : null,
                  backgroundColor: Colors.grey[300],
                  child: _photo == null
                      ? const Icon(Icons.camera_alt, size: 40)
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Empreinte digitale",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
                if (_fingerprintBytes != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.memory(_fingerprintBytes!),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _captureFingerprint,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Capturer empreinte'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text("S'enrôler"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
