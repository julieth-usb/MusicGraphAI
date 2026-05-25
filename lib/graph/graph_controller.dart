import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import '../models/music_node.dart';
import '../models/artist.dart';
import '../models/song.dart';
import '../models/genre.dart';
import 'bfs_algorithm.dart';
import 'dfs_algorithm.dart';

class GraphController extends ChangeNotifier {
  // GraphView objects
  final Graph graph = Graph();
  final Map<MusicNode, Node> _nodeMap = {};

  // Underlying model state
  final List<MusicNode> _nodes = [];
  final List<MapEntry<MusicNode, MusicNode>> _edges = [];

  // Track custom nodes/edges added by the user so they can persist
  final List<MusicNode> _customNodes = [];
  final List<MapEntry<MusicNode, MusicNode>> _customEdges = [];

  bool _isDirected = false;
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // Animation & Search States
  bool _isAlgorithmRunning = false;
  Set<MusicNode> _visitedNodes = {};
  List<MusicNode> _visitedNodesInOrder = [];
  List<MusicNode> _shortestPathNodes = [];
  MusicNode? _activeTraversalNode;
  String? _algorithmType; // "BFS" or "DFS"
  MusicNode? _searchStart;
  MusicNode? _searchTarget;

  // Getters
  List<MusicNode> get nodes => List.unmodifiable(_nodes);
  List<MapEntry<MusicNode, MusicNode>> get edges => List.unmodifiable(_edges);
  bool get isDirected => _isDirected;

  bool get isAlgorithmRunning => _isAlgorithmRunning;
  Set<MusicNode> get visitedNodes => _visitedNodes;
  List<MusicNode> get visitedNodesInOrder => _visitedNodesInOrder;
  List<MusicNode> get shortestPathNodes => _shortestPathNodes;
  MusicNode? get activeTraversalNode => _activeTraversalNode;
  String? get algorithmType => _algorithmType;
  MusicNode? get searchStart => _searchStart;
  MusicNode? get searchTarget => _searchTarget;

  GraphController() {
    _loadDefaultData();
  }

  // Node to GraphView Node mapping helper
  Node getNodeForMusicNode(MusicNode musicNode) {
    return _nodeMap.putIfAbsent(musicNode, () => Node.Id(musicNode));
  }

  void toggleGraphDirected() {
    _isDirected = !_isDirected;
    _rebuildGraphView();
    notifyListeners();
  }

