import 'package:flutter/material.dart';
import 'package:frontend/core/services/api_client.dart';
import 'saved_build_details_page.dart';

class SavedBuild {
  final String id;
  final String name;
  final double price;
  final int powerUsage;
  final List<Map<String, dynamic>> components;

  SavedBuild({
    required this.id,
    required this.name,
    required this.price,
    required this.powerUsage,
    required this.components,
  });
}

class SavedBuildsPage extends StatefulWidget {
  static bool shouldRefresh = false; // ⭐ ADD THIS
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

  Future<void> _loadSavedBuilds() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final res = await _api.get("/builder/my"); // your endpoint

      if (res is Map && res["builds"] is List) {
        final data = res["builds"] as List;

        final loaded = data
            .map((b) {
              final comps = <Map<String, dynamic>>[];

              final raw = b["preview"];

              if (raw != null && raw is Map<String, dynamic>) {
                raw.forEach((cat, comp) {
                  if (comp is Map<String, dynamic>) {
                    comps.add({
                      "category": cat,
                      "name": comp["name"] ?? "Unknown",
                      "price": comp["price"] ?? 0,
                    });
                  }
                });
              }

              return SavedBuild(
                id: b["id"]?.toString() ?? "",
                name: b["name"] ?? "Unnamed Build",
                price:
                    double.tryParse((b["total_price"] ?? 0).toString()) ?? 0.0,
                powerUsage:
                    int.tryParse((b["power_usage"] ?? 0).toString()) ?? 0,
                components: comps,
              );
            })
            .where((s) => s.id.isNotEmpty)
            .toList();

        if (!mounted) return;
        setState(() {
          _savedBuilds = loaded;
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _savedBuilds = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// DELETE (or mark removed) on backend + update UI
  Future<void> _deleteBuild(String buildId) async {
    // optimistic UI: show spinner for this card? simple approach: disable whole screen
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      // call backend to remove (DELETE /builder/my/:id). use deleteUserBuild or removeFromSaved semantics.
      await _api.delete("/builder/my/$buildId");

      if (!mounted) return;
      setState(() {
        _savedBuilds.removeWhere((b) => b.id == buildId);
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Removed from Saved list")));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to remove saved build: $e")),
      );
    }
  }

  String formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => "${m[1]},",
        );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text("No Saved Builds", style: TextStyle(fontSize: 22)),
        ],
      ),
    );
  }

  Widget _buildBuildCard(SavedBuild build) {
    return GestureDetector(
      onTap: () async {
        // open details WITHOUT hiding bottom nav
        final result = await Navigator.of(context).push<bool>(
          PageRouteBuilder(
            opaque: false,
            barrierColor: Colors.black.withOpacity(0.05),
            pageBuilder: (_, __, ___) =>
                SavedBuildDetailsPage(savedBuild: build),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );

        // only reload if details returned true (means they modified/removed the build)
        if (result == true) {
          await _loadSavedBuilds();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Build Name + Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  build.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "₱${formatPrice(build.price)}",
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            // Delete button
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmAndDelete(build.id),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAndDelete(String buildId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove saved build?'),
        content: const Text('This will remove the build from your Saved list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await _deleteBuild(buildId);
    }
  }

  @override
  Widget build(BuildContext context) {
    // AUTO-REFRESH WHEN COMING FROM OTHER FLOW
    if (SavedBuildsPage.shouldRefresh) {
      SavedBuildsPage.shouldRefresh = false;
      _loadSavedBuilds();
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Saved Builds")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _savedBuilds.isEmpty
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: _savedBuilds.map(_buildBuildCard).toList(),
            ),
    );
  }
}
