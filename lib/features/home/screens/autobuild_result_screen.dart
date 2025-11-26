import 'package:flutter/material.dart';

class AutoBuildResultScreen extends StatelessWidget {
  static const routeName = '/autobuild-result';

  final Map<String, dynamic>? result;

  const AutoBuildResultScreen({Key? key, this.result}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get arguments safely
    final args =
        result ??
        (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?);

    if (args == null) {
      return const Scaffold(
        body: Center(child: Text("No build data received.")),
      );
    }

    // Backend returns various formats — handle all
    final rawBuild = args['build'] ?? {};
    final summary = args['summary'] ?? {};
    final totalPrice = summary['total_price'];

    // --- FIX 1: Extract parts safely ---
    List<Map<String, dynamic>> parts = [];

    if (rawBuild is Map) {
      // Example: { "cpu": {...}, "gpu": {...} }
      parts = rawBuild.entries.where((e) => e.value != null).map((e) {
        final comp = e.value;
        return {
          "category": e.key,
          "name": comp["name"] ?? "Unknown",
          "price": comp["price"] ?? 0,
          "brand": comp["brand"] ?? "",
        };
      }).toList();
    } else if (rawBuild is List) {
      // Example: [ {category: cpu, ...}, {category: gpu, ...} ]
      parts = rawBuild.where((e) => e != null).map((comp) {
        return {
          "category": comp["category"] ?? "Unknown",
          "name": comp["name"] ?? "Unknown",
          "price": comp["price"] ?? 0,
          "brand": comp["brand"] ?? "",
        };
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('AutoBuild Result'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // HEADER
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Generated Build",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (totalPrice != null)
                    Text(
                      "₱$totalPrice",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // PARTS LIST
              Expanded(
                child: parts.isEmpty
                    ? const Center(child: Text("No components generated"))
                    : ListView.separated(
                        itemCount: parts.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, i) {
                          final p = parts[i];

                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                p["category"]
                                        .toString()
                                        .substring(0, 1)
                                        .toUpperCase() ??
                                    "?",
                              ),
                            ),
                            title: Text(
                              p["name"],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              p["category"]
                                  .toString()
                                  .replaceAll("_", " ")
                                  .toUpperCase(),
                            ),
                            trailing: Text(
                              "₱${p["price"]}",
                              style: const TextStyle(color: Colors.blueAccent),
                            ),
                          );
                        },
                      ),
              ),

              // FOOTER
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Back"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Save Build not implemented yet"),
                          ),
                        );
                      },
                      child: const Text("Save Build"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
