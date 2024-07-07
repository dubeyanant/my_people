// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// Future<void> nativeGoogleSignIn() async {
//   try {
//     final webClientId = dotenv.env['WEB_CLIENT_ID'];
//     final iosClientId = dotenv.env['IOS_CLIENT_ID'];

//     final GoogleSignIn googleSignIn = GoogleSignIn(
//       clientId: iosClientId,
//       serverClientId: webClientId,
//     );
//     final googleUser = await googleSignIn.signIn();
//     if (googleUser == null) {
//       throw 'Google Sign-In was cancelled by the user';
//     }

//     final googleAuth = await googleUser.authentication;
//     final accessToken = googleAuth.accessToken;
//     final idToken = googleAuth.idToken;

//     if (accessToken == null) {
//       throw 'No Access Token found.';
//     }
//     if (idToken == null) {
//       throw 'No ID Token found.';
//     }

//     final supabase = Supabase.instance.client;

//     final response = await supabase.auth.signInWithIdToken(
//       provider: OAuthProvider.google,
//       idToken: idToken,
//       accessToken: accessToken,
//     );

//     print('User signed in with Google: ${response.user?.email}');
//   } catch (error) {
//     print('Error signing in with Google: $error');
//     // Handle the error appropriately (e.g., show an error message to the user)
//   }
// }
