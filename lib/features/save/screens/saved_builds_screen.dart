import 'package:flutter/material.dart';
import 'package:frontend/core/services/api_client.dart';

class SavedBuild {
  final String id;
  final String name;
  final double price;
  final List<Map<String, dynamic>> components;

  SavedBuild({
    required this.id,
    required this.name,
    required this.price,
    required this.components,
  });
}

class SavedBuildsPage extends StatefulWidget {
  const SavedBuildsPage({Key? key}) : super(key: key);

  @override
  _SavedBuildsPageState createState() => _SavedBuildsPageState();
}

class _SavedBuildsPageState extends State<SavedBuildsPage> {
  final ApiClient _api = ApiClient.create();

  List<SavedBuild> _savedBuilds = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSavedBuilds();
  }

  // ---------------------------------------------------------------------------
  // FETCH SAVED BUILDS
  // ---------------------------------------------------------------------------
  Future<void> _loadSavedBuilds() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final res = await _api.get("/builder/my");

      if (res is Map && res["builds"] is List) {
        final List<dynamic> data = res["builds"];

        _savedBuilds = data.map((b) {
          final comps = <Map<String, dynamic>>[];

          if (b["components"] != null && b["components"] is Map) {
            (b["components"] as Map).forEach((cat, comp) {
              if (comp != null && comp is Map) {
                comps.add({
                  "category": cat,
                  "name": comp["name"],
                  "price": comp["price"],
                });
              }
            });
          }

          return SavedBuild(
            id: b["id"],
            name: b["name"] ?? "Unnamed Build",
            price: double.tryParse(b["total_price"].toString()) ?? 0.0,
            components: comps,
          );
        }).toList();
      } else {
        throw Exception("Unexpected API response structure");
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // DELETE BUILD
  // ---------------------------------------------------------------------------
  Future<void> _deleteBuild(String buildId) async {
    try {
      await _api.delete("/builds/$buildId");

      setState(() {
        _savedBuilds.removeWhere((b) => b.id == buildId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Build deleted"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // CHECKOUT WITH METHOD
  // ---------------------------------------------------------------------------
  Future<void> _checkoutBuild(
    SavedBuild build, {
    required String method,
  }) async {
    try {
      final res = await _api.post("/checkout/build/${build.id}", {
        "payment_method": method,
      });

      final orderId = res["order"]["id"];

      Navigator.pushNamed(
        context,
        "/order-success",
        arguments: {"orderId": orderId},
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Checkout failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // PAYMENT METHOD POPUP
  // ---------------------------------------------------------------------------
  void _showPaymentMethodSheet(SavedBuild build) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Select Payment Method",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              // COD BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _checkoutBuild(build, method: "cod");
                  },
                  child: const Text(
                    "Cash on Delivery (COD)",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // FORMAT PRICE
  // ---------------------------------------------------------------------------
  String formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  // ---------------------------------------------------------------------------
  // UI - EMPTY STATE
  // ---------------------------------------------------------------------------
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.bookmark_border, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "No Saved Builds",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("Save builds to see them here"),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD CARD
  // ---------------------------------------------------------------------------
  Widget _buildBuildCard(SavedBuild build) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                build.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "₱${formatPrice(build.price)}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Component preview
          ...build.components.map(
            (c) => Text(
              "• ${c["category"].toUpperCase()}: ${c["name"]}",
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),

          const SizedBox(height: 16),

          // Delete + Checkout
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => _deleteBuild(build.id),
                  child: const Text("Delete"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () => _showPaymentMethodSheet(build),
                  child: const Text("Checkout"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MAIN UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(child: Text("Error: $_error"));
    }

    if (_savedBuilds.isEmpty) return _buildEmptyState();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: _savedBuilds.map(_buildBuildCard).toList(),
    );
  }
}
