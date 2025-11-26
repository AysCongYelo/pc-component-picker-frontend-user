import 'package:flutter/material.dart';

class BuildSummaryBox extends StatelessWidget {
  final int totalPrice;
  final int powerDraw;
  final String compatibility;

  const BuildSummaryBox({
    super.key,
    required this.totalPrice,
    required this.powerDraw,
    required this.compatibility,
  });

  @override
  Widget build(BuildContext context) {
    final isCompatible = compatibility == "ok" || compatibility == "compatible";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: const [
              Text(
                "Build Summary",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Icon(Icons.info_outline, color: Colors.grey),
            ],
          ),

          const SizedBox(height: 20),

          // Price Row
          _row(
            icon: Icons.payments,
            iconColor: const Color(0xFF10B981),
            title: "Total Price",
            value: "₱$totalPrice",
          ),

          const Divider(height: 32),

          // Power Usage
          _row(
            icon: Icons.power,
            iconColor: const Color(0xFFF59E0B),
            title: "Power Usage",
            value: "${powerDraw}W",
          ),

          const Divider(height: 32),

          // Compatibility
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Compatibility",
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              Row(
                children: [
                  Icon(
                    isCompatible ? Icons.check_circle : Icons.warning_amber,
                    color: isCompatible ? const Color(0xFF10B981) : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isCompatible ? "Compatible" : "Issues Found",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isCompatible
                          ? const Color(0xFF10B981)
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
