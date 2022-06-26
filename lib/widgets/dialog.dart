import 'package:flutter/material.dart';
import 'package:flutter_frontend/core/constants.dart';

class ConfirmDialog extends StatelessWidget {
  final String titleText;
  final String bodyText;
  const ConfirmDialog({
    Key? key,
    required this.bodyText,
    required this.titleText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.error_outline),
          const SizedBox(width: 16.0),
          Text(titleText),
        ],
      ),
      content: SizedBox(
        width: 260.0,
        child: Text(bodyText),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            "Cancel",
            style: TextStyle(color: kColorSecondaryText),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text(
            "Confirm",
          ),
        ),
      ],
    );
  }
}
