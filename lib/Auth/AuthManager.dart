import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hr_project_flutter/General/Common.dart';
import 'package:hr_project_flutter/General/FileIO.dart';
import 'package:hr_project_flutter/General/Logger.dart';
import 'package:hr_project_flutter/General/TDIUser.dart';
import 'package:package_info/package_info.dart';

enum GOOGLE_AUTH_RESULT {
  SUCCESS,
  FAILED,
  ERROR_EMAIL,
}

class AuthManager {
  static final AuthManager _instance = AuthManager._internal();

  factory AuthManager() {
    return _instance;
  }

  AuthManager._internal();

  final FirebaseAuth _fbAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  User? _fbCurUser;
  String? _urlPhoto;
  String? _googleIDToken;
  String? _lastError;
  String? get urlPhoto => _urlPhoto;
  String? get googleIDToken => _googleIDToken;

  set lastError(String? value) {
    _lastError = value;
    slog.i("auth/last error : $_lastError");
  }

  String? get lastError {
    String? returnValue = _lastError;
    _lastError = null;
    return returnValue;
  }

  Future<GOOGLE_AUTH_RESULT> googleSingIn(String fcmToken) async {
    try {
      print('111111>>>>>>${fcmToken}');
      // google login
      final GoogleSignInAccount? gUser = await _googleSignIn.signIn();
      if (gUser == null) {
        return GOOGLE_AUTH_RESULT.FAILED;
      }
      final GoogleSignInAuthentication gAuth = await gUser.authentication;
      final OAuthCredential gCredential =
      GoogleAuthProvider.credential(accessToken: gAuth.accessToken, idToken: gAuth.idToken);

      // google과 firebase 연동
      final User? fUser = (await _fbAuth.signInWithCredential(gCredential)).user;
      _fbCurUser = _fbAuth.currentUser;
      assert(fUser!.uid == _fbCurUser!.uid);
      _googleIDToken = await fUser!.getIdToken();

      // TDI Groupware login
      String platformOS = OS_TYPE.NONE.convertString;
      if (Platform.isAndroid == true) {
        platformOS = OS_TYPE.AOS.convertString;
      } else if (Platform.isIOS) {
        platformOS = OS_TYPE.IOS.convertString;
      }
      PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
        kAppName = packageInfo.appName;
        kPackageName = packageInfo.packageName;
        kAppVersion = packageInfo.version;
        kBuildNumber = packageInfo.buildNumber;
      });
      TDIUser.account = TDIAccount(PROVIDERS.google, fcmToken, fUser.email!, fUser.displayName!, platformOS,kAppVersion);
      var response = await Dio().post(URL.tdiAuth, data: TDIUser.account!.toJson());

      if (response.statusCode == 200) {
        TDIUser.token = TDIToken.formJson(response.data);

        writeJSON(TDIUser.fileAccountJson, TDIUser.account!.toJson());
        writeJSON(TDIUser.fileTokenJson, TDIUser.token!.toJson());

        _urlPhoto = fUser.photoURL;

        slog.i("auth/user info : ${TDIUser.account!.toJson()}");
        slog.i("auth/token:" + TDIUser.token!.token);
      } else {
        slog.e(response);
        return GOOGLE_AUTH_RESULT.ERROR_EMAIL;
      }

      return GOOGLE_AUTH_RESULT.SUCCESS;
    } on Exception catch (e) {
      slog.e(e.toString());
      List<String> result = e.toString().split(", ");
      lastError = result[0];
      googleSignOut();
      return GOOGLE_AUTH_RESULT.ERROR_EMAIL;
    }
  }

  Future<void> googleSignOut() async {
    await _fbAuth.signOut();
    await _googleSignIn.signOut();

    _urlPhoto = "";
    _googleIDToken = "";

    slog.i("auth/sign out");
  }
}
