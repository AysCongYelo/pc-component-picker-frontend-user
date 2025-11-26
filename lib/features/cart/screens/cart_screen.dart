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
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
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

  // -----------------------------------------------------------
  // NAME HANDLER (component, saved build, temp build)
  // -----------------------------------------------------------
  String _itemDisplayName(Map<String, dynamic> item) {
    if (item["component_name"] != null) {
      return item["component_name"];
    }

    if (item["build_name"] != null) {
      return "Saved Build: ${item["build_name"]}";
    }

    if (item["category"] == "temp_build") {
      return "Temporary Build";
    }

    return "Unknown Item";
  }

  // -----------------------------------------------------------
  // PRICE HANDLER
  // -----------------------------------------------------------
  String _itemDisplayPrice(Map<String, dynamic> item) {
    if (item["component_price"] != null) {
      return item["component_price"].toString();
    }

    if (item["build_total_price"] != null) {
      return item["build_total_price"].toString();
    }

    if (item["price"] != null) {
      return item["price"].toString();
    }

    return "0";
  }

  // -----------------------------------------------------------
  // TOTAL PRICE (SUM OF ANY TYPE)
  // -----------------------------------------------------------
  double get totalPrice {
    return _items.fold(0, (sum, item) {
      // component item
      if (item["component_price"] != null) {
        return sum + (double.tryParse(item["component_price"].toString()) ?? 0);
      }

      // saved build item
      if (item["build_total_price"] != null) {
        return sum +
            (double.tryParse(item["build_total_price"].toString()) ?? 0);
      }

      // temp build item
      if (item["price"] != null) {
        return sum + (double.tryParse(item["price"].toString()) ?? 0);
      }

      return sum;
    });
  }

  // -----------------------------------------------------------
  // CATEGORY ICON HANDLER
  // -----------------------------------------------------------
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

      // New
      case "build_bundle":
        return Icons.build_circle;

      // New
      case "temp_build":
        return Icons.engineering;

      default:
        return Icons.computer;
    }
  }

  // -----------------------------------------------------------
  // UI
  // -----------------------------------------------------------
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
                  ..._items.map(_cartItemTile),
                  const SizedBox(height: 20),
                  _buildTotalCard(),
                ],
              ),
            ),
    );
  }

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
          // Category Icon
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

          // Info
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

          // Quantity Controls
          if (category != "build_bundle" && category != "temp_build") ...[
            Row(
              children: [
                // MINUS BUTTON
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => _removeItem(item["id"]),
                ),

                Text(
                  "$quantity",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                // PLUS BUTTON
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () async {
                    await _api.post("/cart/add", {"componentId": componentId});
                    _loadCart();
                  },
                ),
              ],
            ),
          ],

          // Delete button (for entire row)
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

  Widget _buildTotalCard() {
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
            "₱${totalPrice.toStringAsFixed(2)}",
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
