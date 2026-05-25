import 'music_node.dart';

class Genre extends MusicNode {
  Genre({
    required String id,
    required String name,
    String subtitle = 'Género Musical',
  }) : super(
          id: id,
          name: name,
          type: NodeType.genre,
          subtitle: subtitle,
        );
}