  void _loadDefaultData() {
    // 1. Create Predefined Artists
    final badBunny = Artist(id: 'bad_bunny', name: 'Bad Bunny');
    final karolG = Artist(id: 'karol_g', name: 'Karol G');
    final feid = Artist(id: 'feid', name: 'Feid');
    final drake = Artist(id: 'drake', name: 'Drake');
    final travisScott = Artist(id: 'travis_scott', name: 'Travis Scott');
    final taylorSwift = Artist(id: 'taylor_swift', name: 'Taylor Swift');

    // 2. Create Predefined Genres
    final reggaeton = Genre(id: 'reggaeton', name: 'Reggaetón');
    final hiphop = Genre(id: 'hiphop', name: 'Hip-Hop');
    final pop = Genre(id: 'pop', name: 'Pop');

    // 3. Create Predefined Songs
    final ojitosLindos = Song(id: 'ojitos_lindos', name: 'Ojitos Lindos');
    final tqg = Song(id: 'tqg', name: 'TQG');
    final classy101 = Song(id: 'classy_101', name: 'Classy 101');
    final hotlineBling = Song(id: 'hotline_bling', name: 'Hotline Bling');
    final sickoMode = Song(id: 'sicko_mode', name: 'Sicko Mode');
    final cardigan = Song(id: 'cardigan', name: 'Cardigan');

    // Add them to standard lists
    _nodes.addAll([
      badBunny,
      karolG,
      feid,
      drake,
      travisScott,
      taylorSwift,
      reggaeton,
      hiphop,
      pop,
      ojitosLindos,
      tqg,
      classy101,
      hotlineBling,
      sickoMode,
      cardigan,
    ]);

    // 4. Create Predefined Edges / Relationships
    // Artists Collaborations (Undirected style relationships)
    _edges.add(MapEntry(badBunny, karolG));
    _edges.add(MapEntry(karolG, feid));
    _edges.add(MapEntry(badBunny, drake));
    _edges.add(MapEntry(drake, travisScott));
    _edges.add(MapEntry(taylorSwift, drake));

    // Genres (Directed style connections)
    _edges.add(MapEntry(badBunny, reggaeton));
    _edges.add(MapEntry(karolG, reggaeton));
    _edges.add(MapEntry(feid, reggaeton));
    _edges.add(MapEntry(drake, hiphop));
    _edges.add(MapEntry(travisScott, hiphop));
    _edges.add(MapEntry(taylorSwift, pop));

    // Songs to Artists
    _edges.add(MapEntry(ojitosLindos, badBunny));
    _edges.add(MapEntry(tqg, karolG));
    _edges.add(MapEntry(classy101, feid));
    _edges.add(MapEntry(hotlineBling, drake));
    _edges.add(MapEntry(sickoMode, travisScott));
    _edges.add(MapEntry(cardigan, taylorSwift));

    // Songs to Genres
    _edges.add(MapEntry(ojitosLindos, reggaeton));
    _edges.add(MapEntry(tqg, reggaeton));
    _edges.add(MapEntry(classy101, reggaeton));
    _edges.add(MapEntry(sickoMode, hiphop));
    _edges.add(MapEntry(hotlineBling, hiphop));
    _edges.add(MapEntry(cardigan, pop));

    _rebuildGraphView();
  }

  void _rebuildGraphView() {
    graph.nodes.clear();
    graph.edges.clear();
    // Using a set to ensure no duplicate edges in GraphView
    final Set<String> addedEdges = {};

    for (final node in _nodes) {
      graph.addNode(getNodeForMusicNode(node));
    }

    for (final edge in _edges) {
      final sourceGNode = getNodeForMusicNode(edge.key);
      final destGNode = getNodeForMusicNode(edge.value);

      final edgeId = '${edge.key.id}_to_${edge.value.id}';
      final reverseEdgeId = '${edge.value.id}_to_${edge.key.id}';

      if (!addedEdges.contains(edgeId)) {
        graph.addEdge(sourceGNode, destGNode);
        addedEdges.add(edgeId);

        if (!_isDirected) {
          addedEdges.add(reverseEdgeId);
        }
      }
    }
  }

  // --- Add Node & Connection Functions ---

  void addMusicNode(MusicNode node) {
    if (_nodes.any((n) => n.id == node.id || n.name.toLowerCase() == node.name.toLowerCase())) {
      // Avoid exact duplicates
      return;
    }
    _nodes.add(node);
    _customNodes.add(node);

    // Auto-connect isolated nodes to keep them visible on screen!
    if (_nodes.length > 1) {
      // Find the first genre node, or fallback to the first node in the graph
      final fallback = _nodes.firstWhere(
        (n) => n.type == NodeType.genre,
        orElse: () => _nodes.first,
      );
      final newEdge = MapEntry(node, fallback);
      _edges.add(newEdge);
      _customEdges.add(newEdge);
    }

    _rebuildGraphView();
    notifyListeners();
  }

  void addConnection(MusicNode source, MusicNode target) {
    if (source == target) return;

    // Check duplicate edges
    final exists = _edges.any((edge) =>
        (edge.key == source && edge.value == target) ||
        (!_isDirected && edge.key == target && edge.value == source));

    if (!exists) {
      final newEdge = MapEntry(source, target);
      _edges.add(newEdge);
      _customEdges.add(newEdge);
      _rebuildGraphView();
      notifyListeners();
    }
  }

  void resetGraph() {
    stopAnimation();
    _nodes.clear();
    _edges.clear();
    _nodeMap.clear();
    _loadDefaultData();
    // Re-add custom nodes and connections
    _nodes.addAll(_customNodes);
    _edges.addAll(_customEdges);
    _rebuildGraphView();
    notifyListeners();
  }

