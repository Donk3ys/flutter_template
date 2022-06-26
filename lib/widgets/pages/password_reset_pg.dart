import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants.dart';
import 'package:flutter_frontend/core/util_core.dart';
import 'package:flutter_frontend/view_providers/_providers.dart';
import 'package:flutter_frontend/widgets/buttons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({Key? key}) : super(key: key);
  @override
  _PasswordResetPageState createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  bool _hasCode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(bottom: 50.0),
                  child: Text(
                    'Password Reset',
                    style: TextStyle(
                      fontSize: 40.0,
                    ), //color: TEXT_COLOR
                  ),
                ),
                SizedBox(
                  width: 360.0,
                  child: !_hasCode
                      ? PassWordResetEmailForm(
                          onHasCode: (hasCode) =>
                              setState(() => _hasCode = hasCode),
                        )
                      : const PasswordResetPasswordFormController(),
                ),
                const SizedBox(height: 40.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (_hasCode)
                      TextButton(
                        onPressed: () async => setState(() => _hasCode = false),
                        child: const Text(
                          "Get new code",
                          style: TextStyle(
                            color: kColorAccent,
                            fontStyle: FontStyle.italic,
                            // decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    if (!_hasCode)
                      TextButton(
                        onPressed: () async => setState(() => _hasCode = true),
                        child: const Text(
                          "I have a code",
                          style: TextStyle(
                            color: kColorAccent,
                            fontStyle: FontStyle.italic,
                            // decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text("I remember my password "),
                    TextButton(
                      // onPressed: () async => context.go("/login"),
                      onPressed: () async => Navigator.pop(context),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: kColorAccent,
                          fontStyle: FontStyle.italic,
                          // decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PassWordResetEmailForm extends ConsumerStatefulWidget {
  final Function(bool) onHasCode;
  const PassWordResetEmailForm({super.key, required this.onHasCode});

  @override
  _PassWordResetEmailFormState createState() => _PassWordResetEmailFormState();
}

class _PassWordResetEmailFormState
    extends ConsumerState<PassWordResetEmailForm> {
  final _formKey = GlobalKey<FormState>();

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  final emailFocusNode = FocusNode();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    emailFocusNode.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 20.0),
          TextFormField(
            autovalidateMode: _autovalidateMode,
            validator: (value) {
              return isEmail(value)
                  ? null
                  : "Please enter a vaild email address!";
            },
            style: const TextStyle(fontSize: 18.0),
            decoration: const InputDecoration(
              hintText: 'email',
              prefixIcon: Icon(
                Icons.mail_outline,
              ),
            ),
            onChanged: (_) => setState(() {}),
            onFieldSubmitted: (_) => _submit(),
            focusNode: emailFocusNode,
            autofocus: true,
            autofillHints: const [AutofillHints.email],
            controller: _emailController,
          ),
          const SizedBox(height: 16.0),
          Wrap(
            children: [
              Text(
                "Enter email for the account you want to reset the password for and a recovery code will be sent to that email",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 50.0),
          LoadingButton(label: "SEND EMAIL", onSubmit: _submit)
        ],
      ),
    );
  }

  Future<void> _submit() async {
    _autovalidateMode = AutovalidateMode.onUserInteraction;
    setState(() {});
    if (_formKey.currentState!.validate()) {
      final hasCode =
          await ref.read(currentUserProvider.notifier).passwordResetRequest(
                context,
                _emailController.text.trim(),
              );
      emailFocusNode.requestFocus();
      if (hasCode) widget.onHasCode(true);
      _emailController.clear();
    }
  }
}

class PasswordResetPasswordFormController extends ConsumerStatefulWidget {
  const PasswordResetPasswordFormController({
    super.key,
  });

  @override
  _PasswordResetPasswordFormControllerState createState() =>
      _PasswordResetPasswordFormControllerState();
}

class _PasswordResetPasswordFormControllerState
    extends ConsumerState<PasswordResetPasswordFormController> {
  final _formKey = GlobalKey<FormState>();
  bool _hidePassword = true;
  bool _hideCheckPassword = true;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _pinPutController = TextEditingController();
  final _pinPutFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final retypePwFocusNode = FocusNode();

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _pinPutController.dispose();
    _pinPutFocusNode.dispose();
    passwordFocusNode.dispose();
    retypePwFocusNode.dispose();
    super.dispose();
  }

  PinTheme _pinPutTheme(double radius, {bool isError = false}) {
    return PinTheme(
      height: 60.0,
      width: 60.0,
      decoration: BoxDecoration(
        border: Border.all(color: isError ? kColorError : kColorAccent),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Enter Code",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 30.0),
            Pinput(
              // forceErrorState: true,
              length: 6,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return kFieldNotEnteredMessage;
                } else if (value.trim().length < 6) {
                  return "Please enter the full code";
                }
                return null;
              },
              focusNode: _pinPutFocusNode,
              controller: _pinPutController,
              submittedPinTheme: _pinPutTheme(40.0),
              errorPinTheme: _pinPutTheme(0.0, isError: true),
              disabledPinTheme: _pinPutTheme(0.0),
              defaultPinTheme: _pinPutTheme(10.0),
              followingPinTheme: _pinPutTheme(10.0),
              focusedPinTheme: _pinPutTheme(10.0),
              // onSubmit: (String pin) => _showSnackBar(pin, context),
              onSubmitted: (_) => passwordFocusNode.requestFocus(),
              autofocus: true,
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              autovalidateMode: _autovalidateMode,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return kFieldNotEnteredMessage;
                } else if (value.trim().length < 6) {
                  return kPasswordNotLongEnough;
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'new password (min 6 characters)',
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  //                    color: TEXT_COLOR,
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
              onFieldSubmitted: (_) => retypePwFocusNode.requestFocus(),
              focusNode: passwordFocusNode,
              obscureText: _hidePassword,
              controller: _passwordController,
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              autovalidateMode: _autovalidateMode,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return kFieldNotEnteredMessage;

                  // Check passwords match
                } else if (checkPasswordsMatch(
                  value.trim(),
                  _passwordController.text.trim(),
                )) {
                  return kPasswordMissMatch;
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'retype password',
                prefixIcon: const Icon(
                  Icons.lock_open,
//                    color: TEXT_COLOR,
                ),
                suffixIcon: GestureDetector(
                  onTap: () async => setState(
                    () => _hideCheckPassword = !_hideCheckPassword,
                  ),
                  child: Icon(
                    _hideCheckPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              onFieldSubmitted: (_) => _submit(),
              focusNode: retypePwFocusNode,
              obscureText: _hideCheckPassword,
              controller: _passwordConfirmController,
            ),
            const SizedBox(height: 50.0),
            LoadingButton(
              label: "RESET PASSWORD",
              onSubmit: () => _submit(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    // final code = _pinPutController.text.trim();
    // if (code.isEmpty || code.length < 6) {
    //   InfoSnackBar.showError(
    //     context,
    //     "Please enter the code sent to your email",
    //   );
    //   return;
    // }
    _autovalidateMode = AutovalidateMode.onUserInteraction;
    setState(() {});
    if (_formKey.currentState!.validate()) {
      await ref.read(currentUserProvider.notifier).passwordReset(
            context,
            _passwordController.text.trim(),
            _pinPutController.text.trim(),
          );
    }
    // _passwordController.clear();
    // _passwordConfirmController.clear();
  }
}
