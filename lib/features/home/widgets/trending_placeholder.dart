import 'package:flutter/material.dart';

class TrendingPlaceholder extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const TrendingPlaceholder({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    // 🔥 If no trending items
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              "No trending components yet",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    // 🔥 If trending items exist
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, i) {
          final item = items[i];

          return GestureDetector(
            onTap: () {
              // TEMPORARY – No ProductDetail screen yet
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Clicked: ${item['name']}"),
                  duration: const Duration(milliseconds: 800),
                ),
              );
            },
            child: Container(
              width: 170,
              margin: const EdgeInsets.only(left: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.memory, size: 40, color: Colors.blue),
                  const SizedBox(height: 12),
                  Text(
                    item["name"],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "₱${item["price"]}",
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
