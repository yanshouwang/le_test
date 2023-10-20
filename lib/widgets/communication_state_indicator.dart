import 'package:flutter/material.dart' hide ConnectionState;
import 'package:le_test/models.dart';

class CommunicationStateIndicator extends StatelessWidget {
  final ConnectionState state;
  final bool writing;
  final Size? size;

  const CommunicationStateIndicator({
    super.key,
    required this.state,
    required this.writing,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final color = state == ConnectionState.disconnected
        ? Colors.red
        : state == ConnectionState.connecting
            ? Colors.orange
            : writing
                ? Colors.purple
                : Colors.green;
    final width = size?.width;
    final height = size?.height;
    return Container(
      decoration: ShapeDecoration(
        shape: const CircleBorder(),
        gradient: RadialGradient(
          colors: [
            color,
            color.shade100,
          ],
          stops: const [
            0.5,
            0.6,
          ],
        ),
      ),
      width: width,
      height: height,
    );
  }
}
