import 'package:flutter/material.dart';
import 'package:flutter_website/Authentication/login.dart';
import 'package:flutter_website/Authentication/register.dart';
import 'package:flutter_website/Home/home.dart';
import 'package:flutter_website/Introduction/introduction_animation_screen.dart';
import 'package:flutter_website/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  User? user = FirebaseAuth.instance.currentUser;
  runApp(MyApp(user: user));
}

class MyApp extends StatelessWidget {
  final User? user;
  const MyApp({
    super.key,
    required this.user,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wearable Device Analytics',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      routes: {
        'home': (context) =>
            const MyHomePage(title: 'Wearable Device Analytics'),
        'register': (context) => const RegistrationScreen(),
        'login': (context) => const LoginScreen(),
        'dashboard': (context) => const HomePage(),
        'intro': (context) => const IntroductionAnimationScreen(),
        // 'blood_pressure': (context) => BloodPressureScreen(),
      },
      initialRoute: (user == null) ? 'intro' : 'dashboard',
      home: const HomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold());
  }
}
