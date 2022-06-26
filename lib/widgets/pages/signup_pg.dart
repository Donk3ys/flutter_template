import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants.dart';
import 'package:flutter_frontend/core/util_core.dart';
import 'package:flutter_frontend/data_models/user.dart';
import 'package:flutter_frontend/view_providers/_providers.dart';
import 'package:flutter_frontend/widgets/buttons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   leading: BackButton(
      //     onPressed: () => context.pop(),
      //   ),
      // ),
      body: Consumer(
        builder: (context, watch, child) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text('Sign Up', style: TextStyle(fontSize: 40.0)),
                      const SizedBox(
                        height: 40.0,
                      ),
                      const Center(
                        child: SizedBox(
                          width: 300.0,
                          child: SignupFormController(),
                        ),
                      ),
                      const SizedBox(height: 40.0),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          const Text("Have an account? "),
                          TextButton(
                            onPressed: () async => context.go("/login"),
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
        },
      ),
    );
  }
}

class SignupFormController extends ConsumerStatefulWidget {
  const SignupFormController({Key? key}) : super(key: key);

  @override
  _SignupFormControllerState createState() => _SignupFormControllerState();
}

class _SignupFormControllerState extends ConsumerState<SignupFormController> {
  final _formKey = GlobalKey<FormState>();

  List<String> _usernameSuggestionList = [];
  bool _hidePassword = true;
  bool _hideCheckPassword = true;
  // final bool _termsCheck = false;
  // bool _ageCheck = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  // To be disposed
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  final _focusNodeEmail = FocusNode();
  final _focusNodePassword = FocusNode();
  final _focusNodePasswordConfirm = FocusNode();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();

