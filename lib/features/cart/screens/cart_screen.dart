import 'package:flutter/material.dart';
import 'package:frontend/core/services/api_client.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ApiClient _api = ApiClient.create();

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = [];

  // selected items for checkout
  Set<String> _selectedItems = {};

  // colors / styles para consistent
  Color get _primaryBlue => const Color(0xFF2563EB); // soft blue
  Color get _softGreen => const Color(0xFF22C55E); // tailwind-ish green
  Color get _softGreyBg => const Color(0xFFF3F4F6); // screen background
  Color get _textDark => const Color(0xFF111827); // almost black

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  // ---------------- PRICE FORMATTER (for readability) ----------------
  String _formatCurrency(num value) {
    final s = value.toStringAsFixed(2);
    final parts = s.split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formattedInt = intPart.replaceAllMapped(reg, (m) => '${m[1]},');

    return '₱$formattedInt.$decPart';
  }

  String _formatCurrencyFromRaw(dynamic raw) {
    final v = double.tryParse(raw?.toString() ?? '') ?? 0;
    return _formatCurrency(v);
  }

  // ---------------- LOAD CART ----------------
  Future<void> _loadCart() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await _api.get("/cart");
      final items = (res["items"] as List).cast<Map<String, dynamic>>();

      setState(() {
        _items = items;

        // Keep only selections that still exist in cart
        _selectedItems = _selectedItems.where((id) {
          return _items.any((item) => item["id"].toString() == id);
        }).toSet();

        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
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

  // ---------------- CHECKOUT BOTTOM SHEET ----------------
  void _showCheckoutDialog() {
    final parentContext = context;

    final selected = _items
        .where((item) => _selectedItems.contains(item["id"].toString()))
        .toList();

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
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
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: selected.length,
                      itemBuilder: (context, i) {
                        final item = selected[i];
                        final name = _itemDisplayName(item);
                        final priceText =
                            _formatCurrencyFromRaw(_itemDisplayPrice(item));

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _textDark,
                            ),
                          ),
                          subtitle: Text(
                            item["category"] == "build_bundle"
                                ? "${item["bundle_item_count"]} items in bundle"
                                : "Qty: ${item["quantity"] ?? 1}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          trailing: Text(
                            priceText,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _softGreen,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
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
                        _summaryRow(
                          "Subtotal",
                          _formatCurrency(selectedTotal),
                        ),
                        _summaryRow(
                          "Shipping Fee",
                          _formatCurrency(150),
                        ),
                        _summaryRow(
                          "Tax",
                          _formatCurrency(0),
                        ),
                        const Divider(height: 20),
                        _summaryRow(
                          "Total",
                          _formatCurrency(selectedTotal + 150),
                          bold: true,
                          big: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
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
                      onPressed: () async {
                        Navigator.pop(modalContext);

                        try {
                          final res = await _api.post("/checkout", {
                            "item_ids": _selectedItems.toList(),
                            "payment_method": "cod",
                            "notes": null,
                          });

                          await Future.delayed(
                            const Duration(milliseconds: 50),
                          );

                          if (!parentContext.mounted) return;

                          Navigator.pushReplacementNamed(
                            parentContext,
                            "/order-success",
                            arguments: {"orderId": res["order"]["id"]},
                          );
                        } catch (e) {
                          if (!parentContext.mounted) return;

                          ScaffoldMessenger.of(parentContext).showSnackBar(
                            SnackBar(
                              content: Text("Checkout failed: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "Confirm Order",
                        style: TextStyle(
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
  }

  // ---------------- NAME HANDLER ----------------
  String _itemDisplayName(Map<String, dynamic> item) {
    if (item["component_name"] != null) return item["component_name"];
    if (item["build_name"] != null) return "Saved Build: ${item["build_name"]}";
    if (item["category"] == "temp_build") return "Temporary Build";
    return "Unknown Item";
  }

  // ---------------- PRICE HANDLER (raw string) ----------------
  String _itemDisplayPrice(Map<String, dynamic> item) {
    if (item["component_price"] != null) {
      return item["component_price"].toString();
    }
    if (item["build_total_price"] != null) {
      return item["build_total_price"].toString();
    }
    if (item["price"] != null) return item["price"].toString();
    return "0";
  }

  // ---------------- TOTAL PRICE ----------------
  double get totalPrice {
    return _items.fold(0, (sum, item) {
      if (item["component_price"] != null) {
        return sum + (double.tryParse(item["component_price"].toString()) ?? 0);
      }
      if (item["build_total_price"] != null) {
        return sum +
            (double.tryParse(item["build_total_price"].toString()) ?? 0);
      }
      if (item["price"] != null) {
        return sum + (double.tryParse(item["price"].toString()) ?? 0);
      }
      return sum;
    });
  }

  // ---------------- SELECTED TOTAL ----------------
  double get selectedTotal {
    return _items
        .where((item) => _selectedItems.contains(item["id"].toString()))
        .fold(0, (sum, item) {
      final qty = item["quantity"] ?? 1;

      if (item["component_price"] != null) {
        final price = double.tryParse(item["component_price"].toString()) ?? 0;
        return sum + (price * qty);
      }

      if (item["build_total_price"] != null) {
        final price =
            double.tryParse(item["build_total_price"].toString()) ?? 0;
        return sum + (price * qty);
      }

      final price = double.tryParse(item["price"].toString()) ?? 0;
      return sum + (price * qty);
    });
  }

  // ---------------- CATEGORY ICON ----------------
  IconData _getCategoryIcon(String? category) {
    if (category == null) return Icons.computer;

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
      case "build_bundle":
        return Icons.build_circle;
      case "temp_build":
        return Icons.engineering;
      default:
        return Icons.computer;
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _softGreyBg,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          "My Cart",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    "Error: $_error",
                    style: TextStyle(color: Colors.red[700]),
                  ),
                )
              : _items.isEmpty
                  ? _buildEmptyState()
                  : Stack(
                      children: [
                        // Scrollable cart + pull-to-refresh
                        RefreshIndicator(
                          onRefresh: _loadCart,
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(
                              16,
                              16,
                              16,
                              160, // extra bottom padding para di matakpan
                            ),
                            children: [
                              // SELECT ALL
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Select All",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _textDark,
                                    ),
                                  ),
                                  Checkbox(
                                    value: _selectedItems.length ==
                                            _items.length &&
                                        _items.isNotEmpty,
                                    onChanged: (checked) {
                                      setState(() {
                                        if (checked == true) {
                                          _selectedItems = _items
                                              .map((e) => e["id"].toString())
                                              .toSet();
                                        } else {
                                          _selectedItems.clear();
                                        }
                                      });
                                    },
                                    activeColor: _primaryBlue,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ..._items.map(_cartItemTile).toList(),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),

                        // Fixed total card + checkout sa baba (only if may selected)
                        if (_selectedItems.isNotEmpty)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: SafeArea(
                              top: false,
                              child: Container(
                                color: Colors.white,
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  8,
                                  16,
                                  16,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildTotalCard(selectedTotal),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.payment),
                                        label: Text(
                                          "Checkout (${_selectedItems.length})",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _softGreen,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        onPressed: _showCheckoutDialog,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
    );
  }

  // ---------------- CART ITEM TILE (NEW LAYOUT) ----------------
  Widget _cartItemTile(Map<String, dynamic> item) {
    final name = _itemDisplayName(item);
    final rawPrice = _itemDisplayPrice(item);
    final priceText = _formatCurrencyFromRaw(rawPrice);
    final category = item["category"];
    final quantity = item["quantity"] ?? 1;
    final componentId = item["component_id"];
    final idString = item["id"].toString();
    final imageUrl = item["image_url"] as String?; // from backend (if any)

    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ROW 1: IMAGE + DETAILS + CHECKBOX
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 70,
                  height: 70,
                  color: _primaryBlue.withOpacity(0.05),
                  child: (imageUrl != null && imageUrl.isNotEmpty)
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, st) => Center(
                            child: Icon(
                              _getCategoryIcon(category),
                              color: _primaryBlue,
                              size: 28,
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(
                            _getCategoryIcon(category),
                            color: _primaryBlue,
                            size: 28,
                          ),
                        ),
                ),
              ),

              const SizedBox(width: 12),

              // TEXTS
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // title
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // category chip
                    if (category != null) ...[
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
                          category.toString().toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],

                    // price
                    Text(
                      priceText,
                      style: TextStyle(
                        color: _softGreen,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              // CHECKBOX
              Checkbox(
                value: _selectedItems.contains(idString),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedItems.add(idString);
                    } else {
                      _selectedItems.remove(idString);
                    }
                  });
                },
                activeColor: _primaryBlue,
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ROW 2: QTY CONTROLS + DELETE
          Row(
            children: [
              if (category != "build_bundle" && category != "temp_build") ...[
                Text(
                  "Qty",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 8),

                // minus
                InkWell(
                  onTap: () async {
                    final currentQty = quantity;
                    if (currentQty > 1) {
                      await _api.delete("/cart/${item['id']}");
                      setState(() {
                        item["quantity"] = currentQty - 1;
                      });
                    } else {
                      await _api.delete("/cart/deleteRow/${item["id"]}");
                      setState(() {
                        _items.remove(item);
                        _selectedItems.remove(idString);
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                    ),
                    child: const Icon(
                      Icons.remove,
                      size: 16,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Text(
                  "$quantity",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(width: 10),

                // plus
                InkWell(
                  onTap: () async {
                    await _api.post("/cart/add", {"componentId": componentId});
                    setState(() {
                      item["quantity"] = quantity + 1;
                    });
                  },
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 16,
                    ),
                  ),
                ),
              ] else ...[
                Text(
                  "Bundle / Build item",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],

              const Spacer(),

              // DELETE BUTTON
              TextButton.icon(
                onPressed: () async {
                  try {
                    await _api.delete("/cart/deleteRow/${item["id"]}");
                    _loadCart();

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Item removed completely"),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Error removing item: $e"),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Colors.redAccent,
                ),
                label: const Text(
                  "Remove",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.redAccent,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- TOTAL CARD ----------------
  Widget _buildTotalCard(double amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB), // very light grey
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatCurrency(amount),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _primaryBlue.withOpacity(0.06),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: _primaryBlue,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Text(
                  "Selected total",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- EMPTY STATE ----------------
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 70,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              "Your cart is empty",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Add items to your cart to proceed with checkout.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