  void clearGraph() {
    stopAnimation();
    _nodes.clear();
    _edges.clear();
    _customNodes.clear();
    _customEdges.clear();
    _nodeMap.clear();
    graph.edges.clear();
    _rebuildGraphView();
    notifyListeners();
  }

  void removeAllNodesAndEdges() {
    _nodes.clear();
    _edges.clear();
    _rebuildGraphView();
    notifyListeners();
  }

  void loadExampleGraph(String exampleType, {bool clearCurrent = true}) {
    stopAnimation();
    
    final List<MusicNode> tempNodes = [];
    final List<MapEntry<MusicNode, MusicNode>> tempEdges = [];

    switch (exampleType) {
      case 'chain':
        // Cadena básica: 5 nodes in a line
        final c1 = Song(id: 'chain_1', name: 'A');
        final c2 = Song(id: 'chain_2', name: 'B');
        final c3 = Song(id: 'chain_3', name: 'C');
        final c4 = Song(id: 'chain_4', name: 'D');
        final c5 = Song(id: 'chain_5', name: 'E');

        tempNodes.addAll([c1, c2, c3, c4, c5]);
        tempEdges.add(MapEntry(c1, c2));
        tempEdges.add(MapEntry(c2, c3));
        tempEdges.add(MapEntry(c3, c4));
        tempEdges.add(MapEntry(c4, c5));
        break;

      case 'cycle':
        // Ciclo simple: 6 nodes in a ring
        final cy1 = Song(id: 'cycle_1', name: 'A');
        final cy2 = Song(id: 'cycle_2', name: 'B');
        final cy3 = Song(id: 'cycle_3', name: 'C');
        final cy4 = Song(id: 'cycle_4', name: 'D');
        final cy5 = Song(id: 'cycle_5', name: 'E');
        final cy6 = Song(id: 'cycle_6', name: 'F');

        tempNodes.addAll([cy1, cy2, cy3, cy4, cy5, cy6]);
        tempEdges.add(MapEntry(cy1, cy2));
        tempEdges.add(MapEntry(cy2, cy3));
        tempEdges.add(MapEntry(cy3, cy4));
        tempEdges.add(MapEntry(cy4, cy5));
        tempEdges.add(MapEntry(cy5, cy6));
        tempEdges.add(MapEntry(cy6, cy1));
        break;

      case 'star':
        // Estrella: central node with 5 leaves
        final sCtr = Artist(id: 'star_center', name: 'Centro');
        final s1 = Song(id: 'star_1', name: 'A');
        final s2 = Song(id: 'star_2', name: 'B');
        final s3 = Song(id: 'star_3', name: 'C');
        final s4 = Song(id: 'star_4', name: 'D');
        final s5 = Song(id: 'star_5', name: 'E');

        tempNodes.addAll([sCtr, s1, s2, s3, s4, s5]);
        tempEdges.add(MapEntry(sCtr, s1));
        tempEdges.add(MapEntry(sCtr, s2));
        tempEdges.add(MapEntry(sCtr, s3));
        tempEdges.add(MapEntry(sCtr, s4));
        tempEdges.add(MapEntry(sCtr, s5));
        break;

      case 'tree':
        // Árbol binario: root with 2 children, each with 2 children
        final tRoot = Genre(id: 'tree_root', name: 'Raíz');
        final tL = Genre(id: 'tree_l', name: 'A');
        final tR = Genre(id: 'tree_r', name: 'B');
        final tLl = Artist(id: 'tree_ll', name: 'A1');
        final tLr = Artist(id: 'tree_lr', name: 'A2');
        final tRl = Artist(id: 'tree_rl', name: 'B1');
        final tRr = Artist(id: 'tree_rr', name: 'B2');

        tempNodes.addAll([tRoot, tL, tR, tLl, tLr, tRl, tRr]);
        tempEdges.add(MapEntry(tRoot, tL));
        tempEdges.add(MapEntry(tRoot, tR));
        tempEdges.add(MapEntry(tL, tLl));
        tempEdges.add(MapEntry(tL, tLr));
        tempEdges.add(MapEntry(tR, tRl));
        tempEdges.add(MapEntry(tR, tRr));
        break;

      case 'disconnected':
        // Grafo desconexo: Group 1 (3 nodes) and Group 2 (2 nodes)
        final d1 = Song(id: 'disc_1', name: 'A');
        final d2 = Song(id: 'disc_2', name: 'B');
        final d3 = Song(id: 'disc_3', name: 'C');
        final x1 = Artist(id: 'disc_x', name: 'X');
        final y1 = Artist(id: 'disc_y', name: 'Y');

        tempNodes.addAll([d1, d2, d3, x1, y1]);
        tempEdges.add(MapEntry(d1, d2));
        tempEdges.add(MapEntry(d2, d3));
        tempEdges.add(MapEntry(x1, y1));
        break;

      case 'complete':
        // Grafo completo K5: 5 nodes all connected to each other
        final k1 = Genre(id: 'k5_1', name: 'A');
        final k2 = Genre(id: 'k5_2', name: 'B');
        final k3 = Genre(id: 'k5_3', name: 'C');
        final k4 = Genre(id: 'k5_4', name: 'D');
        final k5 = Genre(id: 'k5_5', name: 'E');

        tempNodes.addAll([k1, k2, k3, k4, k5]);
        // All combinations of 5 nodes:
        tempEdges.add(MapEntry(k1, k2));
        tempEdges.add(MapEntry(k1, k3));
        tempEdges.add(MapEntry(k1, k4));
        tempEdges.add(MapEntry(k1, k5));

        tempEdges.add(MapEntry(k2, k3));
        tempEdges.add(MapEntry(k2, k4));
        tempEdges.add(MapEntry(k2, k5));

        tempEdges.add(MapEntry(k3, k4));
        tempEdges.add(MapEntry(k3, k5));

        tempEdges.add(MapEntry(k4, k5));
        break;
    }

    if (clearCurrent) {
      _nodes.clear();
      _edges.clear();
      _customNodes.clear();
      _customEdges.clear();
      _nodeMap.clear();
      graph.nodes.clear();
      
      _nodes.addAll(tempNodes);
      _edges.addAll(tempEdges);
    } else {
      // Safe merge logic to avoid duplicates
      final Map<String, MusicNode> idMap = {for (var n in _nodes) n.id: n};
      
      MusicNode resolveNode(MusicNode node) {
        if (idMap.containsKey(node.id)) {
          return idMap[node.id]!;
        } else {
          _nodes.add(node);
          idMap[node.id] = node;
          return node;
        }
      }
      
      for (final edge in tempEdges) {
        final src = resolveNode(edge.key);
        final dst = resolveNode(edge.value);
        
        final edgeExists = _edges.any((e) =>
            (e.key == src && e.value == dst) ||
            (!_isDirected && e.key == dst && e.value == src));
        if (!edgeExists) {
          _edges.add(MapEntry(src, dst));
        }
      }
    }

    _rebuildGraphView();
    notifyListeners();
  }

