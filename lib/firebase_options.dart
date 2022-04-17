import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC6WAfWCjymUU2r8jvSJ_eKjIDv6c-pQmw',
    appId: '1:674820347185:android:64623cfab22805385a4c10',
    messagingSenderId: '674820347185',
    projectId: 'moodalyse',
    storageBucket: 'moodalyse.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC6WAfWCjymUU2r8jvSJ_eKjIDv6c-pQmw',
    appId: '1:674820347185:android:64623cfab22805385a4c10',
    messagingSenderId: '674820347185',
    projectId: 'moodalyse',
    storageBucket: 'moodalyse.appspot.com',
    iosClientId: '674820347185-mg1s474va9o57ju14i8qiq0vsu5iurim.apps.googleusercontent.com',
    iosBundleId: 'com.jelleglebbeek.moodalyse',
  );
}
