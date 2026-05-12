import 'package:flutter/material.dart';
import '../theme/eom_colors.dart';

/// The five cognitive intents available to the user.
enum CognitiveIntent {
  clarify(
    label: 'Clarify',
    icon: Icons.lightbulb_outline,
    description: 'Untangle what you mean',
    color: EomColors.accent,
  ),
  compress(
    label: 'Compress',
    icon: Icons.compress_outlined,
    description: 'Distill to the essence',
    color: EomColors.accent,
  ),
  map(
    label: 'Map',
    icon: Icons.account_tree_outlined,
    description: 'See the structure',
    color: EomColors.accent,
  ),
  reflect(
    label: 'Reflect',
    icon: Icons.psychology_outlined,
    description: 'Look at it differently',
    color: EomColors.accent,
  ),
  act(
    label: 'Act',
    icon: Icons.bolt_outlined,
    description: 'Turn it into action',
    color: EomColors.sage,
  );

  const CognitiveIntent({
    required this.label,
    required this.icon,
    required this.description,
    required this.color,
  });

  final String label;
  final IconData icon;
  final String description;
  final Color color;
}
