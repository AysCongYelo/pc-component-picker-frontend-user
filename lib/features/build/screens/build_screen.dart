import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/services/api_client_provider.dart';
import 'package:frontend/features/build/providers/build_provider.dart';
import 'package:frontend/features/build/providers/build_state.dart';
import 'build_category_screen.dart';

class BuildTab extends ConsumerWidget {
  const BuildTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(buildProvider);

    return asyncState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => _errorView(context, ref, e.toString()),
      data: (state) => _content(context, ref, state),
    );
  }

  // -------------------------------
  // ERROR VIEW
  // -------------------------------
  Widget _errorView(BuildContext context, WidgetRef ref, String error) {
    return Scaffold(
      appBar: AppBar(title: const Text("Build Workspace")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(error),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                ref.read(buildProvider.notifier).loadTempBuild();
              },
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------
  // MAIN CONTENT
  // -------------------------------
  Widget _content(BuildContext context, WidgetRef ref, BuildState state) {
    final build = state.build;
    final summary = state.summary;

    final entries = build.entries.toList();
    final totalPrice = summary["total_price"] ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text("Build Workspace")),
      body: RefreshIndicator(
        onRefresh: () => ref.read(buildProvider.notifier).loadTempBuild(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (entries.isEmpty)
              _emptyState()
            else
              ...entries.map((item) {
                final cat = item.key;
                final comp = item.value;
                return _componentCard(context, ref, cat, comp);
              }),

            const SizedBox(height: 20),
            _addComponentButton(context),

            const SizedBox(height: 20),
            _summaryCard(totalPrice, summary["power_usage"] ?? 0),

            const SizedBox(height: 20),

            // FIX: show the buttons
            _actionButtons(context, ref),

            const SizedBox(height: 20),

            _resetButton(ref),
          ],
        ),
      ),
    );
  }

  // -------------------------------
  // COMPONENT CARD
  // -------------------------------
  Widget _componentCard(
    BuildContext context,
    WidgetRef ref,
    String category,
    dynamic comp,
  ) {
    return Card(
      child: ListTile(
        title: Text(comp["name"] ?? "Unknown"),
        subtitle: Text("₱${comp["price"]}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✏ EDIT BUTTON
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        BuildCategoryScreen(preselectedCategory: category),
                  ),
                );
              },
            ),

            // 🗑 DELETE BUTTON
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                ref.read(buildProvider.notifier).removeComponent(category);
              },
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------
  // ADD COMPONENT BUTTON
  // -------------------------------
  Widget _addComponentButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BuildCategoryScreen()),
        );
      },
      child: const Text("Add Component"),
    );
  }

  // -------------------------------
  // SUMMARY CARD
  // -------------------------------
  Widget _summaryCard(int totalPrice, int powerUsage) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Total: ₱$totalPrice",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Power Usage: ${powerUsage}W",
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------
  // RESET BUTTON
  // -------------------------------
  Widget _resetButton(WidgetRef ref) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      onPressed: () {
        ref.read(buildProvider.notifier).reset();
      },
      child: const Text("Reset Build"),
    );
  }

  // -------------------------------
  // EMPTY STATE
  // -------------------------------
  Widget _emptyState() {
    return Column(
      children: const [
        Icon(Icons.build, size: 64, color: Colors.grey),
        SizedBox(height: 12),
        Text("Your build is empty"),
      ],
    );
  }

  // -------------------------------
  // ACTION BUTTONS
  // -------------------------------
  Widget _actionButtons(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // AUTO COMPLETE
        ElevatedButton.icon(
          icon: const Icon(Icons.auto_fix_high),
          label: const Text("Auto Complete"),
          onPressed: () async {
            try {
              await ref.read(buildProvider.notifier).autoComplete();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Auto-complete successful!")),
              );
            } catch (e) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Error: $e")));
            }
          },
        ),

        const SizedBox(height: 12),

        // SAVE BUILD
        ElevatedButton.icon(
          icon: const Icon(Icons.save),
          label: const Text("Save Build"),
          onPressed: () {
            final controller = TextEditingController();

            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Save Build"),
                content: TextField(
                  controller: controller,
                  decoration: const InputDecoration(labelText: "Build Name"),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final name = controller.text.trim();
                      Navigator.pop(context);

                      try {
                        final id = await ref
                            .read(buildProvider.notifier)
                            .save(name);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Saved! Build ID: $id")),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("Error: $e")));
                      }
                    },
                    child: const Text("Save"),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 12),

        // ⭐ ADD TEMP BUILD TO CART ⭐
        ElevatedButton.icon(
          icon: const Icon(Icons.shopping_cart),
          label: const Text("Add Build to Cart"),
          onPressed: () async {
            try {
              final res = await ref
                  .read(apiClientProvider)
                  .post("/cart/addTempBuild", {});

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Added ${res['count']} items to cart!")),
              );
            } catch (e) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Error: $e")));
            }
          },
        ),
      ],
    );
  }
}
