import 'package:flutter/material.dart';

class SavedItemTile extends StatelessWidget {
  final String name;
  final int price;
  final String specs;
  final String status;
  final VoidCallback onOpen;
  final VoidCallback onDelete;
  final VoidCallback onCheckout;

  const SavedItemTile({
    super.key,
    required this.name,
    required this.price,
    required this.specs,
    required this.status,
    required this.onOpen,
    required this.onDelete,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NAME + PRICE
          Text(
            name,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "₱$price",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          // SPECS
          Text(specs, style: TextStyle(color: Colors.grey[700])),

          const SizedBox(height: 6),

          // STATUS
          Text(
            "Status: $status",
            style: TextStyle(
              color: status.contains("⚠") ? Colors.orange : Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 14),

          // ACTION BUTTONSF
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: onOpen, child: const Text("Open")),
              TextButton(
                onPressed: onDelete,
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
              ElevatedButton(
                onPressed: onCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Checkout",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
