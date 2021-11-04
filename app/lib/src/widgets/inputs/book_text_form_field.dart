import 'package:flutter/material.dart';

class BookTextFormField extends StatelessWidget {
  final String labelText;
  final String errorText;
  final void Function(String?)? onSaved;
  final String? initialValue;

  const BookTextFormField({
    Key? key,
    required this.labelText,
    required this.errorText,
    required this.onSaved,
    this.initialValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      style: Theme.of(context).textTheme.caption?.copyWith(
            fontSize: 16.0,
            color: Theme.of(context).textTheme.headline6?.color,
          ),
      decoration: InputDecoration(
          labelText: labelText,
          errorStyle: const TextStyle(
            fontSize: 15.0,
            height: 0.9,
          ),
          labelStyle: const TextStyle(color: Colors.grey)),
      validator: (value) {
        if ((value?.isEmpty ?? false) || (value?.trim().isEmpty ?? false)) {
          return errorText;
        }
        return null;
      },
      onSaved: onSaved,
    );
  }
}
