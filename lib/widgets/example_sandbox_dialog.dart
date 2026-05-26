import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../graph/graph_controller.dart';
import '../widgets/graph_widget.dart';

class ExampleSandboxDialog extends StatefulWidget {
  final String exampleType;
  final String title;
  final IconData icon;
  final GraphController mainController;

  const ExampleSandboxDialog({
    super.key,
    required this.exampleType,
    required this.title,
    required this.icon,
    required this.mainController,
  });

  @override
  State<ExampleSandboxDialog> createState() => _ExampleSandboxDialogState();
}

class _ExampleSandboxDialogState extends State<ExampleSandboxDialog> {
  late GraphController _sandboxController;

  @override
  void initState() {
    super.initState();
    // Instantiate a dedicated, isolated GraphController for this sandbox simulation!
    _sandboxController = GraphController();
    // Load the example into this local sandbox
    _sandboxController.loadExampleGraph(widget.exampleType, clearCurrent: true);
    // No autoplay: user will control algorithms manually from the sandbox UI.
  }

  @override
  void dispose() {
    _sandboxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.mainController.isDarkMode;
    
    // Aesthetic themes matching the main app
    final Color modalBg = isDark ? const Color(0xFF0F1322) : const Color(0xFFF0F4FA);
    final Color cardBg = isDark ? const Color(0xFF1B2236) : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color subtitleColor = isDark ? Colors.white70 : Colors.black54;
    final Color accentColor = isDark ? const Color(0xFF00E5FF) : const Color(0xFF0288D1);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.92,
          height: MediaQuery.of(context).size.height * 0.85,
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 750),
          decoration: BoxDecoration(
            color: modalBg.withOpacity(0.95),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: accentColor.withOpacity(0.25), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(isDark ? 0.15 : 0.08),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ChangeNotifierProvider<GraphController>.value(
            value: _sandboxController,
            child: Consumer<GraphController>(
              builder: (context, controller, child) {
                // Calculate properties locally for this sandbox topology
                final maxConnectedNode = controller.getMostConnectedNode();
                final int maxDegree = maxConnectedNode != null ? controller.getDegreeForNode(maxConnectedNode) : 0;
                final double density = controller.getGraphDensity();

                return Column(
                  children: [
                    // --- Sandbox Header ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(widget.icon, color: accentColor, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '🔬 Laboratorio: ${widget.title}',
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                        softWrap: true,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                                      ),
                                      child: const Text(
                                        'Sandbox',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Entorno interactivo. Prueba algoritmos antes de aplicar al lienzo.',
                                  style: TextStyle(
                                    color: subtitleColor,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: textColor.withOpacity(0.7)),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // --- Mini Interactive Graph Canvas ---
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardBg.withOpacity(isDark ? 0.4 : 0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: GraphWidget(
                          controller: controller,
                          onNodeSelected: (node) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Nodo seleccionado: ${node.name} (${node.typeString})'),
                                backgroundColor: accentColor,
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          },
                          autoLayout: false,
                        ),
                      ),
                    ),

                    // --- Sandbox Algorithm Controls ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildSandboxAlgoButton(
                            label: 'BFS (Anchura)',
                            icon: Icons.grid_3x3,
                            color: Colors.purple,
                            isActive: controller.isAlgorithmRunning && controller.algorithmType == 'BFS',
                            onTap: () {
                              if (controller.nodes.isNotEmpty) {
                                controller.startBFS(start: controller.nodes.first);
                              }
                            },
                          ),
                          _buildSandboxAlgoButton(
                            label: 'DFS (Profundidad)',
                            icon: Icons.route,
                            color: Colors.indigo,
                            isActive: controller.isAlgorithmRunning && controller.algorithmType == 'DFS',
                            onTap: () {
                              if (controller.nodes.isNotEmpty) {
                                controller.startDFS(start: controller.nodes.first);
                              }
                            },
                          ),
                          _buildSandboxAlgoButton(
                            label: 'Reiniciar',
                            icon: Icons.restart_alt,
                            color: Colors.grey,
                            isActive: false,
                            onTap: () {
                              controller.stopAnimation();
                            },
                          ),
                        ],
                      ),
                    ),

                    // --- Sandbox Topology Information Panel ---
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: cardBg.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.04),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMetricItem('Nodos', '${controller.nodes.length}', isDark),
                          _buildMetricItem('Conexiones', '${controller.edges.length}', isDark),
                          _buildMetricItem('Grado Máx', '$maxDegree', isDark),
                          _buildMetricItem('Densidad', density.toStringAsFixed(2), isDark),
                        ],
                      ),
                    ),

                    // --- Bottom Actions Section ---
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Row(
                        children: [
                          // OVERWRITE MAIN CANVAS
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.input, size: 18),
                              label: const Text(
                                'Cargar en Lienzo',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              onPressed: () {
                                widget.mainController.stopAnimation();
                                widget.mainController.loadExampleGraph(widget.exampleType, clearCurrent: true);
                                // Ensure main canvas stays in manual mode so applied positions persist
                                if (!widget.mainController.manualLayout) {
                                  widget.mainController.toggleManualLayout();
                                }
                                // Apply the exact node positions created inside the sandbox
                                widget.mainController.applyNodePositionsFrom(_sandboxController);
                                Navigator.pop(context); // Close sandbox
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Lienzo reemplazado con la topología "${widget.title}"'),
                                    backgroundColor: accentColor,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              },
                            ),
                          ),
                          // (Merge option removed — use 'Cargar en Lienzo' to overwrite)
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSandboxAlgoButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? color : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isActive ? Colors.white : color, size: 15),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: isDark ? const Color(0xFF00E5FF) : const Color(0xFF0288D1),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.black54,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
