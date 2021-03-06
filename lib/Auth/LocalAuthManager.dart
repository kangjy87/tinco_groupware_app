import 'package:flutter/services.dart';
import 'package:hr_project_flutter/General/Common.dart';
import 'package:hr_project_flutter/General/Logger.dart';
import 'package:local_auth_device_credentials/auth_strings.dart';
import 'package:local_auth_device_credentials/local_auth.dart';

enum BIO_SURPPORT {
  UNKNOWN,
  SUPPORTED,
  UNSUPPORTED,
}

enum LOCAL_AUTH_RESULT {
  NO_AUTHORIZE,
  SUCCESS,
  FAILED,
}

class LocalAuthManager {
  static final LocalAuthManager _instance = LocalAuthManager._internal();

  factory LocalAuthManager() {
    return _instance;
  }

  LocalAuthManager._internal();

  final LocalAuthentication _auth = LocalAuthentication();
  BIO_SURPPORT _supportState = BIO_SURPPORT.UNKNOWN;
  bool _canCheckBiometrics = false;
  List<BiometricType>? _availableBiometics = <BiometricType>[];
  bool _authenticated = false;
  bool _authenticating = false;
  LOCAL_AUTH_RESULT _authResult = LOCAL_AUTH_RESULT.NO_AUTHORIZE;
  String? _lastError = "";

  BIO_SURPPORT get supportState => _supportState;
  LOCAL_AUTH_RESULT get authResult => _authResult;
  bool get authenticated => _authenticated;
  bool get authenticating => _authenticating;

  set lastError(String? value) {
    _lastError = value;
    slog.i("local auth/last error : $_lastError");
  }

  String? get lastError {
    String? err = _lastError;
    _lastError = null;
    return err;
  }

  Future<void> initialize() async {
    await _checkDeviceSupported();
    await _checkBiometrics();
    await _checkAvailableBiometrics();
  }

  Future<void> _checkDeviceSupported() async {
    try {
      await _auth.isDeviceSupported().then((value) {
        _supportState = value ? BIO_SURPPORT.SUPPORTED : BIO_SURPPORT.UNSUPPORTED;
        return value;
      });
    } on PlatformException catch (e) {
      slog.i(e);
      _supportState = BIO_SURPPORT.UNKNOWN;
      lastError = "Error - ${e.message}";
    }

    slog.i("local auth/support state $_supportState");
  }

  Future<void> _checkBiometrics() async {
    try {
      _canCheckBiometrics = await _auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      slog.i(e);
      _canCheckBiometrics = false;
      lastError = "Error - ${e.message}";
    }

    slog.i("local auth/can biometrics $_canCheckBiometrics");
  }

  Future<void> _checkAvailableBiometrics() async {
    try {
      _availableBiometics = await _auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      slog.i(e);
      _availableBiometics = <BiometricType>[];
      lastError = "Error - ${e.message}";
    }

    _availableBiometics!.forEach((element) => slog.i("local auth/available biometic ${element.toString()}"));
  }

  Future<LOCAL_AUTH_RESULT> authenticate() async {
    try {
      _authenticating = true;
      _authenticated = await _auth
          .authenticate(
        localizedReason: STRINGS.authenticate,
        useErrorDialogs: true,
        stickyAuth: true,
        sensitiveTransaction: true,
        androidAuthStrings: AndroidAuthMessages(signInTitle: STRINGS.tdiGroupware, biometricHint: " "),
        // biometricOnly: true,
      )
          .then((value) {
        _authenticating = false;
        slog.i("local auth/authenticated : $value");
        return value;
      });
    } on PlatformException catch (ex) {
      slog.i(ex);
      _authenticated = false;
      _authenticating = false;
      _authResult = LOCAL_AUTH_RESULT.NO_AUTHORIZE;
      lastError = 'Error - ${ex.message}';
      slog.i("local aith/result : $_authResult");
      return _authResult;
    }

    _authResult = _authenticated ? LOCAL_AUTH_RESULT.SUCCESS : LOCAL_AUTH_RESULT.FAILED;
    slog.i("local aith/result : $_authResult");
    return _authResult;
  }

  void cancelAuthentication() async {
    await _auth.stopAuthentication();
    _authenticated = false;
    _authenticating = false;
  }
}
