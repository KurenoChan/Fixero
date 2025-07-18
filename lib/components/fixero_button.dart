import 'package:flutter/material.dart';

class FixeroButton extends StatelessWidget {
  final Function? onPressed;
  final String name;
  final bool isRecommended;

  const FixeroButton({
    super.key,
    required this.onPressed,
    required this.name,
    required this.isRecommended
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {} ,
        child: null,
    );
  }
}
