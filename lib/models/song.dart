import 'music_node.dart';

class Song extends MusicNode {
  Song({
    required String id,
    required String name,
    String subtitle = 'Canción / Track',
  }) : super(
          id: id,
          name: name,
          type: NodeType.song,
          subtitle: subtitle,
        );
}
