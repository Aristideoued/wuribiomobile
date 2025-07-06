import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
/*
void main() {
  runApp(ImageFromUrlApp());
}

class ImageFromUrlApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Viewer',
      debugShowCheckedModeBanner: false,
      home: ImageFetcherScreen(),
    );
  }
}
*/
class ImageFetcherScreen extends StatefulWidget {
  @override
  _ImageFetcherScreenState createState() => _ImageFetcherScreenState();
}

class _ImageFetcherScreenState extends State<ImageFetcherScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _imageUrl;

  void _loadImage() {
    final url = _controller.text.trim();
    if (url.isNotEmpty) {
      setState(() {
        _imageUrl = url;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Afficher l'image",style: TextStyle(
                color: Colors.white,          
                fontWeight: FontWeight.bold,   
                fontSize: 18,  
                              
              )),
        backgroundColor: Colors.blueAccent,
        centerTitle: true 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text(
                "Image URL:",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Entrez l’URL de l’image',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),

            
            SizedBox(height: 16),
           
            if (_imageUrl != null)
              Expanded(
                  child: ClipRRect(
                          borderRadius: BorderRadius.circular(16), 
                          child: Image.network(
                            _imageUrl!,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Column(
                              children: [
                                Icon(Icons.error, color: Colors.red),
                                Text('Impossible de charger l’image.'),
                              ],
                            ),
                          ),
                        ))
                                        /*Image.network(
                  _imageUrl!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Column(
                    children: [
                      Icon(Icons.error, color: Colors.red),
                      Text('Impossible de charger l’image.'),
                    ],
                  ),
                ),
              )*/,

                              ElevatedButton(
                  onPressed: _loadImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    minimumSize: Size(20, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Afficher',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

                SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Bouton Précédent
                    ElevatedButton(
                      onPressed: () {
                        context.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        minimumSize: Size(120, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Précédent',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    // Bouton Suivant
                    ElevatedButton(
                      onPressed: () {
                        context.go("/media");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        minimumSize: Size(120, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Suivant',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                          ], 
        ),
      ),
    );
  }
}
