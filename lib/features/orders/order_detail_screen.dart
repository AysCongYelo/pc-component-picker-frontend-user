// lib/features/orders/screens/order_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:pc_component_picker/core/services/api_client.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key});

  static const routeName = '/order-detail';

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final ApiClient _api = ApiClient.create();

  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _order;
  List<Map<String, dynamic>> _items = [];

  // UI Colors
  final Color blue = const Color(0xFF2563EB);
  final Color blueLight = const Color(0xFF3B82F6);
  final Color green = const Color(0xFF22C55E);
  final Color darkText = const Color(0xFF1E293B);
  final Color bgGrey = const Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      final orderId = args?["orderId"]?.toString();
      if (orderId == null) {
        setState(() {
          _error = "Missing orderId";
          _loading = false;
        });
        return;
      }

      _loadOrder(orderId);
    });
  }

  // ₱ formatting
  String _format(num value) {
    final s = value.toStringAsFixed(2);
    final p = s.split(".");
    final intPart = p[0].replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return "₱$intPart.${p[1]}";
  }

  // Unified aesthetic status badge
  Widget _statusBadge(String status) {
    late Color color;

    switch (status) {
      case "paid":
        color = green;
        break;
      case "shipped":
        color = blue;
        break;
      case "cancelled":
        color = Colors.red;
        break;
      default:
        color = const Color(0xFFF59E0B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Future<void> _loadOrder(String id) async {
    try {
      setState(() {
        _loading = true;
      });

      final res = await _api.get("/orders/$id");
      final order = res["order"];

      final items = (order["items"] as List)
          .map((e) => (e as Map).cast<String, dynamic>())
          .toList();

      if (!mounted) return;
      setState(() {
        _order = order;
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // Item card UI
  Widget _itemCard(Map<String, dynamic> item) {
    final name = item["component_name"] ?? item["name"] ?? "Unknown";
    final qty = int.tryParse(item["quantity"].toString()) ?? 1;
    final price = num.tryParse(item["price_each"].toString()) ?? 0;
    final lineTotal = price * qty;
    final img = item["component_image"] ?? "";
    final category =
        (item["category"] ?? item["component_category"] ?? "").toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              img,
              width: 58,
              height: 58,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 58,
                height: 58,
                color: blue.withOpacity(0.08),
                child: Icon(Icons.memory, color: blue),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: darkText),
                ),
                const SizedBox(height: 4),
                Text(
                  "${category.toUpperCase()}   Qty: $qty",
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _format(price),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _format(lineTotal),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // MAIN BUILD
  @override
  Widget build(BuildContext context) {
    final order = _order;

    return Scaffold(
      backgroundColor: bgGrey,

      // ★ Gradient AppBar (same UI style)
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Order Details",
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [blue, blueLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text("Error: $_error"))
              : order == null
                  ? const Center(child: Text("Order not found"))
                  : _details(order),
    );
  }

  Widget _details(Map<String, dynamic> order) {
    final status = order["status"] ?? "";
    final created = order["created_at"] ?? "";
    final id = order["id"].toString();
    final total = num.tryParse(order["total"].toString()) ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========================
          // HEADER CARD
          // ========================
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Order #${id.substring(0, 8)}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: darkText,
                        ),
                      ),
                    ),
                    _statusBadge(status),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 16, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 6),
                    Text(
                      created.substring(0, 10),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Order Total",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      _format(total),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 26),

          // ========================
          // ITEMS
          // ========================
          Text(
            "Items (${_items.length})",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          ..._items.map(_itemCard),
        ],
      ),
    );
  }
}
