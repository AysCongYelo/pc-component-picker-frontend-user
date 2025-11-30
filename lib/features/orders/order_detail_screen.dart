// lib/features/orders/screens/order_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:frontend/core/services/api_client.dart';

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
  bool _initialized = false;

  Color get _primaryBlue => const Color(0xFF2563EB);
  Color get _textDark => const Color(0xFF111827);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      final orderId = args?["orderId"]?.toString();
      if (orderId == null || orderId.isEmpty) {
        setState(() {
          _error = "Missing orderId";
          _loading = false;
        });
      } else {
        _loadOrder(orderId);
      }
    }
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

  Widget _statusBadge(String status) {
    Color color;

    switch (status) {
      case "paid":
        color = Colors.green;
        break;
      case "shipped":
        color = Colors.blue;
        break;
      case "cancelled":
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Future<void> _loadOrder(String orderId) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await _api.get("/orders/$orderId");

      final order = (res["order"] ?? res) as Map<String, dynamic>;
      final itemsRaw = (order["items"] ?? []) as List;

      final items = itemsRaw
          .map((e) => (e as Map).cast<String, dynamic>())
          .toList(growable: false);

      setState(() {
        _order = order;
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

  // ---------- ITEM TILE (per component) ----------
  Widget _itemTile(Map<String, dynamic> item) {
    // name galing sa join: component_name
    final name = (item["component_name"] ??
            item["name"] ??
            "Unknown item")
        .toString();

    final qtyRaw = item["quantity"] ?? 1;
    final qty = qtyRaw is num ? qtyRaw : num.tryParse(qtyRaw.toString()) ?? 1;

    // price_each column sa order_items
    final priceRaw = item["price_each"] ?? item["price"] ?? 0;
    final num priceNum =
        priceRaw is num ? priceRaw : num.tryParse(priceRaw.toString()) ?? 0;

    final lineTotal = priceNum * qty;

    final category =
        (item["category"] ?? item["component_category"] ?? "")
            .toString()
            .toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
          // icon / thumbnail
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE0EDFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 12),
          // name + qty
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (category.isNotEmpty)
                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    if (category.isNotEmpty) const SizedBox(width: 6),
                    Text(
                      "Qty: $qty",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(priceNum),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatCurrency(lineTotal),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2563EB),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    final totalRaw = order?["total"] ?? 0;
    final num totalNum =
        totalRaw is num ? totalRaw : num.tryParse(totalRaw.toString()) ?? 0;

    final status = (order?["status"] ?? "pending").toString();
    final createdAt = order?["created_at"]?.toString() ?? '';
    final orderId = order?["id"]?.toString() ?? '';

    final itemCount = _items.length;
    final itemLabel = "$itemCount item${itemCount == 1 ? '' : 's'}";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        title: const Text(
          "Order Details",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    "Error: $_error",
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : order == null
                  ? const Center(
                      child: Text(
                        "Order not found.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    )
                  : SafeArea(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // HEADER CARD
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
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
                                          "Order #${orderId.length > 8 ? orderId.substring(0, 8) : orderId}",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: _textDark,
                                          ),
                                        ),
                                      ),
                                      _statusBadge(status),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_today_rounded,
                                            size: 16,
                                            color: Color(0xFF94A3B8),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            createdAt.isNotEmpty &&
                                                    createdAt.length >= 10
                                                ? createdAt.substring(0, 10)
                                                : createdAt,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // payment method badge (simple text)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              const Color(0xFFE0EDFF),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Row(
                                          children: const [
                                            Icon(
                                              Icons.account_balance_wallet,
                                              size: 14,
                                              color: Color(0xFF2563EB),
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              "COD",
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF2563EB),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Order Total",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                      Text(
                                        _formatCurrency(totalNum),
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: _primaryBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ITEMS SECTION
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Items",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                Text(
                                  itemLabel,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            if (_items.isEmpty)
                              const Text(
                                "No items found in this order.",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF64748B),
                                ),
                              )
                            else
                              ..._items.map(_itemTile).toList(),
                          ],
                        ),
                      ),
                    ),
    );
  }
}
