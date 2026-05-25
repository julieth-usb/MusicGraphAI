import '../models/music_node.dart';

class DfsResult {
  final List<MusicNode> traversalOrder;
  final List<List<MusicNode>> steps; // Visual snapshots of visited nodes
  final List<MusicNode> path; // Deep path from start to target (if target specified)

  DfsResult({
    required this.traversalOrder,
    required this.steps,
    required this.path,
  });
}

/// Executes a Depth-First Search on the graph.
DfsResult runDFS({
  required List<MusicNode> nodes,
  required Map<MusicNode, List<MusicNode>> adjacencyList,
  required MusicNode start,
  MusicNode? target,
}) {
  final List<MusicNode> traversalOrder = [];
  final List<List<MusicNode>> steps = [];
  final Set<MusicNode> visited = {};
  final List<MusicNode> currentPath = [];
  List<MusicNode> finalPath = [];
  bool targetFound = false;

  void dfsHelper(MusicNode current) {
    if (targetFound) return;

    visited.add(current);
    traversalOrder.add(current);
    currentPath.add(current);
    steps.add(List.from(traversalOrder));

    if (target != null && current == target) {
      targetFound = true;
      finalPath = List.from(currentPath);
      return;
    }

    final neighbors = adjacencyList[current] ?? [];
    for (final neighbor in neighbors) {
      if (!visited.contains(neighbor)) {
        dfsHelper(neighbor);
      }
    }

    if (!targetFound) {
      currentPath.removeLast();
    }
  }

  dfsHelper(start);

  return DfsResult(
    traversalOrder: traversalOrder,
    steps: steps,
    path: finalPath,
  );
}
