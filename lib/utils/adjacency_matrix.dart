import '../models/music_node.dart';

class AdjacencyMatrixData {
  final List<String> labels;
  final List<List<int>> matrix;

  AdjacencyMatrixData({
    required this.labels,
    required this.matrix,
  });
}

/// Generates an Adjacency Matrix representing the current graph state.
AdjacencyMatrixData generateAdjacencyMatrix({
  required List<MusicNode> nodes,
  required List<MapEntry<MusicNode, MusicNode>> edges,
  required bool isDirected,
}) {
  final labels = nodes.map((node) => node.name).toList();
  final int n = nodes.length;

  // Initialize n x n matrix with zeros
  final List<List<int>> matrix = List.generate(
    n,
    (_) => List.generate(n, (_) => 0),
  );

  // Map each node to its index
  final Map<MusicNode, int> nodeToIndex = {};
  for (int i = 0; i < n; i++) {
    nodeToIndex[nodes[i]] = i;
  }

  // Populate matrix based on edges
  for (final edge in edges) {
    final fromIndex = nodeToIndex[edge.key];
    final toIndex = nodeToIndex[edge.value];

    if (fromIndex != null && toIndex != null) {
      matrix[fromIndex][toIndex] = 1;

      if (!isDirected) {
        matrix[toIndex][fromIndex] = 1;
      }
    }
  }

  return AdjacencyMatrixData(
    labels: labels,
    matrix: matrix,
  );
}
