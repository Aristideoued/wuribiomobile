import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/*void main() {
  runApp(MyFavPlaceApp());
}

class MyFavPlaceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyFavPlace',
      debugShowCheckedModeBanner: false,
      home: WelcomePage(),
    );
  }
}*/

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF512DA8), // fond violet
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo principal
              Image.asset(
                'images/logo_.png',
                height: 100,
              ),
              SizedBox(height: 24),

              // Titre principal
            /*  Text(
                'MyFavPlace',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
*/
              // Texte de description
              Text(
                'MyFavPlace is an application to save and find\nquickly your favorite places.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),

              // Bouton Facebook
              ElevatedButton(
                onPressed: () {
                  // Action Facebook
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'images/face.png',
                      height: 24,
                    ),
                    SizedBox(width: 12),
                    Text('Connect with Facebook'),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Bouton Google
              ElevatedButton(
                onPressed: () {
                  
                  // Action Google
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'images/google.png',
                      height: 24,
                    ),
                    SizedBox(width: 12),
                    Text('Connect with Google'),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Lien "Do you have an account ? Connect"
              GestureDetector(
                onTap: () {
                  // Action vers login
                },
                child: RichText(
                  text: TextSpan(
                    text: 'Do you have an account ? ',
                    style: TextStyle(color: Colors.white),
                    children: [
                      TextSpan(
                        text: 'Connect',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Lien "continue without connecting"
              TextButton(
                onPressed: () {
                  context.go( "/image");
                  // Continuer sans compte
                },
                child: Text(
                  'continue without connecting',
                  style: TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
