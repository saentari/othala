import 'package:flutter/material.dart';

// A Widget wrapping a [CircularProgressIndicator] in [Center].
class LoadingIndicator extends StatelessWidget {
  final Color color;

  const LoadingIndicator(this.color, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      );
}
