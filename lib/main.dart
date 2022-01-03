import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/components/life_cycle_event_handler.dart';
import 'package:social_media_app/landing/landing_page.dart';
import 'package:social_media_app/screens/mainscreen.dart';
import 'package:social_media_app/services/user_service.dart';
import 'package:social_media_app/utils/config.dart';
import 'package:social_media_app/utils/constants.dart';
import 'package:social_media_app/utils/providers.dart';
import 'package:v_chat_sdk/v_chat_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await VChatController.instance.init(
    baseUrl: Uri.parse("http://170.178.195.150:81"),
    appName: "test_v_chat",
    vChatNotificationType: VChatNotificationType.none,
    enableLogger: true,
    maxMediaUploadSize: 50 * 1000 * 1000,
    passwordHashKey: "passwordHashKey",
    maxGroupChatUsers: 512,
  );
  await Config.initFirebase();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(
      LifecycleEventHandler(
        detachedCallBack: () => UserService().setUserStatus(false),
        resumeCallBack: () => UserService().setUserStatus(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: Consumer<ThemeNotifier>(
        builder: (context, ThemeNotifier notifier, child) {
          return MaterialApp(
            title: Constants.appName,
            debugShowCheckedModeBanner: false,
            theme: notifier.dark ? Constants.darkTheme : Constants.lightTheme,
            home: StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
                if (snapshot.hasData) {
                  return TabScreen();
                } else
                  return Landing();
              },
            ),
          );
        },
      ),
    );
  }
}
