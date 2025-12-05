// lib/features/orders/screens/saved_build_details_page.dart

import 'package:flutter/material.dart';
import 'package:pc_component_picker/core/services/api_client.dart';
import 'saved_builds_screen.dart' show SavedBuild, SavedBuildsPage;

class SavedBuildDetailsPage extends StatefulWidget {
  final SavedBuild savedBuild;

  const SavedBuildDetailsPage({super.key, required this.savedBuild});

  @override
  State<SavedBuildDetailsPage> createState() => _SavedBuildDetailsPageState();
}

class _SavedBuildDetailsPageState extends State<SavedBuildDetailsPage> {
  final ApiClient _api = ApiClient.create();

  Map<String, dynamic> expanded = {};
  bool loading = true;
  String? error;

  // Colors (match your global theme)
  final Color blue = const Color(0xFF2563EB);
  final Color blueLight = const Color(0xFF3B82F6);
  final Color green = const Color(0xFF22C55E);
  final Color bgGrey = const Color(0xFFF8FAFC);
  final Color darkText = const Color(0xFF1E293B);

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

  String formatPrice(num value) {
    final s = value.toStringAsFixed(0);
    return s.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => "${m[1]},",
    );
  }

  // COMPONENT CARD — matched to your UI style
  Widget _componentCard(String category, Map<String, dynamic> c) {
    final price = double.tryParse(c["price"]?.toString() ?? "0") ?? 0.0;
    final imageUrl = c["image_url"]?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 68,
              height: 68,
              color: blue.withOpacity(0.1),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(imageUrl, fit: BoxFit.cover)
                  : Icon(Icons.memory, size: 26, color: blue),
            ),
          ),

          const SizedBox(width: 12),

          // TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.toUpperCase(),
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  c["name"] ?? "Unnamed",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: darkText,
                  ),
                ),
              ],
            ),
          ),

          // PRICE
          Text(
            "₱${formatPrice(price)}",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: green,
            ),
          ),
        ],
      ),
    );
  }

  // CHECKOUT SHEET (no UI changes needed but improved visuals)
  void _showCheckout() {
    final subtotal = widget.savedBuild.price;
    const shipping = 150;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        bool isProc = false;

        return StatefulBuilder(
          builder: (_, setSheet) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.75,
            builder: (_, scroll) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgGrey,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    const Text(
                      "Order Summary",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // TOTAL AREA
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _summaryRow("Subtotal", subtotal),
                          _summaryRow("Shipping Fee", shipping),
                          const Divider(height: 16),
                          _summaryRow("Total", subtotal + shipping, bold: true),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isProc
                            ? null
                            : () async {
                                setSheet(() => isProc = true);

                                try {
                                  final res = await _api.post(
                                    "/checkout/build/${widget.savedBuild.id}",
                                    {"payment_method": "cod"},
                                  );

                                  SavedBuildsPage.refreshTrigger.value = true;

                                  Navigator.pop(context);
                                  Navigator.pushReplacementNamed(
                                    context,
                                    "/order-success",
                                    arguments: {"orderId": res["order"]["id"]},
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Failed: $e")),
                                  );
                                }

                                setSheet(() => isProc = false);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          isProc ? "Processing..." : "Confirm Order",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _summaryRow(String label, num amount, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          Text(
            "₱${formatPrice(amount)}",
            style: TextStyle(
              fontSize: bold ? 17 : 14,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: bold ? blue : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------
  // MAIN UI
  // ----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          "Saved Build Details",
          style: TextStyle(color: Colors.white),
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

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text("Error: $error"))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: expanded.entries.map((e) {
                final comp = e.value;

                if (comp == null || comp is! Map)
                  return const SizedBox.shrink();

                return _componentCard(
                  e.key.toString(),
                  Map<String, dynamic>.from(comp as Map),
                );
              }).toList(),
            ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // ADD TO CART — Soft Blue
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await _api.post(
                        "/cart/add-build/${widget.savedBuild.id}",
                        null,
                      );

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
                    backgroundColor: const Color(0xFF3B82F6), // soft blue
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Add to Cart",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // CHECKOUT NOW — Deep Royal Blue
              Expanded(
                child: ElevatedButton(
                  onPressed: _showCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4ED8), // deep royal blue
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Checkout Now",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
