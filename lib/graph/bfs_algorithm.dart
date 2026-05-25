import '../models/music_node.dart';

class BfsResult {
  final List<MusicNode> traversalOrder;
  final List<MusicNode> shortestPath;
  final List<List<MusicNode>> steps; // Visual step-by-step snapshots of visited nodes

  BfsResult({
    required this.traversalOrder,
    required this.shortestPath,
    required this.steps,
  });
}

/// Executes a Breadth-First Search to find the shortest path from [start] to [target]
/// or to traverse the graph if no target is specified.
BfsResult runBFS({
  required List<MusicNode> nodes,
  required Map<MusicNode, List<MusicNode>> adjacencyList,
  required MusicNode start,
  MusicNode? target,
}) {
  final List<MusicNode> traversalOrder = [];
  final List<List<MusicNode>> steps = [];
  final Map<MusicNode, MusicNode?> parentMap = {};
  final Set<MusicNode> visited = {};
  final List<MusicNode> queue = [];

  visited.add(start);
  queue.add(start);
  parentMap[start] = null;

  while (queue.isNotEmpty) {
    // Record current snapshot of visited nodes for visualization
    steps.add(List.from(traversalOrder));

    final current = queue.removeAt(0);
    traversalOrder.add(current);

    if (target != null && current == target) {
      break;
    }

    final neighbors = adjacencyList[current] ?? [];
    for (final neighbor in neighbors) {
      if (!visited.contains(neighbor)) {
        visited.add(neighbor);
        parentMap[neighbor] = current;
        queue.add(neighbor);
      }
    }
  }

  // Reconstruct shortest path if target was reached
  final List<MusicNode> shortestPath = [];
  if (target != null && visited.contains(target)) {
    MusicNode? curr = target;
    while (curr != null) {
      shortestPath.insert(0, curr);
      curr = parentMap[curr];
    }
  }

  return BfsResult(
    traversalOrder: traversalOrder,
    shortestPath: shortestPath,
    steps: steps,
  );
}
