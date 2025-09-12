import 'package:flutter/material.dart';

class FixeroDropdown extends StatelessWidget {
  final List<String> options;
  final String selectedOption;
  final ValueChanged<String> onChanged;

  const FixeroDropdown({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DropdownButton<String>(
      value: selectedOption,
      items: options.map((option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },

      isExpanded: true,
      icon: const Icon(Icons.arrow_drop_down),
      dropdownColor: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(10),
      underline: const SizedBox(),
    );
  }
}