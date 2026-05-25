import 'package:flutter/material.dart';
import '../models/music_node.dart';

class NodeWidget extends StatelessWidget {
  final MusicNode node;
  final bool isActive;
  final bool isVisited;
  final bool isInPath;
  final VoidCallback? onTap;

  const NodeWidget({
    super.key,
    required this.node,
    this.isActive = false,
    this.isVisited = false,
    this.isInPath = false,
    this.onTap,
  });

  bool _isExampleNode() {
    return node.id.startsWith('chain_') ||
        node.id.startsWith('cycle_') ||
        node.id.startsWith('star_') ||
        node.id.startsWith('tree_') ||
        node.id.startsWith('disc_') ||
        node.id.startsWith('k5_');
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    Color glowColor = node.getColor(isDark);
    double glowStrength = 8.0;
    double borderThickness = 1.5;
    List<BoxShadow> shadows = [];

    if (isInPath) {
      glowColor = const Color(0xFFFFD700); // Golden yellow
      glowStrength = 22.0;
      borderThickness = 3.0;
    } else if (isActive) {
      glowColor = const Color(0xFFFF007F); // Glowing Pink
      glowStrength = 26.0;
      borderThickness = 3.5;
    } else if (isVisited) {
      glowColor = node.getColor(isDark).withOpacity(0.85);
      glowStrength = 12.0;
      borderThickness = 2.0;
    }

    if (isActive || isVisited || isInPath) {
      shadows = [
        BoxShadow(
          color: glowColor.withOpacity(isDark ? 0.5 : 0.3),
          blurRadius: glowStrength,
          spreadRadius: isActive ? 4 : 1,
        ),
        BoxShadow(
          color: glowColor.withOpacity(isDark ? 0.25 : 0.15),
          blurRadius: glowStrength * 2,
          spreadRadius: isActive ? 2 : 0,
        ),
      ];
    } else {
      shadows = [
        BoxShadow(
          color: isDark ? Colors.black.withOpacity(0.5) : Colors.grey.withOpacity(0.2),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];
    }

    // --- IF IT IS AN EXAMPLE, RENDER THE BLUE CIRCLE ---
    if (_isExampleNode()) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          constraints: const BoxConstraints(
            minWidth: 54,
            minHeight: 54,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFFFF007F)
                : (isVisited ? const Color(0xFF6366F1) : const Color(0xFF3B82F6)),
            shape: BoxShape.circle,
            border: Border.all(
              color: isInPath ? const Color(0xFFFFD700) : Colors.white,
              width: isInPath ? 3.0 : 2.0,
            ),
            boxShadow: shadows,
          ),
          alignment: Alignment.center,
          child: Text(
            node.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
              letterSpacing: 0.5,
              shadows: (isActive || isInPath)
                  ? [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 4,
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      );
    }

    // --- OTHERWISE, RENDER THE GORGEOUS MUSIC CARD ---
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1E1E2F).withOpacity(0.85)
              : Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: glowColor.withOpacity(isActive ? 1.0 : (isVisited ? 0.9 : 0.45)),
            width: borderThickness,
          ),
          boxShadow: shadows,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: glowColor.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: glowColor.withOpacity(0.35),
                  width: 1,
                ),
              ),
              child: Icon(
                node.icon,
                color: glowColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  node.name,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                    letterSpacing: 0.5,
                    shadows: (isActive || isInPath)
                        ? [
                            Shadow(
                              color: glowColor.withOpacity(0.8),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  node.subtitle ?? node.typeString,
                  style: TextStyle(
                    color: isDark ? Colors.white.withOpacity(0.6) : Colors.black54,
                    fontSize: 11.0,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
