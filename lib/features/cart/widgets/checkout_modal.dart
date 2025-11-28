import 'package:flutter/material.dart';

typedef Item = Map<String, dynamic>;

Future<void> showCheckoutModal(
  BuildContext parentContext,
  List<Item> selectedItems,
  Future<Map<String, dynamic>> Function() onConfirm,
) {
  double modalSubtotal() {
    return selectedItems.fold(0, (sum, item) {
      final price = double.tryParse(item["price"].toString()) ?? 0;

      if (item["bundle_item_count"] != null) return sum + price;

      final qty = item["quantity"] ?? 1;
      return sum + (price * qty);
    });
  }

  String formatPrice(v) {
    final d = (double.tryParse(v.toString()) ?? 0);
    return d.toStringAsFixed(2);
  }

  return showModalBottomSheet(
    context: parentContext,
    isScrollControlled: true,
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
                    itemCount: selectedItems.length,
                    itemBuilder: (context, i) {
                      final item = selectedItems[i];

                      return ListTile(
                        title: Text(item["name"]),
                        subtitle: item["bundle_item_count"] != null
                            ? Text(
                                "${item["bundle_item_count"]} items in bundle",
                              )
                            : Text("Qty: ${item["quantity"] ?? 1}"),
                        trailing: Text(
                          "₱${formatPrice(item["price"])}",
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
                      _row("Subtotal", "₱${formatPrice(modalSubtotal())}"),
                      _row("Shipping Fee", "₱150.00"),
                      _row("Tax", "₱0.00"),
                      const Divider(),
                      _row(
                        "Total",
                        "₱${formatPrice(modalSubtotal() + 150)}",
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
                      Navigator.pop(modalContext);

                      Map<String, dynamic> result;
                      try {
                        result = await onConfirm();
                      } catch (e) {
                        if (parentContext.mounted) {
                          ScaffoldMessenger.of(parentContext).showSnackBar(
                            SnackBar(
                              content: Text("Checkout failed: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                        return;
                      }

                      await Future.delayed(const Duration(milliseconds: 50));

                      if (parentContext.mounted) {
                        Navigator.pushReplacementNamed(
                          parentContext,
                          "/order-success",
                          arguments: {"orderId": result["order"]["id"]},
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

Widget _row(String left, String right, {bool bold = false, bool big = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          left,
          style: TextStyle(
            fontSize: big ? 18 : 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          right,
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
