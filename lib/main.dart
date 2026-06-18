import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ecrans/splash/ecran_splash.dart';
import 'ecrans/accueil/ecran_principal.dart';
import 'ecrans/langue/ecran_langue_maternelle.dart';
import 'fournisseurs/progression_fournisseur.dart';
import 'fournisseurs/notification_fournisseur.dart';
import 'fournisseurs/auth_fournisseur.dart';
import 'utils/theme.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase déjà initialisé ou erreur: $e");
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProgressionFournisseur()),
        ChangeNotifierProvider(create: (context) => NotificationFournisseur()),
        ChangeNotifierProvider(create: (context) => AuthFournisseur()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final progression = Provider.of<ProgressionFournisseur>(context);
    return MaterialApp(
      title: 'Codelingo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: progression.estModeSombre ? ThemeMode.dark : ThemeMode.light,
      home: const EcranSplash(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF312E81),
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }
        
        if (snapshot.hasData && snapshot.data != null) {
          return const EcranPrincipal();
        }
        
        return const EcranLangueMaternelle();
      },
    );
  }
}
