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
  static bool shouldRefresh = false;

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

      final res = await _api.get("/builder/my");

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

  Future<void> _deleteBuild(String buildId) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
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

  // ------------------------------
  // EMPTY STATE UI
  // ------------------------------
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.computer_rounded, size: 90, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            "No Saved Builds",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Your saved PC builds will appear here.",
            style: TextStyle(color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  // ------------------------------
  // BUILD CARD UI (FUNCTION-SAFE)
  // ------------------------------
  Widget _buildBuildCard(SavedBuild build) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => SavedBuildDetailsPage(savedBuild: build),
          ),
        );

        if (result == true) {
          await _loadSavedBuilds();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // LEFT SIDE INFO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    build.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "₱${formatPrice(build.price)}",
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ),

            // DELETE BUTTON
            IconButton(
              icon: const Icon(
                Icons.delete_rounded,
                color: Color(0xFFF43F5E),
                size: 26,
              ),
              onPressed: () => _confirmAndDelete(build.id),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------
  // CONFIRM DELETE
  // ------------------------------
  Future<void> _confirmAndDelete(String buildId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Remove saved build?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'This will remove the build from your Saved list.',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF43F5E),
              foregroundColor: Colors.white,
            ),
            child: const Text("Remove"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (ok == true) _deleteBuild(buildId);
  }

  // ------------------------------
  // MAIN BUILD
  // ------------------------------
  @override
  Widget build(BuildContext context) {
    if (SavedBuildsPage.shouldRefresh) {
      SavedBuildsPage.shouldRefresh = false;
      _loadSavedBuilds();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Saved Builds",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
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
