import 'package:flutter/material.dart';
import 'package:frontend/core/services/api_client.dart';
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
  Map<String, dynamic> summary = {};
  bool loading = true;
  String? error;

  // ------- shared colors -------
  Color get _primaryBlue => const Color(0xFF2563EB);
  Color get _primaryBlueLight => const Color(0xFF3B82F6);
  Color get _softGreen => const Color(0xFF22C55E);
  Color get _softGreyBg => const Color(0xFFF3F4F6);
  Color get _textDark => const Color(0xFF111827);

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

  String _formatCurrency(num value) {
    final s = value.toStringAsFixed(2);
    final parts = s.split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formattedInt = intPart.replaceAllMapped(reg, (m) => '${m[1]},');

    return '₱$formattedInt.$decPart';
  }

  // --------------------------------------------------
  // CHECKOUT BOTTOM SHEET PARA SA ISANG SAVED BUILD
  // --------------------------------------------------
  void _showCheckoutForThisBuild() {
    final parentContext = context;

    // gawin nating list yung laman ng `expanded`
    final List<Map<String, dynamic>> bundleComponents = [];
    expanded.forEach((cat, comp) {
      if (comp is Map<String, dynamic>) {
        bundleComponents.add({
          "category": cat,
          "name": comp["name"] ?? "Unknown",
          "price": comp["price"] ?? comp["component_price"] ?? 0,
        });
      }
    });

    final double subtotal = widget.savedBuild.price;
    const double shippingFee = 150;
    const double tax = 0;

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        bool isProcessing = false;

        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.75,
              maxChildSize: 0.9,
              minChildSize: 0.5,
              expand: false,
              builder: (_, scrollController) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _softGreyBg,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Text(
                        "Order Summary",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ------------ SCROLL CONTENT ------------
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          children: [
                            // HEADER CARD FOR THIS BUILD

                            // COMPONENTS LIST (if meron)
                            if (bundleComponents.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.view_list_rounded,
                                          size: 18,
                                          color: Colors.grey[700],
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "Bundle items",
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: _textDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ...bundleComponents.map((comp) {
                                      final compName =
                                          (comp["name"] ?? "Unknown component")
                                              .toString();
                                      final compCat = (comp["category"] ?? "")
                                          .toString()
                                          .toUpperCase();
                                      final compPrice = comp["price"] ?? 0;
                                      final numPrice = (compPrice is num)
                                          ? compPrice
                                          : num.tryParse(
                                                  compPrice.toString(),
                                                ) ??
                                                0;
                                      final priceText = _formatCurrency(
                                        numPrice,
                                      );

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    compName,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: _textDark,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  if (compCat.isNotEmpty)
                                                    Text(
                                                      compCat,
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              priceText,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: _softGreen,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      // ------------ TOTAL CARD ------------
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _summaryRow("Subtotal", _formatCurrency(subtotal)),
                            _summaryRow(
                              "Shipping Fee",
                              _formatCurrency(shippingFee),
                            ),
                            _summaryRow("Tax", _formatCurrency(tax)),
                            const Divider(height: 20),
                            _summaryRow(
                              "Total",
                              _formatCurrency(subtotal + shippingFee + tax),
                              bold: true,
                              big: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ------------ CONFIRM BUTTON ------------
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: _primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: isProcessing
                              ? null
                              : () async {
                                  setSheetState(() {
                                    isProcessing = true;
                                  });

                                  try {
                                    final res = await _api.post(
                                      "/checkout/build/${widget.savedBuild.id}",
                                      {"payment_method": "cod", "notes": null},
                                    );

                                    SavedBuildsPage.shouldRefresh = true;

                                    if (!ctx.mounted) return;
                                    Navigator.pop(modalContext);

                                    Navigator.pushReplacementNamed(
                                      ctx,
                                      "/order-success",
                                      arguments: {
                                        "orderId": res["order"]["id"],
                                      },
                                    );
                                  } catch (e) {
                                    if (!ctx.mounted) return;
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                      SnackBar(
                                        content: Text("Checkout failed: $e"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } finally {
                                    if (ctx.mounted) {
                                      setSheetState(() {
                                        isProcessing = false;
                                      });
                                    }
                                  }
                                },
                          child: Text(
                            isProcessing ? "Processing..." : "Confirm Order",
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
            );
          },
        );
      },
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool bold = false,
    bool big = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: big ? 16 : 13,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
              color: _textDark,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: big ? 18 : 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: bold ? _primaryBlue : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- COMPONENT CARD (new layout) ----------
  Widget _componentCard(String category, Map<String, dynamic> c) {
    final imageUrl = c["image_url"]?.toString() ?? "";
    final priceNum = double.tryParse(c["price"]?.toString() ?? "") ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 70,
              height: 70,
              color: _primaryBlue.withOpacity(0.05),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(
                          Icons.memory,
                          color: _primaryBlue,
                          size: 26,
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(Icons.memory, color: _primaryBlue, size: 26),
                    ),
            ),
          ),

          const SizedBox(width: 12),

          // TEXTS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // category chip
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // component name
                Text(
                  c["name"] ?? "Unnamed",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // PRICE
          Text(
            _formatCurrency(priceNum),
            style: TextStyle(
              color: _softGreen,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------
  // MAIN BUILD
  // ------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _softGreyBg,
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Saved Build Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
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

                    final c = comp as Map<String, dynamic>;
                    return _componentCard(category, c);
                  }),
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
                    backgroundColor: _softGreen,
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
                  onPressed: _showCheckoutForThisBuild,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBlue,
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
