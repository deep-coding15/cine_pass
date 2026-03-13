import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:cine_pass_client/cine_pass_client.dart';

class SignInPage extends StatelessWidget {
  final Client client;

  const SignInPage({required this.client, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SignInWidget(
        client: client,
        onAuthenticated: () {
          // Do something when the user is authenticated.
          //
          // NOTE: You should not navigate to the home screen here, otherwise
          // the user will have to sign in again every time they open the app.
        },
        onError: (error) {
          // Handle errors
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        },
      ),
    );
  }
}