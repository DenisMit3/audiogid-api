import 'package:flutter/material.dart';

class OfflineProgressIndicator extends StatelessWidget {
  final double progress;
  final String? label;

  const OfflineProgressIndicator(
      {super.key, required this.progress, this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
        ],
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
