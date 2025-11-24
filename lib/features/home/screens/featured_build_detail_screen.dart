import 'package:flutter/material.dart';

class FeaturedBuildDetailScreen extends StatelessWidget {
  static const routeName = "/featured-build-detail";

  final Map<String, dynamic> featuredBuild;

  const FeaturedBuildDetailScreen({super.key, required this.featuredBuild});

  @override
  Widget build(BuildContext context) {
    final List items = featuredBuild['items'] ?? [];

    // COMPUTE TOTAL WATTAGE IF AVAILABLE
    int totalWattage = 0;
    for (final item in items) {
      final comp = item["component"];
      if (comp != null && comp["wattage"] != null) {
        totalWattage += (comp["wattage"] as num?)?.toInt() ?? 0;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text("Featured Build"),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TITLE --------------------------------------------------
            Text(
              featuredBuild["title"] ?? "",
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // DESCRIPTION -------------------------------------------
            Text(
              featuredBuild["description"] ?? "",
              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
            ),

            const SizedBox(height: 20),

            // INCLUDED COMPONENTS -----------------------------------
            const Text(
              "Included Components",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 12),

            Column(
              children: items.map((item) {
                final comp = item["component"];
                if (comp == null) return const SizedBox();

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          comp["image_url"],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comp["name"],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              comp["brand"],
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),

                      Text(
                        "₱${comp["price"]}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 25),

            // SUMMARY SECTION ---------------------------------------
            const Text(
              "Summary",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _summaryRow(
                    "Total Price",
                    "₱${featuredBuild["total_price"]}",
                  ),
                  const SizedBox(height: 8),
                  _summaryRow("Total Wattage", "$totalWattage W"),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Checkout This Build",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
}
