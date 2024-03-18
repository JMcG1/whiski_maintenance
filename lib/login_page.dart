import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'issues_page.dart'; // Assuming this is your main screen after login

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _loginError = '';

  Future<bool> verifyUser(String email, String password) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .where('password', isEqualTo: password) // Storing passwords like this is not secure
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                bool isValidUser = await verifyUser(_emailController.text, _passwordController.text);
                if (isValidUser) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const IssuesPage()),
                  );
                } else {
                  setState(() {
                    _loginError = 'Invalid email or password.';
                  });
                }
              },
              child: const Text('Login'),
            ),
            if (_loginError.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(_loginError, style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}
