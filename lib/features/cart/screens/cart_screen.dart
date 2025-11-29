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

  // Selected items
  Set<String> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  // ---------------- LOAD CART ----------------
  Future<void> _loadCart() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await _api.get("/cart");
      print("CART RESPONSE => ${res["items"]}");
      final items = (res["items"] as List).cast<Map<String, dynamic>>();

      setState(() {
        _items = items;

        // Keep only selections still valid
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

  // ---------------- ITEM NAME ----------------
  String _itemDisplayName(Map<String, dynamic> item) {
    if (item["component_name"] != null) return item["component_name"];
    if (item["build_name"] != null) return "Saved Build: ${item["build_name"]}";
    if (item["category"] == "temp_build") return "Temporary Build";
    return "Unknown Item";
  }

  // ---------------- PRICE ----------------
  String _itemDisplayPrice(Map<String, dynamic> item) {
    if (item["component_price"] != null)
      return item["component_price"].toString();

    if (item["build_total_price"] != null)
      return item["build_total_price"].toString();

    if (item["price"] != null) return item["price"].toString();

    return "0";
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

  // ---------------- TOTAL PRICE (SELECTED ONLY) ----------------
  double get selectedTotal {
    return _items
        .where((item) => _selectedItems.contains(item["id"].toString()))
        .fold(0.0, (sum, item) {
          final qty = item["quantity"] ?? 1;

          if (item["component_price"] != null) {
            final price =
                double.tryParse(item["component_price"].toString()) ?? 0.0;
            return sum + (price * qty);
          }

          if (item["build_total_price"] != null) {
            final price =
                double.tryParse(item["build_total_price"].toString()) ?? 0.0;
            return sum + (price * qty);
          }

          final price = double.tryParse(item["price"].toString()) ?? 0.0;
          return sum + (price * qty);
        });
  }

  // ---------------- CART ITEM UI ----------------
  Widget _cartItemTile(Map<String, dynamic> item) {
    final name = _itemDisplayName(item);
    final price = _itemDisplayPrice(item);
    final category = item["category"];
    final componentId = item["component_id"];
    final idString = item["id"].toString();
    final quantity = item["quantity"] ?? 1;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: _selectedItems.contains(idString),
            onChanged: (checked) {
              setState(() {
                if (checked == true) {
                  _selectedItems.add(idString);
                } else {
                  _selectedItems.remove(idString);
                }
              });
            },
          ),

          // ICON
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 60,
              height: 60,
              color: Colors.grey[200],
              child: Image.network(
                item["image_url"] ?? "",
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, st) => const Icon(
                  Icons.broken_image,
                  size: 30,
                  color: Colors.grey,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // NAME + PRICE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "₱$price",
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // QUANTITY CONTROL
          if (category != "build_bundle" && category != "temp_build")
            Row(
              children: [
                InkWell(
                  onTap: () async {
                    if (quantity > 1) {
                      await _api.delete("/cart/${item['id']}");
                      setState(() => item["quantity"] = quantity - 1);
                    } else {
                      await _api.delete("/cart/deleteRow/${item['id']}");
                      setState(() {
                        _items.remove(item);
                        _selectedItems.remove(idString);
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                    ),
                    child: const Icon(Icons.remove, size: 16),
                  ),
                ),

                const SizedBox(width: 6),

                Text(
                  "$quantity",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(width: 6),

                InkWell(
                  onTap: () async {
                    await _api.post("/cart/add", {"componentId": componentId});
                    setState(() => item["quantity"] = quantity + 1);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                    ),
                    child: const Icon(Icons.add, size: 16),
                  ),
                ),
              ],
            ),

          // DELETE FULL ROW
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () async {
              await _api.delete("/cart/deleteRow/${item['id']}");
              _loadCart();
            },
          ),
        ],
      ),
    );
  }

  // ---------------- TOTAL PRICE CARD ----------------
  Widget _buildTotalCard(double amount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Total Price",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Text(
            "₱${amount.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
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
            const Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            const Text(
              "Your cart is empty",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Add items to your cart to checkout.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- CHECKOUT (bottom sheet) ----------------
  void _showCheckoutDialog() {
    final parent = context;

    final selected = _items.where(
      (item) => _selectedItems.contains(item["id"].toString()),
    );

    showModalBottomSheet(
      context: parent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const Text(
                    "Order Summary",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: selected.map((item) {
                        final name = _itemDisplayName(item);
                        final price = _itemDisplayPrice(item);

                        return ListTile(
                          title: Text(name),
                          subtitle: Text(
                            item["category"] == "build_bundle"
                                ? "${item["bundle_item_count"]} items"
                                : "Qty: ${item["quantity"] ?? 1}",
                          ),
                          trailing: Text(
                            "₱$price",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        _summaryRow(
                          "Subtotal",
                          "₱${selectedTotal.toStringAsFixed(2)}",
                        ),
                        _summaryRow("Shipping Fee", "₱150.00"),
                        const Divider(),
                        _summaryRow(
                          "Total",
                          "₱${(selectedTotal + 150).toStringAsFixed(2)}",
                          bold: true,
                          big: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Confirm Order
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
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
                          });

                          Navigator.pushReplacementNamed(
                            parent,
                            "/order-success",
                            arguments: {"orderId": res["order"]["id"]},
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(parent).showSnackBar(
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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

  // ---------------- MAIN UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart"),
        centerTitle: true,
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: Stack(
        children: [
          // Scrollable content
          Positioned.fill(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text("Error: $_error"))
                : _items.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadCart,
                    child: ListView(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                        bottom: _selectedItems.isNotEmpty ? 160 : 20,
                      ),
                      children: [
                        // SELECT ALL
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Select All",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Checkbox(
                              value:
                                  _selectedItems.length == _items.length &&
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
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        ..._items.map(_cartItemTile).toList(),
                      ],
                    ),
                  ),
          ),

          // FIXED BOTTOM TOTAL + CHECKOUT
          if (_selectedItems.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTotalCard(selectedTotal),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.payment),
                        label: Text(
                          "Checkout (${_selectedItems.length})",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _showCheckoutDialog,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // SUMMARY ROW
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
              fontSize: big ? 18 : 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: big ? 20 : 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: bold ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
