import 'package:flutter/material.dart';
import 'package:wuriproject/Api/theme_notifier.dart';
import 'package:wuriproject/Routes/routes.dart';
import 'package:wuriproject/Screens/DarkMode.dart';
import 'package:wuriproject/Screens/FirebaseDemo.dart';
import 'package:wuriproject/Screens/SqfliteDemo.dart';
import 'package:wuriproject/Services/firebase_service.dart';

void main() async {
runApp(MyApp());
 
}

class MyApp extends StatelessWidget {



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
    
      initialRoute: '/',
      routes:routes
      
    );
  }
}

/*void main() async {
runApp(MyApp());
 WidgetsFlutterBinding.ensureInitialized();
   try {
    await FirebaseService.initializeFirebase();
    print('Firebase initialisé avec succès');
  } catch (e) {
    print('Erreur lors de l\'initialisation de Firebase: $e');
  }

  final themeNotifier = await ThemeNotifier.create();
  runApp(MyApp(themeNotifier: themeNotifier));
}*/


/*class MyApp extends StatelessWidget {
  final ThemeNotifier themeNotifier;
  const MyApp({super.key, required this.themeNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: themeNotifier,
      builder: (context, isDark, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/',
          routes: {
         
            '/': (context) =>
                SharedPreferencesDemo(themeNotifier: themeNotifier),
                  '/lite': (context) =>
                  SqfliteDemo(),
                    '/fire': (context) =>
                  FirebaseDemo()
           
          },
        );
      },
    );
  }
}*/


/*
class MyApp extends StatelessWidget {
@override
Widget build(BuildContext context) {
return MaterialApp(
debugShowCheckedModeBanner: false,
home: Scaffold(
appBar: AppBar(
title: Text("Flutter UI Succienctly"),
),
body: Center(
child: Text("Our first flutter layout", style: TextStyle(fontSize: 24),),
),
floatingActionButton: FloatingActionButton(
child: Icon(Icons.ac_unit),
onPressed: (){ print("Oh, it is cold outside"); }),
),
);
}}*/

/*
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connexion',
      debugShowCheckedModeBanner: false,
      home: ConnexionPage(),
    );
  }
}

class ConnexionPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 10)],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                    const Image(width: 400,height: 200,image: AssetImage("images/logo_.png")),
                    /*Image.asset(
                    'images/logo_.png',
                    height: 100,
                    ),
                   
                    Text(
                    'Connexion',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),*/
                    SizedBox(height: 24),
                                TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                        labelText: 'E-mail',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                        if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un e-mail';
                        } else if (!value.contains('@')) {
                        return 'L’e-mail doit contenir @';
                        }
                        return null;
                    },
                    ),

                  SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Veuillez entrer un mot de passe' : null,
                  ),
                  SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Action mot de passe oublié
                      },
                      child: Text('Mot de passe oublié ?'),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Action de connexion
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48),
                      backgroundColor: Colors.blue, 
                      foregroundColor: Colors.white
                    ),
                    child: Text('Connexion'),
                  ),
                  SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      // Action s’inscrire
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48),
                    ),
                    child: Text("S’inscrire"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
*/




