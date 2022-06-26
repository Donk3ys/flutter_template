import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants.dart';

class LoadingButton extends StatefulWidget {
  final String label;
  final Future<void> Function() onSubmit;
  const LoadingButton({super.key, required this.label, required this.onSubmit});

  @override
  _LoadingButtonState createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    if (_submitting) return const CircularProgressIndicator();
    return ElevatedButton(
      onPressed: () async {
        setState(() {
          _submitting = true;
        });

        await widget.onSubmit();

        setState(() {
          _submitting = false;
        });
      },
      style: ElevatedButton.styleFrom(primary: kColorAccent),
      child: Text(
        widget.label,
        style:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
    );
  }
}
