import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:native_notify/native_notify.dart';
import 'package:biometric_storage/biometric_storage.dart';


// void main() {
//
//
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Biometric Auth',
//       theme: ThemeData(
//         primarySwatch: Colors.grey,
//       ),
//       home: const MyHomePage(title: 'Biometric Auth page'),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key, required this.title}) : super(key: key);
//   final String title;
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   final LocalAuthentication _localAuthentication = LocalAuthentication();
//   bool _canCheckBiometric = false;
//   String _authorizedOrNot = "Not Authorized";
//
//   // List<BiometricType> _availableBiometricTypes = List<BiometricType>();
//   List<BiometricType> _availableBiometricTypes = <BiometricType>[];
//
//   Future<void> _checkBiometric() async {
//     bool canCheckBiometric = false;
//     try {
//       _canCheckBiometric = await _localAuthentication.canCheckBiometrics;
//     } on PlatformException catch (e) {
//       print(e);
//     }
//     if (!mounted) return;
//     setState(() {
//       _canCheckBiometric = canCheckBiometric;
//     });
//   }
//
//   Future<void> _getListOfBiometricTypes() async {
//     List<BiometricType> listOfBiometrics;
//     try {
//       listOfBiometrics = await _localAuthentication.getAvailableBiometrics();
//     } on PlatformException catch (e) {
//       print(e);
//     }
//     if (!mounted) return;
//     setState(() {
//       _availableBiometricTypes = listOfBiometrics;
//     });
//   }
//
//   Future<void> _authorizeNow() async {
//     bool isAuthorized = false;
//     try {
//        isAuthorized = await _localAuthentication.authenticate(         //authenticateWithBiometrics
//         localizedReason: 'Please authenticate to get next page',
//         // useErrorDialogs: true,
//         // stickyAuth: true,
//         //  Iterable authMessages = const[IOSAuthMessage[] ,AndroidAuthMessage[]],
//         // AuthenticationOptions options = const AuthenticationOptions()
//       );
//     } on PlatformException catch (e) {
//       print(e);
//     }
//     if (!mounted) return
//     setState(() {
//       if (isAuthorized) {
//         _authorizedOrNot = "Authorized";
//       } else {
//         _authorizedOrNot = "Not Authorized";
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text("Check Biometric : $_canCheckBiometric"),
//             ElevatedButton(
//               onPressed: _checkBiometric,
//               child: Text("Check Biometric"),
//
//             ),
//             Text("List Of Biometric :${_availableBiometricTypes.toString()}"),
//             ElevatedButton(
//               onPressed: _getListOfBiometricTypes,
//               child: Text("List of Biometric Types"),
//
//             ),
//             Text("Authorized : $_authorizedOrNot"),
//             ElevatedButton(
//               onPressed: _authorizeNow,
//               child: Text("Authorize now"),
//
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NativeNotify.initialize(1700, 'b44HT0osqbVUUGwzxfvGGG', null, null);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    auth.isDeviceSupported().then(
          (bool isSupported) => setState(() => _supportState = isSupported
          ? _SupportState.supported
          : _SupportState.unsupported),
    );
  }

  Future<void> _checkBiometrics() async {
    late bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    }
    on PlatformException catch (e) {
      canCheckBiometrics = true;
      print(e);
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _getAvailableBiometrics() async {
    late List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      availableBiometrics = <BiometricType>[];
      print(e);
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        localizedReason: 'Let OS determine authentication method',
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );
      setState(() {
        _isAuthenticating = true;
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Error - ${e.message}';
      });
      return;
    }
    if (!mounted) {
      return;
    }
    setState(
            () => _authorized = authenticated ? 'Authorized' : 'Not Authorized');
  }

  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        localizedReason:
        'Scan your fingerprint (or face or whatever) to authenticate',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true,
          sensitiveTransaction: false,
        ),
      );
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.message}';
      });
      return;
    }
    if (!mounted) {
      return;
    }
    final String message = authenticated ? 'Authorized' : 'Not Authorized';
    setState(() {
      _authorized = message;
    });
  }

  Future<void> _cancelAuthentication() async {
    await auth.stopAuthentication();
    setState(() => _isAuthenticating = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: ListView(
          padding: const EdgeInsets.only(top: 30),
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                //null we put unknown
                if (_supportState == _SupportState.unknown)
                  const CircularProgressIndicator()
                else if (_supportState == _SupportState.supported)
                  const Text('This device is supported')
                else
                  const Text('This device is not supported'),
                const Divider(height: 100),
                Text('Can check biometrics: $_canCheckBiometrics\n'),
                ElevatedButton(
                  onPressed: _checkBiometrics,
                  child: const Text('Check biometrics'),
                ),
                const Divider(height: 100),
                Text('Available biometrics: $_availableBiometrics\n'),
                ElevatedButton(
                  onPressed: _getAvailableBiometrics,
                  child: const Text('Get available biometrics'),
                ),
                const Divider(height: 100),
                Text('Current State: $_authorized\n'),
                if (_isAuthenticating)
                  ElevatedButton(
                    onPressed: _cancelAuthentication,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const <Widget>[
                        Text('Cancel Authentication'),
                        Icon(Icons.cancel),
                      ],
                    ),
                  )
                else
                  Column(
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: _authenticate,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const <Widget>[
                            Text('Authenticate'),
                            Icon(Icons.perm_device_information),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _authenticateWithBiometrics,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(_isAuthenticating
                                ? 'Cancel'
                                : 'Authenticate: biometrics only'),
                            const Icon(Icons.fingerprint),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _SupportState {
  unknown,
  supported,
  unsupported,
}
