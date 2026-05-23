import 'package:flutter/material.dart';

/// Barra di ricerca riusabile (UC-6).
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.onChanged,
    this.hintText = 'Cerca…',
    this.initialValue,
  });

  final ValueChanged<String> onChanged;
  final String hintText;
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: initialValue == null
          ? null
          : TextEditingController(text: initialValue),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
    );
  }
}
