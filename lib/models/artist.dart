import 'music_node.dart';

class Artist extends MusicNode {
  Artist({
    required String id,
    required String name,
    String subtitle = 'Artista Principal',
  }) : super(
          id: id,
          name: name,
          type: NodeType.artist,
          subtitle: subtitle,
        );
}
