import 'package:flutter/material.dart';

class CheckoutScreen extends StatelessWidget {
  static const routeName = '/checkout';

  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TEMP PLACEHOLDER ITEMS
    final items = [
      {"name": "CPU – i5-12400F", "price": 8500},
      {"name": "GPU – RTX 3060", "price": 15000},
      {"name": "RAM – 16GB DDR4", "price": 2000},
    ];

    final int totalPrice = items.fold(
      0,
      (sum, item) => sum + (item["price"] as int),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TITLE
            const Text(
              "Confirm Order",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // ITEMS
            const Text(
              "Items:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  " • ${item["name"]} – ₱${item["price"]}",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // PAYMENT METHOD (STATIC FOR NOW)
            const Text(
              "Payment Method:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text("Cash on Delivery", style: TextStyle(fontSize: 16)),

            const SizedBox(height: 20),

            // NOTES INPUT
            const Text(
              "Notes (optional):",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 6),

            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Add instructions for delivery…",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const Spacer(),

            // TOTAL + ORDER BUTTON
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total: ₱$totalPrice",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Order Placed (placeholder)"),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Place Order",
                      style: TextStyle(fontSize: 17, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
