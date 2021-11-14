import 'package:chat/data/message_dao.dart';
import 'package:chat/ui/message_list.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Add MultiProvider
    return MultiProvider(
      providers: [
        // TODO: Add ChangeNotifierProvider<UserDao> here
        Provider<MessageDao>(
          create: (_) => MessageDao(),
          lazy: false,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Chat',
        theme: ThemeData(primarySwatch: Colors.blue),
        // TODO: Add Consumer<UserDao> here
        home: const MessageList(),
      ),
    );
  }
}
