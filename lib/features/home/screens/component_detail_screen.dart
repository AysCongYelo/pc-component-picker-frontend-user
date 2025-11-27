import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_client_provider.dart';

// 🔧 Category UUID → slug mapping
const categorySlugMap = {
  "2bbab1a8-0a20-49da-b0fb-e932a68ca35f": "cpu",
  "aa06cff7-dcf2-4e74-ba06-e36073fe6037": "gpu",
  "760d0169-1b6d-4769-8e16-ee98739411c3": "motherboard",
  "e70730b3-e286-425a-8255-c9039ab7b337": "memory",
  "d37a208d-1cf7-4aa3-affd-059abf0c9b86": "storage",
  "0b75a480-8751-4c03-9089-1a180d54caa5": "psu",
  "b12acc94-c57c-493a-a5c5-ebd565935cdc": "case",
  "e4e7380f-aa46-46e7-8bee-2072ffc91401": "cpu_cooler",
};

class ComponentDetailScreen extends ConsumerWidget {
  final Map<String, dynamic> component;

  const ComponentDetailScreen({super.key, required this.component});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = component["image_url"] ?? "";
    final price = component["price"]?.toString() ?? "0";
    final brand = component["brand"] ?? "Unknown";
    final name = component["name"] ?? "No Name";
    final specs = component["specs"] ?? {};

    final categorySlug = categorySlugMap[component["category_id"]];

    return Scaffold(
      appBar: AppBar(title: Text(name, overflow: TextOverflow.ellipsis)),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 220,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported, size: 60),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              brand,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 12),

            Text(
              "₱$price",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Specifications",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),

            if (specs.isNotEmpty)
              ...specs.entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${e.key}: ",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          e.value.toString(),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              const Text(
                "No specs available",
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),

      // ⭐ BOTTOM BUTTONS
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // ---------------------------
            // ADD TO BUILD
            // ---------------------------
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(0, 50),
                ),
                onPressed: () async {
                  try {
                    if (categorySlug == null) {
                      throw "Category not mapped.";
                    }

                    final api = ref.read(apiClientProvider);

                    await api.post("/builder/temp/add", {
                      "category": categorySlug,
                      "componentId": component["id"],
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Added to Build!")),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Failed: $e")));
                  }
                },
                child: const Text("Add to Build"),
              ),
            ),

            const SizedBox(width: 12),

            // ---------------------------
            // ADD TO CART
            // ---------------------------
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(0, 50),
                ),
                onPressed: () async {
                  try {
                    final api = ref.read(apiClientProvider);

                    await api.post("/cart/add", {
                      "componentId": component["id"], // FIXED
                      "quantity": 1,
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Added to Cart!")),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Failed: $e")));
                  }
                },
                child: const Text("Add to Cart"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
