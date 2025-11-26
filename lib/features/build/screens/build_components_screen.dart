import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:frontend/core/services/api_client_provider.dart';
import 'package:frontend/features/build/services/build_service.dart';
import 'package:frontend/features/build/providers/build_provider.dart';

class BuildComponentsScreen extends ConsumerWidget {
  final String category;

  const BuildComponentsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = BuildService(ref.read(apiClientProvider));

    return Scaffold(
      appBar: AppBar(title: Text("Select ${category.toUpperCase()}")),
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
            return const Center(child: Text("No components found"));
          }

          return ListView.builder(
            itemCount: components.length,
            itemBuilder: (context, i) {
              final comp = components[i];
              return Card(
                child: ListTile(
                  leading: comp["image_url"] != null
                      ? Image.network(comp["image_url"], width: 56, height: 56)
                      : const Icon(Icons.image),
                  title: Text(comp["name"]),
                  subtitle: Text("₱${comp["price"]}"),
                  onTap: () async {
                    // ➤ Add component to temp build
                    await ref
                        .read(buildProvider.notifier)
                        .addComponent(category, comp["id"]);

                    // Go back to Build Tab
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${comp["name"]} added!")),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
