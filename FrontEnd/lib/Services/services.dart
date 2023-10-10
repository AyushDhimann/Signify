import 'package:flutter/widgets.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';

class LocalAuth{
  static final _auth = LocalAuthentication();
  static Future<bool> _canAuthenticate() async => 
    await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
  static Future<bool> authenticate() async{
    try{
      if(! await _canAuthenticate()) return false;
      return await _auth.authenticate(
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Sign in',
            cancelButton: 'Cancel'
          ),
          IOSAuthMessages(
            cancelButton: 'Cancel',
            localizedFallbackTitle: 'Use FaceID to Authenticate'
          )
        ],
        localizedReason: 'Use On-Device Biometrics to Continue',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true
        )
      );
    } catch(e){
      debugPrint('error while authenticating: $e');
      return false;
    }
  }
}