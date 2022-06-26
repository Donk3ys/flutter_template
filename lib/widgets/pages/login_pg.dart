import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants.dart';
import 'package:flutter_frontend/view_providers/_providers.dart';
import 'package:flutter_frontend/widgets/buttons.dart';
import 'package:flutter_frontend/widgets/pages/password_reset_pg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   // title: const Text("Login"),
      //   backgroundColor: kColorBackgroundDark,
      //   leading: BackButton(onPressed: () => context.pop()),
      // ),

      // backgroundColor: kColorBackground,
      body: Center(
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 40.0,
                  ), //color: TEXT_COLOR
                ),
                const SizedBox(
                  height: 40.0,
                ),
                const Center(
                  child: SizedBox(width: 300.0, child: LoginFormController()),
                ),
                const SizedBox(height: 40.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Expanded(
                      child: Text("No account?", textAlign: TextAlign.right),
                    ),
                    const SizedBox(width: 4.0),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () async => context.push("/signup"),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: kColorAccent,
                              fontStyle: FontStyle.italic,
                              // decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Expanded(
                      child: Text(
                        "Forgot password?",
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () async => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const PasswordResetPage(),
                            ),
                          ),
                          child: const Text(
                            ' Password Reset',
                            style: TextStyle(
                              color: kColorAccent,
                              fontStyle: FontStyle.italic,
                              // decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                //   onPressed: () async => context.push("/terms"),
                //   child: const Text(
                //     'Terms & Conditions',
                //     style: TextStyle(
                //       color: kColorAccent,
                //       fontStyle: FontStyle.italic,
                //       // decoration: TextDecoration.underline,
                //     ),
                //   ),
                // ),
                // TextButton(
                //   onPressed: () async => context.push("/contact"),
                //   child: const Text(
                //     'Contact Support',
                //     style: TextStyle(
                //       color: kColorAccent,
                //       fontStyle: FontStyle.italic,
                //       // decoration: TextDecoration.underline,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginFormController extends ConsumerStatefulWidget {
  const LoginFormController();
  @override
  _LoginFormControllerState createState() => _LoginFormControllerState();
}

class _LoginFormControllerState extends ConsumerState<LoginFormController> {
  final _formKey = GlobalKey<FormState>();
  bool _hidePassword = true;

  final _focusNodeEmail = FocusNode();
  final _focusNodePassword = FocusNode();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _focusNodeEmail.dispose();
    _focusNodePassword.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            validator: (value) {
              return value == null ? kFieldNotEnteredMessage : null;
            },
            style: const TextStyle(fontSize: 18.0),
            decoration: const InputDecoration(
              hintText: 'email',
              prefixIcon: Icon(
                Icons.mail_outline,
              ),
            ),
            onFieldSubmitted: (_) {
              if (_passwordController.text.isNotEmpty &&
                  _emailController.text.isNotEmpty) {
                _submit();
              } else if (_passwordController.text.isEmpty) {
                _focusNodePassword.requestFocus();
              }
            },
            focusNode: _focusNodeEmail,
            autofocus: true,
            autofillHints: const [AutofillHints.email],
            controller: _emailController,
          ),
          const SizedBox(height: 10.0),
          TextFormField(
            validator: (value) {
              return value == null ? kFieldNotEnteredMessage : null;
            },
            style: const TextStyle(fontSize: 18.0),
            decoration: InputDecoration(
              hintText: 'password',
              prefixIcon: const Icon(
                Icons.lock_outline,
              ),
              suffixIcon: GestureDetector(
                onTap: () async =>
                    setState(() => _hidePassword = !_hidePassword),
                child: Icon(
                  _hidePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            onFieldSubmitted: (_) => _submit(),
            focusNode: _focusNodePassword,
            obscureText: _hidePassword,
            autofillHints: const [AutofillHints.password],
            controller: _passwordController,
          ),
          const SizedBox(height: 50.0),
          LoadingButton(
            label: "LOGIN",
            onSubmit: () => _submit(),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(currentUserProvider.notifier).loginUser(
            context,
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
      _passwordController.clear();
      _focusNodeEmail.requestFocus();
    }
  }
}
