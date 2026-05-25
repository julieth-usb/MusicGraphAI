import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import '../models/music_node.dart';
import '../models/song.dart';
import '../graph/graph_controller.dart';
import 'node_widget.dart';

class GraphWidget extends StatefulWidget {
  final GraphController controller;
  final Function(MusicNode) onNodeSelected;

  const GraphWidget({
    super.key,
    required this.controller,
    required this.onNodeSelected,
  });

  @override
  State<GraphWidget> createState() => _GraphWidgetState();
}

class _GraphWidgetState extends State<GraphWidget> {
  final FruchtermanReingoldAlgorithm _forceLayout = FruchtermanReingoldAlgorithm(
    FruchtermanReingoldConfiguration()
      ..iterations = 800
      ..attractionRate = 50.0
      ..repulsionRate = 250.0
      ..attractionPercentage = 0.3
      ..repulsionPercentage = 0.3,
  );

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.controller.nodes.isEmpty) {
      return GestureDetector(
        onLongPress: () {
          _createNewNode(widget.controller);
        },
        child: Container(
          color: Colors.transparent, // catch taps
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.gesture,
                  size: 64,
                  color: isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'El lienzo está vacío.\nMantén presionado para crear un nodo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.5),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final Paint edgePaint = Paint()
      ..color = const Color(0xFF3B82F6) 
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    return InteractiveViewer(
      constrained: false,
      boundaryMargin: const EdgeInsets.all(2000),
      minScale: 0.1,
      maxScale: 4.0,
      child: GestureDetector(
        onLongPress: () {
          _createNewNode(widget.controller);
        },
        child: CustomPaint(
          painter: GridPainter(isDark),
          child: Container(
            width: 4000,
            height: 4000,
            color: Colors.transparent,
            alignment: Alignment.center,
            child: GraphView(
              graph: widget.controller.graph,
              algorithm: _forceLayout,
              paint: edgePaint,
              builder: (Node node) {
                final musicNode = node.key!.value as MusicNode;

                final bool isActive = widget.controller.activeTraversalNode == musicNode;
                final bool isVisited = widget.controller.visitedNodes.contains(musicNode);
                final bool isInPath = widget.controller.shortestPathNodes.contains(musicNode);

                return GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      node.position += details.delta;
                    });
                  },
                  child: NodeWidget(
                    node: musicNode,
                    isActive: isActive,
                    isVisited: isVisited,
                    isInPath: isInPath,
                    onTap: () => widget.onNodeSelected(musicNode),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _createNewNode(GraphController controller) {
    int count = controller.nodes.length;
    String newName;
    if (count < 26) {
      newName = String.fromCharCode(65 + count);
    } else {
      newName = 'N${count + 1}';
    }
    
    final newNode = Song(id: 'custom_$newName', name: newName);
    controller.addMusicNode(newNode);
  }
}

class GridPainter extends CustomPainter {
  final bool isDark;
  GridPainter(this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.04) : const Color(0xFF3B82F6).withOpacity(0.1) // Soft grid color
      ..strokeWidth = 1.0;

    const double step = 40.0;
    
    // Draw horizontal lines
    for (double i = 0; i <= size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
    // Draw vertical lines
    for (double i = 0; i <= size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => oldDelegate != this;
}
