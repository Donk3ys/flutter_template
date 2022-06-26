import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  final String? message;
  const ErrorPage({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late String formattedMessage;
    if (message == null || message!.contains("no routes for location")) {
      formattedMessage = "Page not found!";
    } else {
      formattedMessage = message!;
    }

    return Scaffold(
      // appBar: AppBar(
      //   // title: const Text("Login"),
      //   backgroundColor: kColorBackgroundDark,
      //   leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      // ),

      // backgroundColor: kColorBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Error !',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 20.0),
            Text(
              formattedMessage,
            ),
          ],
        ),
      ),
    );
  }
}
