// lib/features/orders/screens/orders_list_screen.dart

import 'package:flutter/material.dart';
import 'package:pc_component_picker/core/services/api_client.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  static const routeName = "/my-orders";

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  final ApiClient _api = ApiClient.create();

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _orders = [];

  // Theme colors
  final Color primaryBlue = const Color(0xFF2563EB);
  final Color primaryBlueLight = const Color(0xFF3B82F6);
  final Color bgGrey = const Color(0xFFF8FAFC);
  final Color darkText = const Color(0xFF1E293B);

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final res = await _api.get("/orders");
      final orders = (res["orders"] as List).cast<Map<String, dynamic>>();

      setState(() {
        _orders = orders;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _formatCurrency(num value) {
    final text = value.toStringAsFixed(2);
    final parts = text.split(".");
    final intPart = parts[0];

    final reg = RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))");
    final formatted = intPart.replaceAllMapped(reg, (m) => "${m[1]},");

    return "₱$formatted.${parts[1]}";
  }

  // STATUS BADGE — new aesthetic version
  Widget _statusBadge(String status) {
    late Color color;

    switch (status) {
      case "paid":
        color = const Color(0xFF22C55E);
        break;
      case "shipped":
        color = const Color(0xFF2563EB);
        break;
      case "cancelled":
        color = const Color(0xFFEF4444);
        break;
      default:
        color = const Color(0xFFF59E0B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  // ORDER CARD — premium UI design
  Widget _orderCard(Map<String, dynamic> order) {
    final id = order["id"].toString();
    final totalRaw = order["total"];
    final status = (order["status"] ?? "pending").toString();
    final date = order["created_at"]?.toString() ?? "";

    final total = totalRaw is num
        ? totalRaw
        : num.tryParse(totalRaw.toString()) ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.pushNamed(
            context,
            "/order-detail",
            arguments: {"orderId": id},
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // ICON BOX
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: primaryBlue,
                  size: 23,
                ),
              ),
              const SizedBox(width: 14),

              // DETAILS
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order #${id.substring(0, 8)}",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        _statusBadge(status),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 13,
                              color: Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              date.substring(0, 10),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      _formatCurrency(total),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // HEADER ABOVE ORDER LIST
  Widget _sectionHeader() {
    return Row(
      children: [
        const Icon(Icons.history_rounded, color: Color(0xFF475569), size: 22),
        const SizedBox(width: 8),
        const Text(
          "My Orders",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        const Spacer(),
        if (_orders.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              "${_orders.length} total",
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("My Orders", style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryBlue, primaryBlueLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
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
          : _orders.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.inventory_2_rounded,
                    size: 70,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "You have no orders yet.",
                    style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadOrders,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(),
                    const SizedBox(height: 16),
                    ..._orders.map(_orderCard),
                  ],
                ),
              ),
            ),
    );
  }
}