  // --- Animation Controllers & Playback ---

  void stopAnimation() {
    _isAlgorithmRunning = false;
    _visitedNodes.clear();
    _visitedNodesInOrder.clear();
    _shortestPathNodes.clear();
    _activeTraversalNode = null;
    _algorithmType = null;
    _searchStart = null;
    _searchTarget = null;
    notifyListeners();
  }

  // Build Adjacency List for the algorithms
  Map<MusicNode, List<MusicNode>> getAdjacencyList() {
    final Map<MusicNode, List<MusicNode>> adj = {};
    for (final node in _nodes) {
      adj[node] = [];
    }

    for (final edge in _edges) {
      adj[edge.key]?.add(edge.value);
      if (!_isDirected) {
        adj[edge.value]?.add(edge.key);
      }
    }
    return adj;
  }

  Future<void> startBFS({required MusicNode start, MusicNode? target}) async {
    if (_isAlgorithmRunning) stopAnimation();

    _isAlgorithmRunning = true;
    _algorithmType = "BFS";
    _searchStart = start;
    _searchTarget = target;
    notifyListeners();

    final adj = getAdjacencyList();
    final result = runBFS(
      nodes: _nodes,
      adjacencyList: adj,
      start: start,
      target: target,
    );

    // 1. Animate Traversal Order Step-by-Step
    for (final node in result.traversalOrder) {
      if (!_isAlgorithmRunning) return; // check for cancellation
      _activeTraversalNode = node;
      _visitedNodes.add(node);
      _visitedNodesInOrder.add(node);
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 600));
    }

    _activeTraversalNode = null;
    notifyListeners();

    // 2. Animate shortest path if target was specified and found
    if (target != null && result.shortestPath.isNotEmpty) {
      for (final node in result.shortestPath) {
        if (!_isAlgorithmRunning) return;
        _shortestPathNodes.add(node);
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 250));
      }
    }

    _isAlgorithmRunning = false;
    notifyListeners();
  }

  Future<void> startDFS({required MusicNode start, MusicNode? target}) async {
    if (_isAlgorithmRunning) stopAnimation();

    _isAlgorithmRunning = true;
    _algorithmType = "DFS";
    _searchStart = start;
    _searchTarget = target;
    notifyListeners();

    final adj = getAdjacencyList();
    final result = runDFS(
      nodes: _nodes,
      adjacencyList: adj,
      start: start,
      target: target,
    );

    // 1. Animate Traversal Order Step-by-Step
    for (final node in result.traversalOrder) {
      if (!_isAlgorithmRunning) return; // check for cancellation
      _activeTraversalNode = node;
      _visitedNodes.add(node);
      _visitedNodesInOrder.add(node);
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 600));
    }

    _activeTraversalNode = null;
    notifyListeners();

    // 2. Animate DFS path if target was specified and found
    if (target != null && result.path.isNotEmpty) {
      for (final node in result.path) {
        if (!_isAlgorithmRunning) return;
        _shortestPathNodes.add(node);
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 250));
      }
    }

    _isAlgorithmRunning = false;
    notifyListeners();
  }

  // --- Graph mathematical queries for the right panel ---

  MusicNode? getMostConnectedNode() {
    if (_nodes.isEmpty) return null;

    final adj = getAdjacencyList();
    MusicNode? bestNode;
    int maxConnections = -1;

    for (final entry in adj.entries) {
      final degree = entry.value.length;
      if (degree > maxConnections) {
        maxConnections = degree;
        bestNode = entry.key;
      }
    }
    return bestNode;
  }

  int getDegreeForNode(MusicNode node) {
    final adj = getAdjacencyList();
    return adj[node]?.length ?? 0;
  }

  String getDominantGenre() {
    if (_nodes.isEmpty) return "Ninguno";

    final Map<String, int> genreCounts = {};
    for (final edge in _edges) {
      if (edge.value.type == NodeType.genre) {
        genreCounts[edge.value.name] = (genreCounts[edge.value.name] ?? 0) + 1;
      }
      if (!_isDirected && edge.key.type == NodeType.genre) {
        genreCounts[edge.key.name] = (genreCounts[edge.key.name] ?? 0) + 1;
      }
    }

    if (genreCounts.isEmpty) return "Ninguno";

    String bestGenre = "Ninguno";
    int maxCount = -1;
    genreCounts.forEach((genre, count) {
      if (count > maxCount) {
        maxCount = count;
        bestGenre = genre;
      }
    });

    return "$bestGenre ($maxCount conexiones)";
  }

  double getGraphDensity() {
    final int v = _nodes.length;
    final int e = _edges.length;
    if (v <= 1) return 0.0;

    // For simple graph:
    // Directed density = E / (V * (V - 1))
    // Undirected density = 2E / (V * (V - 1))
    final int possibleEdges = v * (v - 1);
    if (_isDirected) {
      return e / possibleEdges;
    } else {
      return (2 * e) / possibleEdges;
    }
  }
}