    _focusNodeEmail.dispose();
    _focusNodePassword.dispose();
    _focusNodePasswordConfirm.dispose();
    super.dispose();
  }

  // @override
  // void initState() {
  //   WidgetsBinding.instance.addPostFrameCallback((_) async {
  //   });
  //
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextFormField(
            autovalidateMode: _autovalidateMode,
            validator: (value) {
              return value == null || value.isEmpty
                  ? kFieldNotEnteredMessage
                  : null;
            },
            onChanged: (username) async {
              if (username.length == 4) {
                // TODO: CHECK USERNAME
                // _usernameSuggestionList =
                //     await authVm.checkUsernameValid(username);
                // setState(() {});
              } else {
                _onUsernameChangeHandler(username);
              }
            },
            onEditingComplete: () => _focusNodeEmail.requestFocus(),
            decoration: InputDecoration(
              hintText: 'username (min 4 characters)',
              prefixIcon: Icon(
                _usernameSuggestionList.isNotEmpty ||
                        _usernameOnStoppedTyping != null ||
                        _usernameController.text.trim().isEmpty
                    ? Icons.verified_user_outlined
                    : Icons.verified_user,
                color: _usernameController.text.trim().isEmpty
                    ? Colors.grey
                    : _usernameSuggestionList.isNotEmpty
                        ? kColorError
                        : kColorSuccess,
              ),
              // suffixIcon: authVm.isCheckingUsername
              //     ? const SizedBox(
              //         height: 24.0,
              //         width: 24.0,
              //         child: Center(
              //           child: SizedBox(
              //             height: 24.0,
              //             width: 24.0,
              //             child: CircularProgressIndicator(
              //               strokeWidth: 1.8,
              //             ),
              //           ),
              //         ),
              //       )
              //     : null,
            ),
            autofocus: true,
            controller: _usernameController,
          ),
          if (_usernameSuggestionList.isNotEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "The username you entered has already used been used.",
                style: TextStyle(color: Colors.red),
              ),
            ),
          // if (_usernameSuggestionList.isNotEmpty)
          //   SizedBox(
          //     height: 40.0,
          //     child: ListView.builder(
          //       scrollDirection: Axis.horizontal,
          //       itemCount: _usernameSuggestionList.length,
          //       itemBuilder: (context, index) {
          //         final suggestion =
          //             _usernameSuggestionList.elementAt(index);
          //         return TextButton(
          //           key: UniqueKey(),
          //           onPressed: () {
          //             _usernameController.text = suggestion;
          //             setState(() {});
          //           },
          //           child: Text(suggestion),
          //         );
          //       },
          //     ),
          //   ),
          TextFormField(
            autovalidateMode: _autovalidateMode,
            validator: (value) {
              return isEmail(value)
                  ? null
                  : "Please enter a vaild email address!";
            },
            onEditingComplete: () => _focusNodePassword.requestFocus(),
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'email',
              prefixIcon: Icon(
                Icons.mail_outline,
                //                    color: TEXT_COLOR,
              ),
            ),
            // autofocus: true,
            focusNode: _focusNodeEmail,
            controller: _emailController,
          ),
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
            onEditingComplete: () => _focusNodePasswordConfirm.requestFocus(),
            decoration: InputDecoration(
              hintText: 'password (min 6 characters)',
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
            focusNode: _focusNodePassword,
            obscureText: _hidePassword,
            controller: _passwordController,
          ),
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
            focusNode: _focusNodePasswordConfirm,
            obscureText: _hideCheckPassword,
            controller: _passwordConfirmController,
          ),
          const SizedBox(height: 30.0),
          // HtmlWidget(_termsHtml),
          // SizedBox(
          //   width: 260,
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       Checkbox(
          //         activeColor: kColorAccent,
          //         checkColor: Colors.white,
          //         value: _termsCheck,
          //         onChanged: (checked) => checked != null
          //             ? setState(() {
          //                 _termsCheck = checked;
          //               })
          //             : null,
          //       ),
          //       const SizedBox(width: 8.0),
          //       TextButton(
          //         onPressed: () async => Navigator.of(context).push(
          //           MaterialPageRoute(
          //             builder: (context) => const TermsConditionsPage(),
          //           ),
          //         ),
          //         child: const Text("Accept Terms and Conditions"),
          //       ),
          //     ],
          //   ),
          // ),
          // SizedBox(
          //   width: 260,
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       Checkbox(
          //         activeColor: kColorAccent,
          //         checkColor: Colors.white,
          //         value: _ageCheck,
          //         onChanged: (checked) => checked != null
          //             ? setState(() {
          //                 _ageCheck = checked;
          //               })
          //             : null,
          //       ),
          //       const SizedBox(width: 8.0),
          //       const Padding(
          //         padding: EdgeInsets.all(8.0),
          //         child: Text("I'm over the age of 13 years   "),
          //       ),
          //     ],
          //   ),
          // ),
          const SizedBox(height: 40.0),
          LoadingButton(
            label: "SIGN UP",
            onSubmit: () => _submit(),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    // if (!_termsCheck) {
    //   InfoSnackBar.showError(
    //     context,
    //     "Please confirm you have read the terms and conditions",
    //   );
    //   return;
    // }
    // if (!_ageCheck) {
    //   InfoSnackBar.showError(
    //     context,
    //     "Please confirm you are over the age of 13 years",
    //   );
    //   return;
    // }

    _autovalidateMode = AutovalidateMode.onUserInteraction;
    setState(() {});
    if (_formKey.currentState!.validate()) {
      final user = User(
        uuid: "",
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        profileImageUrl: '',
        createdAt: DateTime.now(),
        status: UserStatus.activated,
      );
      await ref.read(currentUserProvider.notifier).signUpUser(context, user);
    }
    _passwordController.clear();
    _passwordConfirmController.clear();
    _focusNodePassword.requestFocus();
  }

  //  final _termsHtml = """
  // <div>
  // 	<h1>Terms of Service</h1>
  // 	<p>By signing up for Sportee, you accept our Privacy Policy and agree not to:</p>
  // 	<ul>
  // 			<li>Use our service to send spam or scam users.</li>
  // 			<li>Promote violence on publicly viewable Sportee channels, etc.</li>
  // 			<li>Post illegal pornographic content on publicly viewable Sportee channels, etc.</li>
  // 	</ul>
  // 	<p>We reserve the right to update these Terms of Service later.</p>
  // 	<p>Citizens of EU countries and the United Kingdom must be at least 16 years old to sign up.</p>
  // 	</div>
  // 	""";
  //

  Timer? _usernameOnStoppedTyping;
  void _onUsernameChangeHandler(String username) {
    const duration = Duration(milliseconds: 800);
    if (_usernameOnStoppedTyping != null) {
      setState(() => _usernameOnStoppedTyping?.cancel()); // clear timer
    }

    _usernameOnStoppedTyping = Timer(duration, () async {
      if (username.isEmpty || username.length == 4) return;
      // _usernameSuggestionList = await _pgCtrl.checkUsernameValid(username);
      _usernameSuggestionList = ["name"];
      _usernameOnStoppedTyping = null;
      setState(() {});
    });
  }
}
