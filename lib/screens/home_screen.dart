import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/music_node.dart';
import '../models/artist.dart';
import '../models/song.dart';
import '../models/genre.dart';
import '../graph/graph_controller.dart';
import '../utils/adjacency_matrix.dart';
import '../widgets/graph_widget.dart';
import '../widgets/example_sandbox_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Form input controllers
  final _nodeNameController = TextEditingController();
  NodeType _selectedNodeType = NodeType.artist;

  // Node selection for connections and algorithms
  MusicNode? _connectionSource;
  MusicNode? _connectionTarget;

  MusicNode? _algoStart;
  MusicNode? _algoTarget;

  // Track currently selected node in UI for details card
  MusicNode? _inspectingNode;

  @override
  void dispose() {
    _nodeNameController.dispose();
    super.dispose();
  }

  // Pre-fill fields when a node is clicked in the graph
  void _handleNodeSelected(MusicNode node) {
    setState(() {
      _inspectingNode = node;
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Detalles de: "${node.name}" (${node.typeString})',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: node.color.withOpacity(0.9),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Visual helper to establish relationships
  void _addConnection(BuildContext context, GraphController controller) {
    if (_connectionSource == null || _connectionTarget == null) {
      _showWarningSnackBar('Selecciona el nodo de origen y destino.');
      return;
    }
    controller.addConnection(_connectionSource!, _connectionTarget!);
    Navigator.pop(context); // close bottom sheet
    _showSuccessSnackBar('Conexión establecida: ${_connectionSource!.name} ↔ ${_connectionTarget!.name}');
  }

  // Form submission to add custom node
  void _addCustomNode(BuildContext context, GraphController controller) {
    final name = _nodeNameController.text.trim();
    if (name.isEmpty) {
      _showWarningSnackBar('Por favor, introduce un nombre.');
      return;
    }

    final String cleanId = name.toLowerCase().replaceAll(' ', '_');
    MusicNode newNode;

    switch (_selectedNodeType) {
      case NodeType.artist:
        newNode = Artist(id: cleanId, name: name);
        break;
      case NodeType.song:
        newNode = Song(id: cleanId, name: name);
        break;
      case NodeType.genre:
        newNode = Genre(id: cleanId, name: name);
        break;
    }

    controller.addMusicNode(newNode);
    _nodeNameController.clear();
    Navigator.pop(context); // close bottom sheet

    final bool isDark = controller.isDarkMode;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nodo "${newNode.name}" creado con éxito.'),
        backgroundColor: newNode.getColor(isDark),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF00FF87),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // --- Bottom Sheet Launchers ---

  void _openStructuresSheet(BuildContext context, GraphController controller) {
    final bool isDark = controller.isDarkMode;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: 16,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111422) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Pull indicator
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DefaultTabController(
                    length: 2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TabBar(
                          indicatorColor: isDark ? const Color(0xFF00E5FF) : const Color(0xFF0288D1),
                          labelColor: isDark ? Colors.white : Colors.black87,
                          unselectedLabelColor: Colors.grey,
                          tabs: const [
                            Tab(text: '➕ Crear Nodo', icon: Icon(Icons.add_box_outlined, size: 20)),
                            Tab(text: '🔗 Conectar', icon: Icon(Icons.link, size: 20)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 280),
                          child: TabBarView(
                            children: [
                              // Tab 1: Create Node Form
                              SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    TextField(
                                      controller: _nodeNameController,
                                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                                      decoration: InputDecoration(
                                        labelText: 'Nombre (ej: Karol G)',
                                        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                                        filled: true,
                                        fillColor: isDark ? const Color(0xFF1B2236) : const Color(0xFFE8EDF5),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    DropdownButtonFormField<NodeType>(
                                      value: _selectedNodeType,
                                      dropdownColor: isDark ? const Color(0xFF111422) : Colors.white,
                                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: isDark ? const Color(0xFF1B2236) : const Color(0xFFE8EDF5),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                      ),
                                      items: NodeType.values.map((type) {
                                        String label = 'Artista';
                                        Color iconColor = isDark ? const Color(0xFF00E5FF) : const Color(0xFF0288D1);
                                        if (type == NodeType.song) {
                                          label = 'Canción';
                                          iconColor = isDark ? const Color(0xFF00FF87) : const Color(0xFF2E7D32);
                                        } else if (type == NodeType.genre) {
                                          label = 'Género';
                                          iconColor = isDark ? const Color(0xFFBD00FF) : const Color(0xFF7B1FA2);
                                        }
                                        return DropdownMenuItem(
                                          value: type,
                                          child: Row(
                                            children: [
                                              Icon(
                                                type == NodeType.artist
                                                    ? Icons.mic
                                                    : (type == NodeType.song ? Icons.music_note : Icons.queue_music),
                                                color: iconColor,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(label),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setModalState(() {
                                            _selectedNodeType = val;
                                          });
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isDark ? const Color(0xFF00FF87).withOpacity(0.2) : const Color(0xFF2E7D32).withOpacity(0.15),
                                        foregroundColor: isDark ? const Color(0xFF00FF87) : const Color(0xFF2E7D32),
                                        side: BorderSide(color: isDark ? const Color(0xFF00FF87) : const Color(0xFF2E7D32), width: 1),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      onPressed: () => _addCustomNode(context, controller),
                                      child: const Text('Agregar Nodo', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ),
                              // Tab 2: Create Edge Form
                              SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    _buildNodeSelector(
                                      label: 'Nodo A (Origen)',
                                      value: _connectionSource,
                                      nodes: controller.nodes,
                                      color: isDark ? const Color(0xFF00E5FF) : const Color(0xFF0288D1),
                                      isDark: isDark,
                                      onChanged: (val) {
                                        setModalState(() {
                                          _connectionSource = val;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    _buildNodeSelector(
                                      label: 'Nodo B (Destino)',
                                      value: _connectionTarget,
                                      nodes: controller.nodes,
                                      color: isDark ? const Color(0xFFBD00FF) : const Color(0xFF7B1FA2),
                                      isDark: isDark,
                                      onChanged: (val) {
                                        setModalState(() {
                                          _connectionTarget = val;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isDark ? const Color(0xFF00E5FF).withOpacity(0.2) : const Color(0xFF0288D1).withOpacity(0.15),
                                        foregroundColor: isDark ? const Color(0xFF00E5FF) : const Color(0xFF0288D1),
                                        side: BorderSide(color: isDark ? const Color(0xFF00E5FF) : const Color(0xFF0288D1), width: 1),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      onPressed: () => _addConnection(context, controller),
                                      child: const Text('Conectar Nodos', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openAlgorithmsSheet(BuildContext context, GraphController controller) {
    final bool isDark = controller.isDarkMode;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: 16,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111422) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.bolt, color: isDark ? const Color(0xFFFF007F) : const Color(0xFF7B1FA2), size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Recorridos y Caminos Mínimos',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildNodeSelector(
                    label: 'Nodo Inicial (Start)',
                    value: _algoStart,
                    nodes: controller.nodes,
                    color: isDark ? const Color(0xFF00E5FF) : const Color(0xFF0288D1),
                    isDark: isDark,
                    onChanged: (val) {
                      setModalState(() {
                        _algoStart = val;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildNodeSelector(
                    label: 'Nodo Destino (Opcional - Camino más corto)',
                    value: _algoTarget,
                    nodes: controller.nodes,
                    color: isDark ? const Color(0xFFFFD700) : const Color(0xFFE65100),
                    isDark: isDark,
                    onChanged: (val) {
                      setModalState(() {
                        _algoTarget = val;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? const Color(0xFFFF007F).withOpacity(0.2) : const Color(0xFF7B1FA2).withOpacity(0.15),
                            foregroundColor: isDark ? const Color(0xFFFF007F) : const Color(0xFF7B1FA2),
                            side: BorderSide(color: isDark ? const Color(0xFFFF007F) : const Color(0xFF7B1FA2), width: 1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.compare_arrows, size: 18),
                          label: const Text('Ejecutar BFS', style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: _algoStart == null
                              ? null
                              : () {
                                  Navigator.pop(context);
                                  controller.startBFS(start: _algoStart!, target: _algoTarget);
                                },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? const Color(0xFF00E5FF).withOpacity(0.2) : const Color(0xFF0288D1).withOpacity(0.15),
                            foregroundColor: isDark ? const Color(0xFF00E5FF) : const Color(0xFF0288D1),
                            side: BorderSide(color: isDark ? const Color(0xFF00E5FF) : const Color(0xFF0288D1), width: 1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.search, size: 18),
                          label: const Text('Ejecutar DFS', style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: _algoStart == null
                              ? null
                              : () {
                                  Navigator.pop(context);
                                  controller.startDFS(start: _algoStart!, target: _algoTarget);
                                },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openMathematicsSheet(BuildContext context, GraphController controller) {
    final bool isDark = controller.isDarkMode;
    final matrixData = generateAdjacencyMatrix(
      nodes: controller.nodes,
      edges: controller.edges,
      isDirected: controller.isDirected,
    );
    final mostConnected = controller.getMostConnectedNode();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF111422) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.analytics, color: isDark ? const Color(0xFF00E5FF) : const Color(0xFF0288D1), size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Análisis del Grafo Musical',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Stats Card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1C2236) : const Color(0xFFF3F5F9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            _buildMathStatRow('Total Vértices (V)', '${controller.nodes.length}', isDark ? const Color(0xFF00E5FF) : const Color(0xFF0288D1)),
                            _buildMathStatRow('Total Aristas (E)', '${controller.edges.length}', isDark ? const Color(0xFF00FF87) : const Color(0xFF2E7D32)),
                            _buildMathStatRow('Densidad de Red', controller.getGraphDensity().toStringAsFixed(3), isDark ? const Color(0xFFBD00FF) : const Color(0xFF7B1FA2)),
                            _buildMathStatRow('Género Dominante', controller.getDominantGenre(), isDark ? const Color(0xFFFF007F) : const Color(0xFFFF007F)),
                            _buildMathStatRow('Nodo Estrella (Max)', mostConnected != null ? '${mostConnected.name} (${controller.getDegreeForNode(mostConnected)} con)' : 'Ninguno', isDark ? const Color(0xFFFFD700) : const Color(0xFFE65100)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Matriz de Adyacencia (${controller.nodes.length} x ${controller.nodes.length})',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Matrix Table scroll representation
                      if (controller.nodes.isEmpty)
                        const Center(child: Text('Sin nodos', style: TextStyle(color: Colors.grey)))
                      else
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0C0F19) : const Color(0xFFE8EDF5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Table(
                              defaultColumnWidth: const FixedColumnWidth(34),
                              border: TableBorder.all(color: Colors.grey.withOpacity(0.1)),
                              children: [
                                // Header abbreviations row
                                TableRow(
                                  children: [
                                    const TableCell(
                                      child: Center(
                                        child: Text(
                                          'M',
                                          style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 10),
                                        ),
                                      ),
                                    ),
                                    ...List.generate(matrixData.labels.length, (index) {
                                      final label = matrixData.labels[index];
                                      return TableCell(
                                        child: Center(
                                          child: Text(
                                            label.substring(0, label.length > 2 ? 2 : label.length),
                                            style: TextStyle(color: controller.nodes[index].getColor(isDark), fontWeight: FontWeight.bold, fontSize: 9),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                                // Cells rows
                                ...List.generate(matrixData.matrix.length, (rowIndex) {
                                  final rowLabel = matrixData.labels[rowIndex];
                                  final rowNode = controller.nodes[rowIndex];
                                  return TableRow(
                                    children: [
                                      TableCell(
                                        child: Center(
                                          child: Text(
                                            rowLabel.substring(0, rowLabel.length > 2 ? 2 : rowLabel.length),
                                            style: TextStyle(color: rowNode.getColor(isDark), fontWeight: FontWeight.bold, fontSize: 9),
                                          ),
                                        ),
                                      ),
                                      ...List.generate(matrixData.matrix[rowIndex].length, (colIndex) {
                                        final cellValue = matrixData.matrix[rowIndex][colIndex];
                                        final bool isActiveCell = cellValue == 1;
                                        return TableCell(
                                          child: Container(
                                            height: 24,
                                            color: isActiveCell
                                                ? const Color(0xFF00FF87).withOpacity(0.12)
                                                : Colors.transparent,
                                            child: Center(
                                              child: Text(
                                                '$cellValue',
                                                style: TextStyle(
                                                  color: isActiveCell
                                                      ? const Color(0xFF00FF87)
                                                      : (isDark ? Colors.white24 : Colors.black26),
                                                  fontWeight: isActiveCell ? FontWeight.bold : FontWeight.normal,
                                                  fontSize: 10.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openTheorySheet(BuildContext context, GraphController controller) {
    final bool isDark = controller.isDarkMode;
    final primaryColor = isDark ? const Color(0xFF00E5FF) : const Color(0xFF0288D1);
    final secondaryColor = isDark ? const Color(0xFFBD00FF) : const Color(0xFF7B1FA2);
    final accentColor = isDark ? const Color(0xFFFFD700) : const Color(0xFFE65100);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF111422) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              )
            ],
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pull indicator
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.school, color: accentColor, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    'Fundamentos y Teoría del Grafo',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: DefaultTabController(
                  length: 4,
                  child: Column(
                    children: [
                      TabBar(
                        indicatorColor: accentColor,
                        labelColor: isDark ? Colors.white : Colors.black87,
                        unselectedLabelColor: Colors.grey,
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                        tabs: const [
                          Tab(text: '⚡ Algor.', icon: Icon(Icons.bolt, size: 16)),
                          Tab(text: '📊 Estruct.', icon: Icon(Icons.hub, size: 16)),
                          Tab(text: '🛡️ Valida.', icon: Icon(Icons.security, size: 16)),
                          Tab(text: '💡 Ejempl.', icon: Icon(Icons.psychology, size: 16)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Tab 1: BFS & DFS
                            _buildTheoryAlgorithmsTab(isDark, primaryColor, secondaryColor, accentColor),
                            // Tab 2: Representation (Adjacency Matrix vs List)
                            _buildTheoryRepresentationsTab(isDark, primaryColor, secondaryColor),
                            // Tab 3: Validations & Restrictions
                            _buildTheoryValidationsTab(isDark, primaryColor, secondaryColor, accentColor),
                            // Tab 4: Predesigned Examples
                            _buildTheoryExamplesTab(context, isDark, controller, accentColor),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTheoryAlgorithmsTab(bool isDark, Color primary, Color secondary, Color accent) {
    final cardBg = isDark ? const Color(0xFF1B2236) : const Color(0xFFE8EDF5);
    final textStyle = TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13, height: 1.4);
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // BFS Section
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primary.withOpacity(0.3), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.compare_arrows, color: primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Búsqueda en Anchura (BFS)',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Text(
                  '• Funcionamiento Computacional:\nUtiliza una estructura de datos tipo Cola (FIFO - First In, First Out). Explora nivel por nivel, visitando todos los vecinos inmediatos del nodo actual antes de pasar a los del siguiente nivel. Es el algoritmo óptimo para encontrar caminos mínimos en grafos sin pesos.',
                  style: textStyle,
                ),
                const SizedBox(height: 8),
                Text(
                  '• Fundamento Matemático:\n- Complejidad Temporal: O(V + E), donde V es la cantidad de Vértices (nodos) y E es la cantidad de Aristas (conexiones).\n- Complejidad Espacial: O(V) para registrar los nodos en cola y el conjunto de visitados.',
                  style: textStyle,
                ),
              ],
            ),
          ),
          // DFS Section
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: secondary.withOpacity(0.3), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.search, color: secondary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Búsqueda en Profundidad (DFS)',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Text(
                  '• Funcionamiento Computacional:\nUtiliza una estructura de datos tipo Pila (LIFO - Last In, First Out), típicamente implementada mediante recursividad. Explora lo más profundo posible a lo largo de cada rama antes de retroceder (backtracking) para explorar otros caminos alternos. Es ideal para verificar conectividad, detectar ciclos y ordenamiento topológico.',
                  style: textStyle,
                ),
                const SizedBox(height: 8),
                Text(
                  '• Fundamento Matemático:\n- Complejidad Temporal: O(V + E), ya que en el peor caso visita cada vértice y arista una única vez.\n- Complejidad Espacial: O(V) en el peor caso debido a la pila de recursión del sistema.',
                  style: textStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTheoryRepresentationsTab(bool isDark, Color primary, Color secondary) {
    final cardBg = isDark ? const Color(0xFF1B2236) : const Color(0xFFE8EDF5);
    final textStyle = TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13, height: 1.4);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'En MusicGraph AI, los datos del grafo musical se representan internamente de forma dual para maximizar tanto la eficiencia computacional como la claridad visual:',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 12),
          // Adjacency List Card
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primary.withOpacity(0.3), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.list, color: primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Lista de Adyacencia (Interna)',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Text(
                  '• Definición: Representa el grafo mediante un mapa clave-valor donde cada clave es un nodo y su valor es una lista de nodos vecinos.\n\n• Eficiencia: O(V + E) en almacenamiento de memoria. Es sumamente óptima para grafos dispersos (como las relaciones de artistas y géneros) y permite iterar de forma veloz sobre los vecinos inmediatos durante BFS y DFS.',
                  style: textStyle,
                ),
              ],
            ),
          ),
          // Adjacency Matrix Card
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: secondary.withOpacity(0.3), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.grid_on, color: secondary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Matriz de Adyacencia (Visual y Matemática)',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Text(
                  '• Definición: Una matriz bidimensional N x N donde el valor en la celda [i][j] es 1 si existe una arista del nodo i al nodo j, y 0 en caso contrario.\n\n• Aplicación en la App: Se calcula dinámicamente para representarse en la sección "Matemática", brindando al usuario un panel matemático interactivo y comprensible del mapa total de adyacencias.',
                  style: textStyle,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Identificación Visual de los Vértices (Nodos)',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          // Artist Node Preview
          _buildNodeLegendItem(
            isDark: isDark,
            title: 'Artista (Vértice)',
            color: isDark ? const Color(0xFF00E5FF) : const Color(0xFF0288D1),
            icon: Icons.mic,
            description: 'Representa a cantantes y creadores. En el lienzo se dibuja en azul con un micrófono en el centro.',
          ),
          // Song Node Preview
          _buildNodeLegendItem(
            isDark: isDark,
            title: 'Canción (Vértice)',
            color: isDark ? const Color(0xFF00FF87) : const Color(0xFF2E7D32),
            icon: Icons.music_note,
            description: 'Representa los sencillos o temas musicales. Se dibuja de color verde con una nota musical central.',
          ),
          // Genre Node Preview
          _buildNodeLegendItem(
            isDark: isDark,
            title: 'Género (Vértice)',
            color: isDark ? const Color(0xFFBD00FF) : const Color(0xFF7B1FA2),
            icon: Icons.queue_music,
            description: 'Representa agrupaciones de estilos musicales. Se renderiza en color morado con un ícono de lista.',
          ),
        ],
      ),
    );
  }

  Widget _buildTheoryValidationsTab(bool isDark, Color primary, Color secondary, Color accent) {
    final cardBg = isDark ? const Color(0xFF1B2236) : const Color(0xFFE8EDF5);
    final textStyle = TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13, height: 1.4);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Validation rules
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primary.withOpacity(0.3), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.verified_user, color: primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Validación de Conexiones',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Text(
                  'Para asegurar la integridad matemática del grafo, el sistema aplica las siguientes reglas de validación en tiempo real:\n\n'
                  '1. Evitar Auto-bucles (Self-loops): No se permite conectar un nodo consigo mismo (ej. Karol G conectada a Karol G). El sistema verifica que el nodo de origen sea diferente al de destino.\n\n'
                  '2. Evitar Multigrafos (Arcos paralelos redundantes): Si la conexión ya existe en el sentido actual del grafo, el controlador descarta la nueva inserción, manteniendo el grafo simple.',
                  style: textStyle,
                ),
              ],
            ),
          ),
          // Restrictions
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: secondary.withOpacity(0.3), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.settings_input_component, color: secondary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Restricciones por Direccionalidad',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Text(
                  'El usuario puede alternar la direccionalidad del grafo musical de manera global, aplicando restricciones específicas en los algoritmos y la matriz de adyacencia:\n\n'
                  '• Grafo Dirigido (Flecha unidireccional):\n'
                  '- Las conexiones son de un solo sentido (A → B no implica B → A).\n'
                  '- La Matriz de Adyacencia resultante es típicamente asimétrica.\n'
                  '- Los recorridos BFS/DFS respetan estrictamente el sentido del arco.\n\n'
                  '• Grafo No Dirigido (Línea bidireccional):\n'
                  '- Las conexiones son simétricas y de doble sentido (A ↔ B).\n'
                  '- La Matriz de Adyacencia es estrictamente simétrica respecto a su diagonal principal (A = A^T).\n'
                  '- Al insertar una conexión, el controlador la propaga internamente agregando la arista simétrica en la lista de adyacencia.',
                  style: textStyle,
                ),
              ],
            ),
          ),
          // UX & Visual Representation
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accent.withOpacity(0.3), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.remove_red_eye, color: accent, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Guía Visual de Recorridos (UX)',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Text(
                  'Durante la simulación de algoritmos, los estados de los nodos se renderizan con animaciones y halos de luz diferenciados:\n\n'
                  '• Estado Normal (Apagado): El nodo conserva su color temático (Celeste para Artista, Verde para Canción, Morado para Género).\n\n'
                  '• Estado Activo (Escaneo - Rosa Neón): Indica el nodo exacto que la cabeza del algoritmo está analizando en ese microsegundo.\n\n'
                  '• Estado Visitado (Brillo Coloreado): El nodo ya fue procesado y su vecindad fue agregada a la cola o pila.\n\n'
                  '• Estado en Camino Mínimo (Oro/Amarillo): Representa los nodos que conforman el camino final resultante.',
                  style: textStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTheoryExamplesTab(BuildContext context, bool isDark, GraphController controller, Color accentColor) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Toca un ejemplo para cargarlo y ver cómo cambia el análisis automático en el lienzo.',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          _buildExampleCard(
            context: context,
            isDark: isDark,
            controller: controller,
            type: 'chain',
            title: 'Cadena básica',
            description: 'Cinco nodos en línea para entender recorridos y extremos.',
            tag: 'Principiante',
            tagColor: Colors.teal,
            icon: Icons.link,
          ),
          _buildExampleCard(
            context: context,
            isDark: isDark,
            controller: controller,
            type: 'cycle',
            title: 'Ciclo simple',
            description: 'Seis vértices formando un anillo cerrado y fácil de seguir.',
            tag: 'Principiante',
            tagColor: Colors.teal,
            icon: Icons.loop,
          ),
          _buildExampleCard(
            context: context,
            isDark: isDark,
            controller: controller,
            type: 'star',
            title: 'Estrella',
            description: 'Un nodo central con cinco hojas para ver grados y conectividad.',
            tag: 'Intermedio',
            tagColor: Colors.orange,
            icon: Icons.star_border,
          ),
          _buildExampleCard(
            context: context,
            isDark: isDark,
            controller: controller,
            type: 'tree',
            title: 'Árbol binario',
            description: 'Estructura jerárquica sin ciclos para practicar ramas.',
            tag: 'Intermedio',
            tagColor: Colors.orange,
            icon: Icons.account_tree_outlined,
          ),
          _buildExampleCard(
            context: context,
            isDark: isDark,
            controller: controller,
            type: 'disconnected',
            title: 'Grafo desconexo',
            description: 'Dos grupos separados para ver cómo el sistema detecta componentes.',
            tag: 'Intermedio',
            tagColor: Colors.orange,
            icon: Icons.flash_on_outlined,
          ),
          _buildExampleCard(
            context: context,
            isDark: isDark,
            controller: controller,
            type: 'complete',
            title: 'Grafo completo K5',
            description: 'Todos los nodos conectados entre sí para comparar densidad.',
            tag: 'Avanzado',
            tagColor: Colors.redAccent,
            icon: Icons.grid_view,
          ),
        ],
      ),
    );
  }

  Widget _buildExampleCard({
    required BuildContext context,
    required bool isDark,
    required GraphController controller,
    required String type,
    required String title,
    required String description,
    required String tag,
    required Color tagColor,
    required IconData icon,
  }) {
    final cardBg = isDark ? const Color(0xFF1B2236) : const Color(0xFFE8EDF5);
    final primaryColor = isDark ? const Color(0xFF00E5FF) : const Color(0xFF0288D1);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.1), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Dismiss the theory sheet first so sandbox displays clean
            Navigator.pop(context);
            
            // Show scale-animated sandbox dialog for safe interactive previewing
            showGeneralDialog(
              context: context,
              barrierDismissible: true,
              barrierLabel: 'Sandbox',
              barrierColor: Colors.black.withOpacity(0.65),
              transitionDuration: const Duration(milliseconds: 350),
              pageBuilder: (dialogCtx, anim1, anim2) {
                return ExampleSandboxDialog(
                  exampleType: type,
                  title: title,
                  icon: icon,
                  mainController: controller,
                );
              },
              transitionBuilder: (dialogCtx, anim1, anim2, child) {
                final curve = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
                return ScaleTransition(
                  scale: curve,
                  child: FadeTransition(
                    opacity: anim1,
                    child: child,
                  ),
                );
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Nice Left Icon Circle
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor.withOpacity(0.08),
                  ),
                  child: Icon(icon, color: primaryColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Dynamic tag
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: tagColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                color: tagColor,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: isDark ? Colors.white30 : Colors.black26,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNodeLegendItem({
    required bool isDark,
    required String title,
    required Color color,
    required IconData icon,
    required String description,
  }) {
    final cardBg = isDark ? const Color(0xFF1B2236) : const Color(0xFFE8EDF5);
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          // Simulated premium glowing node
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? const Color(0xFF111422) : Colors.white,
              border: Border.all(color: color, width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
              ],
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Main Build Method ---

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<GraphController>(context);
    final bool isDark = controller.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0D14) : const Color(0xFFF3F5F9),
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Core Background Grid and GraphVisualizer (full screen canvas!)
            Positioned.fill(
              child: Opacity(
                opacity: isDark ? 0.05 : 0.03,
                child: GridPaper(
                  color: isDark ? Colors.blueGrey : Colors.indigo,
                  interval: 80,
                  divisions: 2,
                  subdivisions: 4,
                ),
              ),
            ),
            Positioned.fill(
              child: GraphWidget(
                controller: controller,
                onNodeSelected: _handleNodeSelected,
              ),
            ),

            // 2. Floating Top HUD Bar (glassmorphic cyberpunk header)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF111422).withOpacity(0.85) : Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? const Color(0xFF00E5FF).withOpacity(0.2) : const Color(0xFF0288D1).withOpacity(0.15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.hub, color: isDark ? const Color(0xFF00E5FF) : const Color(0xFF0288D1), size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'MusicGraph AI',
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Dynamic Switch Mode Button (☀️/🌙)
                        IconButton(
                          icon: Icon(
                            isDark ? Icons.light_mode : Icons.dark_mode,
                            color: isDark ? Colors.amberAccent : const Color(0xFF7B1FA2),
                          ),
                          tooltip: 'Cambiar Modo de Color',
                          onPressed: () {
                            controller.toggleTheme();
                          },
                        ),
                        // Theory button (moved next to mode switch!)
                        IconButton(
                          icon: Icon(
                            Icons.school,
                            color: isDark ? const Color(0xFFFFD700) : const Color(0xFFE65100),
                          ),
                          tooltip: 'Teoría y Ejemplos',
                          onPressed: () => _openTheorySheet(context, controller),
                        ),
                        const SizedBox(width: 6),
                        // Refresh Preloaded Button
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Color(0xFF00FF87)),
                          tooltip: 'Datos Iniciales',
                          onPressed: () {
                            controller.resetGraph();
                            setState(() {
                              _connectionSource = null;
                              _connectionTarget = null;
                              _algoStart = null;
                              _algoTarget = null;
                              _inspectingNode = null;
                            });
                          },
                        ),
                        // Clear canvas button
                        IconButton(
                          icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                          tooltip: 'Limpiar Lienzo',
                          onPressed: () {
                            controller.clearGraph();
                            setState(() {
                              _connectionSource = null;
                              _connectionTarget = null;
                              _algoStart = null;
                              _algoTarget = null;
                              _inspectingNode = null;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Row(
                                  children: [
                                    Icon(Icons.delete_sweep, color: Colors.white, size: 20),
                                    const SizedBox(width: 8),
                                    Text('Lienzo limpiado por completo'),
                                  ],
                                ),
                                backgroundColor: Colors.redAccent,
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          },
                        ),
                        // Direct Config Toggle: Grafo Dirigido
                        IconButton(
                          icon: Icon(
                            controller.isDirected ? Icons.arrow_right_alt : Icons.swap_horiz,
                            color: controller.isDirected ? Colors.pinkAccent : Colors.grey,
                          ),
                          tooltip: controller.isDirected ? 'Grafo Dirigido' : 'Grafo No Dirigido',
                          onPressed: () {
                            controller.toggleGraphDirected();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 3. Ambient Help Overlay (glowing prompt guide)
            Positioned(
              top: 76,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF111422).withOpacity(0.65) : Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.zoom_out_map, color: isDark ? const Color(0xFF00E5FF) : const Color(0xFF0288D1), size: 12),
                    const SizedBox(width: 6),
                    Text(
                      'Pellizca para zoom. Arrastra para panear.',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Interactive Node Inspect Card Overlay (Tapping a node displays details sheet)
            if (_inspectingNode != null)
              Positioned(
                bottom: 84,
                left: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF111422).withOpacity(0.95) : Colors.white.withOpacity(0.98),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: _inspectingNode!.getColor(isDark), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: _inspectingNode!.getColor(isDark).withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: _inspectingNode!.getColor(isDark).withOpacity(0.15),
                            radius: 22,
                            child: Icon(_inspectingNode!.icon, color: _inspectingNode!.getColor(isDark), size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _inspectingNode!.name,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '${_inspectingNode!.typeString} • Conexiones: ${controller.getDegreeForNode(_inspectingNode!)}',
                                  style: TextStyle(
                                    color: isDark ? Colors.white60 : Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () {
                              setState(() {
                                _inspectingNode = null;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Quick Action mapping buttons for connection or algorithm
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: isDark ? const Color(0xFF00E5FF) : const Color(0xFF0288D1)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              icon: const Icon(Icons.play_circle_fill, size: 14),
                              label: const Text('Iniciar Ruta', style: TextStyle(fontSize: 11)),
                              onPressed: () {
                                setState(() {
                                  _algoStart = _inspectingNode;
                                  _connectionSource = _inspectingNode;
                                });
                                _showSuccessSnackBar('"${_inspectingNode!.name}" fijada como Origen.');
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: isDark ? const Color(0xFFFFD700) : const Color(0xFFE65100)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              icon: const Icon(Icons.flag, size: 14),
                              label: const Text('Fijar Destino', style: TextStyle(fontSize: 11)),
                              onPressed: () {
                                setState(() {
                                  _algoTarget = _inspectingNode;
                                  _connectionTarget = _inspectingNode;
                                });
                                _showSuccessSnackBar('"${_inspectingNode!.name}" fijada como Destino.');
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // 5. Visual Floating Bottom Pill Menu (Creative cell phone control capsule!)
            Positioned(
              bottom: 16,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF151828).withOpacity(0.92) : Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.12) : Colors.grey.withOpacity(0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Button 1: Create
                    _buildFloatingMenuButton(
                      icon: Icons.dashboard_customize,
                      label: 'Estructuras',
                      color: isDark ? const Color(0xFF00FF87) : const Color(0xFF2E7D32),
                      onPressed: () => _openStructuresSheet(context, controller),
                    ),
                    // Button 2: Run algorithms
                    _buildFloatingMenuButton(
                      icon: Icons.rocket_launch,
                      label: 'Algoritmos',
                      color: isDark ? const Color(0xFFFF007F) : const Color(0xFF7B1FA2),
                      onPressed: () => _openAlgorithmsSheet(context, controller),
                    ),
                    // Button 3: Stats math
                    _buildFloatingMenuButton(
                      icon: Icons.bar_chart,
                      label: 'Matemática',
                      color: isDark ? const Color(0xFF00E5FF) : const Color(0xFF0288D1),
                      onPressed: () => _openMathematicsSheet(context, controller),
                    ),
                  ],
                ),
              ),
            ),

            // 6. Full Screen scanning scan banner overlay during search
            if (controller.isAlgorithmRunning)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.55),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF151829) : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isDark ? const Color(0xFFFF007F) : const Color(0xFF7B1FA2),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isDark ? const Color(0xFFFF007F) : const Color(0xFF7B1FA2)).withOpacity(0.3),
                            blurRadius: 20,
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark ? const Color(0xFFFF007F) : const Color(0xFF7B1FA2),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Escaneo de ${controller.algorithmType} en curso',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Visitando: ${controller.activeTraversalNode?.name ?? "..."}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark ? const Color(0xFF00E5FF) : const Color(0xFF0288D1),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent.withOpacity(0.3),
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.redAccent),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.stop, size: 16),
                            label: const Text('Detener Animación'),
                            onPressed: () {
                              controller.stopAnimation();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- Sub-widgets and internal UI helpers ---

  Widget _buildFloatingMenuButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildNodeSelector({
    required String label,
    required MusicNode? value,
    required List<MusicNode> nodes,
    required Color color,
    required bool isDark,
    required ValueChanged<MusicNode?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 11),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<MusicNode>(
          value: value,
          dropdownColor: isDark ? const Color(0xFF111422) : Colors.white,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 13),
          isExpanded: true,
          hint: Text('Seleccionar nodo...', style: TextStyle(color: isDark ? Colors.white30 : Colors.black38, fontSize: 13)),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? const Color(0xFF1B2236) : const Color(0xFFE8EDF5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          ),
          items: nodes.map((node) {
            return DropdownMenuItem<MusicNode>(
              value: node,
              child: Row(
                children: [
                  Icon(node.icon, color: node.getColor(isDark), size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      node.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildMathStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11.5),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                shadows: [
                  Shadow(color: color.withOpacity(0.2), blurRadius: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
