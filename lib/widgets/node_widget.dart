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

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Determine theme-aligned glowing colors
    Color glowColor = node.getColor(isDark);
    double glowStrength = 8.0;
    double borderThickness = 1.5;
    List<BoxShadow> shadows = [];

    if (isInPath) {
      glowColor = const Color(0xFFFFD700); // Golden yellow for final shortest path
      glowStrength = 22.0;
      borderThickness = 3.0;
    } else if (isActive) {
      glowColor = const Color(0xFFFF007F); // Glowing Hot Pink for active traversal scanning
      glowStrength = 26.0;
      borderThickness = 3.5;
    } else if (isVisited) {
      glowColor = node.getColor(isDark).withOpacity(0.85);
      glowStrength = 12.0;
      borderThickness = 2.0;
    }

    // Add high fidelity neon shadow glow effect
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
      // Subtle standard ambient glow
      shadows = [
        BoxShadow(
          color: isDark ? Colors.black.withOpacity(0.5) : Colors.grey.withOpacity(0.2),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          // Futuristic glassmorphic background
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
            // Circular Glowing Icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(6),
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
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            // Title & Subtitle
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  node.name,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
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
                const SizedBox(height: 2),
                Text(
                  node.subtitle ?? node.typeString,
                  style: TextStyle(
                    color: isDark ? Colors.white.withOpacity(0.6) : Colors.black54,
                    fontSize: 10,
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
