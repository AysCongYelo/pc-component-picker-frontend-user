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

  // ⭐ NEW — selected items for checkout
  Set<String> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

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

        // ✔ Keep only selections that still exist in cart
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

  void _showCheckoutDialog() {
    final parentContext = context;

    final selected = _items
        .where((item) => _selectedItems.contains(item["id"].toString()))
        .toList();

    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        // ⭐ IMPORTANT
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const Text(
                    "Order Summary",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 16),

                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: selected.length,
                      itemBuilder: (context, i) {
                        final item = selected[i];
                        final name = _itemDisplayName(item);
                        final price = _itemDisplayPrice(item);

                        return ListTile(
                          title: Text(name),
                          subtitle: item["category"] == "build_bundle"
                              ? Text(
                                  "${item["bundle_item_count"]} items in bundle",
                                )
                              : Text("Qty: ${item["quantity"] ?? 1}"),
                          trailing: Text(
                            "₱$price",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
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
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _summaryRow(
                          "Subtotal",
                          "₱${selectedTotal.toStringAsFixed(2)}",
                        ),
                        _summaryRow("Shipping Fee", "₱150.00"),
                        _summaryRow("Tax", "₱0.00"),
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

                  const SizedBox(height: 16),

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
                        Navigator.pop(
                          modalContext,
                        ); // ⭐ ALWAYS USE modalContext

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

  Future<void> _removeItem(String itemId) async {
    try {
      await _api.delete("/cart/$itemId");
      _loadCart();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Item removed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error removing item: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ---------------- NAME HANDLER ----------------
  String _itemDisplayName(Map<String, dynamic> item) {
    if (item["component_name"] != null) return item["component_name"];
    if (item["build_name"] != null) return "Saved Build: ${item["build_name"]}";
    if (item["category"] == "temp_build") return "Temporary Build";
    return "Unknown Item";
  }

  // ---------------- PRICE HANDLER ----------------
  String _itemDisplayPrice(Map<String, dynamic> item) {
    if (item["component_price"] != null)
      return item["component_price"].toString();
    if (item["build_total_price"] != null)
      return item["build_total_price"].toString();
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
            final price =
                double.tryParse(item["component_price"].toString()) ?? 0;
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
      appBar: AppBar(
        title: const Text("My Cart"),
        centerTitle: true,
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text("Error: $_error"))
          : _items.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadCart,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ---------------- SELECT ALL ----------------
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
                  const SizedBox(height: 20),

                  if (_selectedItems.isNotEmpty) ...[
                    _buildTotalCard(selectedTotal),

                    const SizedBox(height: 20),

                    ElevatedButton.icon(
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
                  ],
                ],
              ),
            ),
    );
  }

  // ---------------- CART ITEM TILE ----------------
  Widget _cartItemTile(Map<String, dynamic> item) {
    final name = _itemDisplayName(item);
    final price = _itemDisplayPrice(item);
    final category = item["category"];
    final quantity = item["quantity"] ?? 1;
    final componentId = item["component_id"];

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
          // ---------------- CHECKBOX ----------------
          Checkbox(
            value: _selectedItems.contains(item["id"].toString()),
            onChanged: (value) {
              setState(() {
                final id = item["id"].toString();
                if (value == true) {
                  _selectedItems.add(id);
                } else {
                  _selectedItems.remove(id);
                }
              });
            },
          ),

          // ---------------- ICON ----------------
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getCategoryIcon(category),
              color: Colors.blue,
              size: 28,
            ),
          ),

          const SizedBox(width: 16),

          // ---------------- DETAILS ----------------
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

          // ---------------- QUANTITY ----------------
          if (category != "build_bundle" && category != "temp_build") ...[
            Row(
              children: [
                // ---------- MINUS ----------
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () async {
                    final currentQty = item["quantity"] ?? 1;

                    if (currentQty > 1) {
                      // MINUS ONE (backend: DELETE /cart/:itemId)
                      await _api.delete("/cart/${item['id']}");

                      setState(() {
                        item["quantity"] =
                            currentQty - 1; // 👈 smooth UI update
                      });
                    } else {
                      // Quantity becomes 0 → delete entire row
                      await _api.delete("/cart/deleteRow/${item["id"]}");

                      setState(() {
                        _items.remove(item);
                        _selectedItems.remove(item["id"].toString());
                      });
                    }
                  },
                ),

                // ---------- QTY NUMBER ----------
                Text(
                  "${item["quantity"] ?? 1}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // ---------- PLUS ----------
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () async {
                    await _api.post("/cart/add", {"componentId": componentId});

                    setState(() {
                      item["quantity"] = (item["quantity"] ?? 1) + 1;
                    });
                  },
                ),
              ],
            ),
          ],

          // ---------------- DELETE FULL ROW ----------------
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () async {
              try {
                await _api.delete("/cart/deleteRow/${item["id"]}");
                _loadCart();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Item removed completely"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error removing item: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  // ---------------- TOTAL CARD ----------------
  // now accepts amount to display (selected total)
  Widget _buildTotalCard(double amount) {
    return Container(
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
      child: Column(
        children: [
          const Text(
            "Total Price",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
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
              "Add items to your cart to proceed with checkout.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
