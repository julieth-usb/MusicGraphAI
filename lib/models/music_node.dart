import 'package:flutter/material.dart';

enum NodeType { artist, song, genre }

class MusicNode {
  final String id;
  final String name;
  final NodeType type;
  final String? subtitle; // e.g. "Artist", "Pop", "Album/Song"

  MusicNode({
    required this.id,
    required this.name,
    required this.type,
    this.subtitle,
  });

  Color getColor(bool isDarkMode) {
    if (isDarkMode) {
      switch (type) {
        case NodeType.artist:
          return const Color(0xFF00E5FF); // Neon Electric Blue
        case NodeType.song:
          return const Color(0xFF00FF87); // Neon Vibrant Green
        case NodeType.genre:
          return const Color(0xFFBD00FF); // Neon Purple
      }
    } else {
      switch (type) {
        case NodeType.artist:
          return const Color(0xFF0288D1); // Elegant Ocean Blue
        case NodeType.song:
          return const Color(0xFF2E7D32); // Vibrant Forest Green
        case NodeType.genre:
          return const Color(0xFF7B1FA2); // Royal Purple
      }
    }
  }

  Color get color => getColor(true);

  IconData get icon {
    switch (type) {
      case NodeType.artist:
        return Icons.mic;
      case NodeType.song:
        return Icons.music_note;
      case NodeType.genre:
        return Icons.queue_music;
    }
  }

  String get typeString {
    switch (type) {
      case NodeType.artist:
        return 'Artista';
      case NodeType.song:
        return 'Canción';
      case NodeType.genre:
        return 'Género';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MusicNode && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => name;
}
