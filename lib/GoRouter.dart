import 'package:go_router/go_router.dart';
import 'package:wuriproject/ImageInterface.dart';
import 'package:wuriproject/Login.dart';
import 'package:wuriproject/MediaInterface.dart';
import 'package:wuriproject/Persistance.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => NetworkTutorialScreen(),
       routes: [
      GoRoute(
        path: "/image",
        builder: (context, state) =>  ImageFetcherScreen(),
      ),

    ],
    ),
    
   /* GoRoute(
      path: '/image',
      builder: (context, state) => ImageFetcherScreen(),
    ),*/
    GoRoute(
      path: '/media',
      builder: (context, state) => MediaTutorialScreen(),
    )
  ],
);
