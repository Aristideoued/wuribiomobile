import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';

class NetworkTutorialScreen extends StatefulWidget {
  const NetworkTutorialScreen({super.key});

  @override
  _NetworkTutorialScreenState createState() => _NetworkTutorialScreenState();
}

class _NetworkTutorialScreenState extends State<NetworkTutorialScreen> {
  // Variables pour la connectivité
  String connectivityStatus = "Vérification...";
  bool isConnected = false;
  String connectionType = "";

  // Variables pour les requêtes HTTP
  String httpResponse = "";
  bool isLoading = false;
  String errorMessage = "";

  // Contrôleurs pour les formulaires
  final TextEditingController urlController = TextEditingController();
  final TextEditingController postDataController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialiser avec des valeurs par défaut
    urlController.text = "https://jsonplaceholder.typicode.com/posts/1";
    postDataController.text =
        '{"title": "Test Post", "body": "biometric data", "userId": 1}';

    // Vérifier la connectivité au démarrage
    checkConnectivity();

    // Écouter les changements de connectivité
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
        result.forEach((val){
      updateConnectivityStatus(val);

        });
    });
  }

  @override
  void dispose() {
    urlController.dispose();
    postDataController.dispose();
    super.dispose();
  }

  // 1. DÉTECTION NATIVE DE LA CONNECTIVITÉ
  Future<void> checkConnectivity() async {
    try {
      // Méthode native : essayer de se connecter à un serveur(google.com)
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          isConnected = true;
          connectivityStatus = "Connecté (méthode native)";
        });
      }
    } on SocketException catch (_) {
      setState(() {
        isConnected = false;
        connectivityStatus = "Non connecté (méthode native)";
      });
    }
  }

  // 2. DÉTECTION AVEC CONNECTIVITY_PLUS
  Future<void> checkConnectivityWithPackage() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      connectivityResult.forEach((val){
        updateConnectivityStatus(val);
      });
     
    } catch (e) {
      setState(() {
        connectivityStatus = "Erreur: $e";
        isConnected = false;
      });
    }
  }

  void updateConnectivityStatus(ConnectivityResult result) {
    setState(() {
      switch (result) {
        case ConnectivityResult.wifi:
          isConnected = true;
          connectionType = "WiFi";
          connectivityStatus = "Connecté via WiFi";
          break;
        case ConnectivityResult.mobile:
          isConnected = true;
          connectionType = "Mobile";
          connectivityStatus = "Connecté via Mobile";
          break;
        case ConnectivityResult.ethernet:
          isConnected = true;
          connectionType = "Ethernet";
          connectivityStatus = "Connecté via Ethernet";
          break;
        case ConnectivityResult.vpn:
          isConnected = true;
          connectionType = "VPN";
          connectivityStatus = "Connecté via VPN";
          break;
        case ConnectivityResult.bluetooth:
          isConnected = true;
          connectionType = "Bluetooth";
          connectivityStatus = "Connecté via Bluetooth";
          break;
        case ConnectivityResult.other:
          isConnected = true;
          connectionType = "Autre";
          connectivityStatus = "Connecté via autre moyen";
          break;
        case ConnectivityResult.none:
          isConnected = false;
          connectionType = "Aucune";
          connectivityStatus = "Non connecté";
          break;
      }
    });
  }

  // 3. REQUÊTE HTTP GET
  Future<void> makeGetRequest() async {
    if (!isConnected) {
      _showMessage("Pas de connexion internet");
      return;
    }

    setState(() {
      isLoading = true;
      httpResponse = "";
      errorMessage = "";
    });

    try {
      final response = await http.get(
        Uri.parse(urlController.text),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'Flutter App',
        },
      );

      setState(() {
        isLoading = false;
        if (response.statusCode == 200) {
          // Formater la réponse JSON pour l'affichage
          final jsonResponse = json.decode(response.body);
          httpResponse =
              "Status: ${response.statusCode}\n\nHeaders:\n${response.headers}\n\nBody:\n${const JsonEncoder.withIndent('  ').convert(jsonResponse)}";
        } else {
          httpResponse =
              "Erreur HTTP: ${response.statusCode}\n\n${response.body}";
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Erreur réseau: $e";
      });
    }
  }

  // 4. REQUÊTE HTTP POST
  Future<void> makePostRequest() async {
    if (!isConnected) {
      _showMessage("Pas de connexion internet");
      return;
    }

    setState(() {
      isLoading = true;
      httpResponse = "";
      errorMessage = "";
    });

    try {
      final response = await http.post(
        Uri.parse('https://jsonplaceholder.typicode.com/posts'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'Flutter App',
        },
        body: postDataController.text,
      );

      setState(() {
        isLoading = false;
        if (response.statusCode == 201) {
          final jsonResponse = json.decode(response.body);
          httpResponse =
              "Status: ${response.statusCode} (Créé)\n\nHeaders:\n${response.headers}\n\nBody:\n${const JsonEncoder.withIndent('  ').convert(jsonResponse)}";
        } else {
          httpResponse =
              "Erreur HTTP: ${response.statusCode}\n\n${response.body}";
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Erreur réseau: $e";
      });
    }
  }

  // 5. GESTION DES ERREURS RÉSEAU
  Future<void> testNetworkErrors() async {
    setState(() {
      isLoading = true;
      httpResponse = "";
      errorMessage = "";
    });

    try {
      // Test avec un timeout court
      final response = await http.get(
        Uri.parse('https://gethttpstatus.com/404'),
        headers: {'User-Agent': 'Flutter App'},
      ).timeout(const Duration(seconds: 5));

      setState(() {
        isLoading = false;
        httpResponse =
            "Test d'erreur 404:\nStatus: ${response.statusCode}\nBody: ${response.body}";
      });
    } on SocketException catch (e) {
      setState(() {
        isLoading = false;
        errorMessage =
            "Erreur de socket: $e\n\nCauses possibles:\n• Pas de connexion internet\n• Serveur inaccessible\n• Problème DNS";
      });
    } on TimeoutException catch (e) {
      setState(() {
        isLoading = false;
        errorMessage =
            "Timeout: $e\n\nCauses possibles:\n• Connexion lente\n• Serveur surchargé\n• Problème réseau";
      });
    } on FormatException catch (e) {
      setState(() {
        isLoading = false;
        errorMessage =
            "Erreur de format: $e\n\nCauses possibles:\n• Réponse malformée\n• JSON invalide\n• Encodage incorrect";
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Erreur inattendue: $e";
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
        title: const Text('Gestion Réseau & HTTP'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // SECTION CONNECTIVITÉ
            _buildSectionTitle("1. DÉTECTION DE LA CONNECTIVITÉ"),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          isConnected ? Icons.wifi : Icons.wifi_off,
                          color: isConnected ? Colors.green : Colors.red,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            connectivityStatus,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isConnected ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (connectionType.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text("Type: $connectionType",
                          style: const TextStyle(fontSize: 14)),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: checkConnectivity,
                            icon: const Icon(Icons.network_check),
                            label: const Text('Méthode Native'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: checkConnectivityWithPackage,
                            icon: const Icon(Icons.wifi),
                            label: const Text('Package'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // SECTION REQUÊTES HTTP
            _buildSectionTitle("2. REQUÊTES HTTP"),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: urlController,
                      decoration: const InputDecoration(
                        labelText: 'URL pour GET',
                        border: OutlineInputBorder(),
                        hintText: 'https://api.example.com/data',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isLoading ? null : makeGetRequest,
                            icon: const Icon(Icons.download),
                            label: const Text('GET'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isLoading ? null : makePostRequest,
                            icon: const Icon(Icons.upload),
                            label: const Text('POST'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // SECTION DONNÉES POST
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Données pour POST:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: postDataController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '{"key": "value"}',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // SECTION GESTION D'ERREURS
            _buildSectionTitle("3. GESTION DES ERREURS RÉSEAU"),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : testNetworkErrors,
                      icon: const Icon(Icons.error_outline),
                      label: const Text('Tester les Erreurs'),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Types d\'erreurs gérées:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildErrorType(
                        'SocketException', 'Pas de connexion internet'),
                    _buildErrorType('TimeoutException', 'Requête trop lente'),
                    _buildErrorType('FormatException', 'Données malformées'),
                    _buildErrorType('HttpException', 'Erreur HTTP'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // SECTION RÉPONSE
            if (isLoading)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Chargement...'),
                    ],
                  ),
                ),
              ),

            if (httpResponse.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Réponse HTTP:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(
                          httpResponse,
                          style:
                              const TextStyle(fontFamily: 'monospace', fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (errorMessage.isNotEmpty)
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Erreur:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                      const SizedBox(height: 8),
                      Text(errorMessage,
                          style: TextStyle(color: Colors.red[800])),
                    ],
                  ),
                ),
              ),
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
          color: Colors.green[800],
        ),
      ),
    );
  }

  Widget _buildErrorType(String type, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error, color: Colors.orange, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}