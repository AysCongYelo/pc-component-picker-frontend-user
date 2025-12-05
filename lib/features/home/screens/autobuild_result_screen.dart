import 'package:flutter/material.dart';

class AutoBuildResultScreen extends StatelessWidget {
  static const routeName = '/autobuild-result';

  final Map<String, dynamic>? result;

  const AutoBuildResultScreen({Key? key, this.result}) : super(key: key);

  // Category icons (same vibes sa Cart + BuildTab)
  IconData _getIcon(String category) {
    switch (category.toLowerCase()) {
      case "cpu":
        return Icons.memory;
      case "gpu":
        return Icons.graphic_eq;
      case "motherboard":
        return Icons.developer_board;
      case "memory":
      case "ram":
        return Icons.sd_card;
      case "storage":
        return Icons.sd_storage;
      case "psu":
        return Icons.power;
      case "case":
        return Icons.devices;
      case "cpu_cooler":
      case "cooler":
        return Icons.ac_unit;
      default:
        return Icons.computer;
    }
  }

  String _format(int v) {
    return v.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        result ??
        (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?);

    if (args == null) {
      return const Scaffold(
        body: Center(child: Text("No build data received.")),
      );
    }

    final rawBuild = args['build'] ?? {};
    final summary = args['summary'] ?? {};
    final totalPrice = summary['total_price'];

    // HANDLE FLEXIBLE BACKEND FORMATS
    List<Map<String, dynamic>> parts = [];

    if (rawBuild is Map) {
      parts = rawBuild.entries.map((e) {
        final data = e.value ?? {};
        return {
          "category": e.key,
          "name": data["name"] ?? "Unknown",
          "price": data["price"] ?? 0,
          "brand": data["brand"] ?? "",
        };
      }).toList();
    } else if (rawBuild is List) {
      parts = rawBuild.map((data) {
        return {
          "category": data["category"] ?? "",
          "name": data["name"] ?? "Unknown",
          "price": data["price"] ?? 0,
          "brand": data["brand"] ?? "",
        };
      }).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'AutoBuild Result',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),

      // ---------------------------------------------------------------------
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // HEADER
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
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
                        "₱${_format(totalPrice)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.green,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ---------------------------------------------------------------------
              // COMPONENT LIST
              Expanded(
                child: parts.isEmpty
                    ? const Center(child: Text("No components generated"))
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: parts.length,
                        itemBuilder: (context, i) {
                          final p = parts[i];
                          final category = p["category"].toString();
                          final name = p["name"].toString();
                          final price = p["price"] is int
                              ? p["price"] as int
                              : int.tryParse("${p["price"]}") ?? 0;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey[200]!),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ICON
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getIcon(category),
                                    size: 28,
                                    color: Colors.blue,
                                  ),
                                ),

                                const SizedBox(width: 14),

                                // TEXTS
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          height: 1.3,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        category
                                            .replaceAll("_", " ")
                                            .toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // PRICE
                                Text(
                                  "₱${_format(price)}",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 8),

              // ---------------------------------------------------------------------
              // FOOTER BUTTONS
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Back"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Save Build not implemented yet"),
                          ),
                        );
                      },
                      child: const Text(
                        "Save Build",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
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
