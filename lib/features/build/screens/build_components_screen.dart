import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pc_component_picker/core/services/api_client_provider.dart';
import 'package:pc_component_picker/features/build/services/build_service.dart';
import 'package:pc_component_picker/features/build/providers/build_provider.dart';

class BuildComponentsScreen extends ConsumerWidget {
  final String category;
  final bool isEditing;

  const BuildComponentsScreen({
    super.key,
    required this.category,
    this.isEditing = false,
  });

  Color get mainBlue => const Color(0xFF2563EB);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = BuildService(ref.read(apiClientProvider));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Select ${category.toUpperCase()}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: FutureBuilder<List<dynamic>>(
        future: service.fetchComponents(category),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(child: Text("Error: ${snap.error}"));
          }

          final components = snap.data ?? [];

          if (components.isEmpty) {
            return const Center(
              child: Text(
                "No components found",
                style: TextStyle(fontSize: 16, color: Color(0xFF475569)),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: components.length,
            itemBuilder: (context, i) {
              final comp = components[i];

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
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    await ref
                        .read(buildProvider.notifier)
                        .addComponent(category, comp["id"]);

                    if (isEditing) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${comp["name"]} added!")),
                    );
                  },
                  child: Row(
                    children: [
                      // IMAGE
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 70,
                          height: 70,
                          color: mainBlue.withOpacity(0.08),
                          child: comp["image_url"] != null
                              ? Image.network(
                                  comp["image_url"],
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                                )
                              : const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      // TEXT DETAILS
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comp["name"] ?? "Unknown",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "₱${comp["price"]}",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF22C55E),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Icon(
                        Icons.add_circle_outline,
                        color: Color(0xFF2563EB),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
