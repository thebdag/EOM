import 'package:flutter/material.dart';
import '../models/thought_node.dart';
import '../theme/eom_colors.dart';

/// Clean directory-tree visualization for the "Map" intent.
/// Uses 1px muted grey connecting lines per design spec.
class ThoughtTreeView extends StatelessWidget {
  const ThoughtTreeView({
    super.key,
    required this.root,
  });

  final ThoughtNode root;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: 1.0,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: EomColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: EomColors.surfaceBorder, width: 0.5),
        ),
        child: _buildNode(context, root, '', true),
      ),
    );
  }

  Widget _buildNode(
    BuildContext context,
    ThoughtNode node,
    String prefix,
    bool isRoot,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isRoot)
              Text(
                prefix,
                style: const TextStyle(
                  color: EomColors.textTertiary,
                  fontSize: 14,
                  fontFamily: 'monospace',
                  height: 1.4,
                ),
              ),
            Flexible(
              child: Text(
                node.label,
                style: TextStyle(
                  color: isRoot ? EomColors.textPrimary : EomColors.textSecondary,
                  fontSize: isRoot ? 15 : 14,
                  fontWeight: isRoot ? FontWeight.w500 : FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        if (node.children.isNotEmpty)
          ...node.children.asMap().entries.map((entry) {
            final i = entry.key;
            final child = entry.value;
            final isLast = i == node.children.length - 1;
            final connector = isLast ? '└── ' : '├── ';
            final childPrefix = isRoot ? '' : (prefix.replaceAll('├── ', '│   ').replaceAll('└── ', '    '));
            final newPrefix = '$childPrefix$connector';
            return _buildNode(context, child, newPrefix, false);
          }),
      ],
    );
  }
}
