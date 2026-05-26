import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import '../models/music_node.dart';
import '../graph/graph_controller.dart';
import 'node_widget.dart';

class GraphWidget extends StatefulWidget {
  final GraphController controller;
  final Function(MusicNode) onNodeSelected;
  final bool autoLayout;

  const GraphWidget({
    super.key,
    required this.controller,
    required this.onNodeSelected,
    this.autoLayout = true,
  });

  @override
  State<GraphWidget> createState() => _GraphWidgetState();
}

class _GraphWidgetState extends State<GraphWidget> {
  // We instantiate the algorithm configuration.
  // FruchtermanReingold is a force-directed layout which lets nodes auto-arrange.
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
    if (widget.controller.nodes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_off,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'El grafo está vacío.\n¡Agrega nodos para comenzar!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // Dynamic edge styling based on algorithm execution state
    final Paint edgePaint = Paint()
      ..color = widget.controller.isAlgorithmRunning
          ? const Color(0xFFFF007F).withOpacity(0.3) // Scanning neon hot pink edge lines
          : const Color(0xFF5A5E82).withOpacity(0.5) // Slate blue neon lines
      ..strokeWidth = widget.controller.isAlgorithmRunning ? 2.5 : 1.5
      ..style = PaintingStyle.stroke;

    // Choose algorithm based on widget.autoLayout. If disabled, use 0 iterations
    // to avoid reflowing nodes so user can move them manually.
    final algorithm = widget.autoLayout
        ? _forceLayout
        : FruchtermanReingoldAlgorithm(
            FruchtermanReingoldConfiguration()..iterations = 0);

    return InteractiveViewer(
      constrained: false,
      boundaryMargin: const EdgeInsets.all(500),
      minScale: 0.05,
      maxScale: 4.0,
      child: Container(
        padding: const EdgeInsets.all(32),
        child: GraphView(
          graph: widget.controller.graph,
          // ArrowEdgeRenderer displays elegant direction markers for directed paths!
          algorithm: algorithm,
          paint: edgePaint,
          builder: (Node node) {
            // Retrieve the original music node
            final musicNode = node.key!.value as MusicNode;

            final bool isActive = widget.controller.activeTraversalNode == musicNode;
            final bool isVisited = widget.controller.visitedNodes.contains(musicNode);
            final bool isInPath = widget.controller.shortestPathNodes.contains(musicNode);

            // Wrap with a GestureDetector to allow freeform dragging of individual nodes!
            return GestureDetector(
              onPanUpdate: (details) {
                // Allows the user to freely drag nodes around the canvas
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
    );
  }
}
