import 'package:flutter/material.dart';
import 'package:pc_component_picker/core/services/api_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeaturedBuildDetailScreen extends ConsumerStatefulWidget {
  static const routeName = "/featured-build-detail";

  const FeaturedBuildDetailScreen({super.key});

  @override
  ConsumerState<FeaturedBuildDetailScreen> createState() =>
      _FeaturedBuildDetailScreenState();
}

class _FeaturedBuildDetailScreenState
    extends ConsumerState<FeaturedBuildDetailScreen> {
  Map<String, dynamic>? buildData;
  bool loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final id = args["id"];

    _loadBuild(id);
  }

  Future<void> _loadBuild(String id) async {
    final api = ref.read(apiClientProvider);

    final res = await api.get("/featuredbuildspublic/$id");

    setState(() {
      buildData = res["data"];
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final items = buildData?["items"] ?? [];

    int totalWattage = 0;

    for (final item in items) {
      final comp = item["components"];
      final specs = comp?["specs"] ?? {};

      final watt = specs["tdp"] ?? specs["wattage"] ?? specs["Wattage"] ?? 0;

      totalWattage += (watt is num ? watt.toInt() : 0);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Featured Build"),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              buildData?["title"] ?? "",
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              buildData?["description"] ?? "",
              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),

            const Text(
              "Included Components",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),

            if (items.isEmpty)
              const Text(
                "No components assigned yet.",
                style: TextStyle(color: Colors.grey),
              ),

            ...items.map((item) {
              final comp = item["components"];
              return Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: comp["image_url"] != null
                          ? Image.network(
                              comp["image_url"],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[300],
                            ),
                    ),
                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comp["name"] ?? "",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            comp["brand"] ?? "",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      "₱${comp["price"]}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 20),

            const Text(
              "Summary",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _row("Total Price", "₱${buildData?["total_price"]}"),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
}
