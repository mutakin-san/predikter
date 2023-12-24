import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class ARPage extends StatefulWidget {
  const ARPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ARPageState();
  }
}

class _ARPageState extends State<ARPage> {
  late ArCoreController arCoreController;
  List<ArCoreNode> points = [];
  List<vector.Vector3> pointPositions = [];
  bool enablePlaneRenderer = false;

  double distance1 = 0.0;
  double distance2 = 0.0;

  int maxPoints = 4;

  ArCoreNode? selectedPoint; // Keep track of the selected point

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onPanUpdate: (details) async {
                if (selectedPoint != null) {
                  _handlePointDrag(details.delta);
                }
              },
              child: ArCoreView(
                enablePlaneRenderer: enablePlaneRenderer,
                debug: true,
                onArCoreViewCreated: onARViewCreated,
                enableUpdateListener: true,
                enableTapRecognizer: true,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildDistanceText('Diameter Dada:', distance1),
                _buildDistanceText('Panjang Badan:', distance2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void onARViewCreated(ArCoreController controller) {
    arCoreController = controller;
    arCoreController.onPlaneTap = _handlePlaneTap;
    arCoreController.onNodeTap = (name) {
      final point = points.firstWhere((item) => item.name == name);
      _handlePointTap(point);
    };
  }

  void _handlePlaneTap(List<ArCoreHitTestResult> hits) {
    if (points.length < maxPoints) {
      if (hits.isNotEmpty) {
        final hit = hits.first;
        _placePoint(hit);
        _drawLinesAndMeasureDistances();
      }
    }
  }

  void _placePoint(ArCoreHitTestResult hit) {
    final point = ArCoreNode(
      shape: ArCoreSphere(
        radius: 0.01,
        materials: [
          ArCoreMaterial(color: points.length >= 2 ? Colors.red : Colors.blue)
        ],
      ),
      position: hit.pose.translation,
    );

    points.add(point);
    pointPositions.add(hit.pose.translation);
    arCoreController.addArCoreNodeWithAnchor(point);

    // Set the newly placed point as the selected point
    selectedPoint = point;
  }

  void _handlePointTap(ArCoreNode point) {
    // Set the tapped point as the selected point
    selectedPoint = point;
  }

  void _handlePointDrag(Offset delta) {
    arCoreController.removeNode(nodeName: selectedPoint?.name);

    final currentPosition = selectedPoint!.position!.value;

    final newPosition = vector.Vector3(
      currentPosition.x + delta.dx / 500, // Scale down the movement
      currentPosition.y - delta.dy / 500,
      currentPosition.z,
    );

    selectedPoint!.position!.value = newPosition;
    // Update the position in the list
    final index = points.indexOf(selectedPoint!);
    if (index != -1) {
      pointPositions[index] = newPosition;
    }

    arCoreController.addArCoreNodeWithAnchor(selectedPoint!);

    _drawLinesAndMeasureDistances();
  }

  void _drawLinesAndMeasureDistances() {
    if (points.length >= 2) {
      // Calculate and print distance between the last 2 points
      final distance = _calculateDistance(
          pointPositions[pointPositions.length - 2], pointPositions.last);

      setState(() {
        distance1 = distance;
      });
    }

    if (points.length >= 4) {
      final double distance = _calculateDistance(
          pointPositions[pointPositions.length - 4],
          pointPositions[pointPositions.length - 3]);
      setState(() {
        distance2 = distance;
      });
    }
  }

  Widget _buildDistanceText(String label, double distance) {
      return Text('$label ${distance.toStringAsFixed(2)} cm');
  }

  double _calculateDistance(
      vector.Vector3 position1, vector.Vector3 position2) {
    return position1.distanceTo(position2) * 100;
  }

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }
}
