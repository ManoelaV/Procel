import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyBWEv0IphqCMobutRW0dYoua7oHa0JcSNw",
            authDomain: "diabetes-app-2-dhvrsv.firebaseapp.com",
            projectId: "diabetes-app-2-dhvrsv",
            storageBucket: "diabetes-app-2-dhvrsv.appspot.com",
            messagingSenderId: "670726744771",
            appId: "1:670726744771:web:93eb955ddfc3773f745076"));
  } else {
    await Firebase.initializeApp();
  }
}
