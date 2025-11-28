import 'package:flutter/material.dart';
import 'package:frontend/core/services/api_client.dart';
import 'saved_builds_screen.dart' show SavedBuild, SavedBuildsPage;
import 'package:frontend/features/cart/widgets/checkout_modal.dart';

class SavedBuildDetailsPage extends StatefulWidget {
  final SavedBuild savedBuild;

  const SavedBuildDetailsPage({super.key, required this.savedBuild});

  @override
  State<SavedBuildDetailsPage> createState() => _SavedBuildDetailsPageState();
}

class _SavedBuildDetailsPageState extends State<SavedBuildDetailsPage> {
  final ApiClient _api = ApiClient.create();

  Map<String, dynamic> expanded = {};
  Map<String, dynamic> summary = {};
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final res = await _api.get("/builder/my/${widget.savedBuild.id}");
      final build = res["build"] ?? {};

      if (!mounted) return;
      setState(() {
        expanded =
            build["expanded"] ?? build["components"] ?? build["preview"] ?? {};
        summary = res["summary"] ?? {};
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  String formatPrice(double v) {
    return v
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => "${m[1]},",
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.savedBuild.name)),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadDetails,
                    child: const Text("Retry"),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (expanded.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        "No components found",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...expanded.entries.map((entry) {
                    final category = entry.key;
                    final comp = entry.value;

                    if (comp == null || comp is! Map<String, dynamic>) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "$category component is missing or deleted",
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final c = comp;
                    final imageUrl = c["image_url"]?.toString() ?? "";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: imageUrl.isNotEmpty
                                    ? Image.network(
                                        imageUrl,
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 70,
                                        height: 70,
                                        color: Colors.grey.shade300,
                                        child: Icon(
                                          Icons.memory,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  c["name"] ?? "Unnamed",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                "₱${formatPrice(double.tryParse(c['price'].toString()) ?? 0)}",
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total Price: ₱${formatPrice(double.tryParse(summary["total_price"].toString()) ?? 0)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Power Usage: ${summary["power_usage"] ?? 0}W",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // ADD TO CART
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await _api.post(
                        "/cart/add-build/${widget.savedBuild.id}",
                        null,
                      );

                      // remove from saved list
                      await _api.delete("/builder/my/${widget.savedBuild.id}");

                      SavedBuildsPage.shouldRefresh = true;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Build added to cart!")),
                      );

                      Navigator.pop(context, true);
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("Error: $e")));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Add to Cart",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // CHECKOUT
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    showCheckoutModal(
                      context,
                      [
                        {
                          "name": widget.savedBuild.name,
                          "price": widget.savedBuild.price,
                          "quantity": 1,
                          "bundle_item_count": expanded.length,
                        },
                      ],
                      () async {
                        // CHECKOUT REQUEST
                        final result = await _api.post(
                          "/checkout/build/${widget.savedBuild.id}",
                          {"payment_method": "cod", "notes": null},
                        );

                        SavedBuildsPage.shouldRefresh = true;

                        // ⭐ DO NOT POP PAGE HERE
                        // The modal will close itself.
                        // The success screen will handle navigation.

                        return result;
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Checkout Now",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
