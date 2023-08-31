import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pillprompt/screens/pillbox_screen.dart';
import 'package:pillprompt/screens/taking_screen.dart';
import 'package:pillprompt/services/notification_services.dart';
import 'screens/home_screen.dart';

const String defaultChannelId = 'pillprompt_notification_channel';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  initializeNotifications();
  FirebaseMessaging.onMessage.listen(onMessageHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/pillbox_screen': (context) => const PillBoxScreen(),
        '/taking_screen': (context) => const TakingScreen(),
      },
      debugShowCheckedModeBanner: false,
      title: 'PillPrompt',
      theme: ThemeData(primarySwatch: Colors.cyan),
    );
  }
}
