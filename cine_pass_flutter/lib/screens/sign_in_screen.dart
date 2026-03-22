import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../main.dart';

class SignInScreen extends StatefulWidget {
  final Widget child;
  const SignInScreen({super.key, required this.child});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isSignedIn = false;

  @override
  void initState() {
    super.initState();
    // Listen to authentication state changes
    client.auth.authInfoListenable.addListener(_updateSignedInState);
    _isSignedIn = client.auth.isAuthenticated;
  }

  // Don't forget to remove the listener when the widget is disposed.
  @override
  void dispose() {
    client.auth.authInfoListenable.removeListener(_updateSignedInState);
    super.dispose();
  }

  void _updateSignedInState() {
    setState(() {
      _isSignedIn = client.auth.isAuthenticated;
    });
  }

  Future<bool> signOutDevice() async {
    return await client.auth.signOutDevice();
  }

  Future<bool> signOutAllDevices() async {
    return await client.auth.signOutAllDevices();
  }

  AuthSuccess getAuthInfo() {
    final authInfo = client.auth.authInfo;
    if (authInfo is AuthSuccess) {
      return authInfo;
    } else {
      throw Exception('User is not authenticated');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isSignedIn
        ? widget.child
        : Center(
            child: SignInWidget(
              client: client,
              onAuthenticated: () {
                context.showSnackBar(
                  message: 'User authenticated.',
                  backgroundColor: Colors.green,
                );
              },
              onError: (error) {
                context.showSnackBar(
                  message: 'Authentication failed: $error',
                  backgroundColor: Colors.red,
                );
              },
            ),
          );
  }
}

extension on BuildContext {
  void showSnackBar({
    required String message,
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
