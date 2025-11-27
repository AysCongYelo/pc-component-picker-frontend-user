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

  // --------------------------------------------------------------
  // ERROR VIEW
  // --------------------------------------------------------------
  Widget _errorView(BuildContext context, WidgetRef ref, String error) {
    // ← FIXED: Changed name from _content to _errorView
    return Scaffold(
      appBar: AppBar(
        title: const Text("Build Workspace"),
        backgroundColor: Colors.blue.shade700,
        elevation: 2,
        actions: [
          TextButton(
            onPressed: () {
              ref.read(buildProvider.notifier).reset();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Build has been reset")),
              );
            },
            child: const Text(
              "RESET",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 12),
            Text(error),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.read(buildProvider.notifier).loadTempBuild(),
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------
  // MAIN CONTENT
  // --------------------------------------------------------------
  Widget _content(BuildContext context, WidgetRef ref, BuildState state) {
    final build = state.build;
    final summary = state.summary;

    final entries = build.entries.toList();
    final totalPrice = summary["total_price"] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Build Workspace"),
        backgroundColor: Colors.blue.shade700,
        elevation: 2,
        actions: [
          TextButton(
            onPressed: () {
              ref.read(buildProvider.notifier).reset();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Build has been reset")),
              );
            },
            child: const Text(
              "RESET",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

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
                return _componentCard(context, ref, cat, comp, build);
              }),

            const SizedBox(height: 20),
            _addComponentButton(context, build),

            const SizedBox(height: 26),
            const Text(
              "Build Summary",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 12),
            _summaryCard(totalPrice, summary["power_usage"] ?? 0),

            const SizedBox(height: 30),

            _scrollingActionButtons(context, ref),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------
  // COMPONENT CARD (Modern UI)
  // --------------------------------------------------------------
  Widget _componentCard(
    BuildContext context,
    WidgetRef ref,
    String category,
    dynamic comp,
    Map<String, dynamic> build,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),

        // IMAGE
        leading: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade200,
          ),
          clipBehavior: Clip.hardEdge,
          child:
              comp["image_url"] != null &&
                  comp["image_url"].toString().isNotEmpty
              ? Image.network(comp["image_url"], fit: BoxFit.cover)
              : const Icon(Icons.image, size: 24, color: Colors.grey),
        ),

        // ⭐ THIS WAS MISSING
        title: Text(
          comp["name"] ?? "Unknown Component",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),

        subtitle: Text(
          "₱${comp["price"]}",
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),

        // EDIT + DELETE BUTTONS
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BuildCategoryScreen(
                      preselectedCategory: category,
                      selectedCategories: build.keys.toSet(),
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () =>
                  ref.read(buildProvider.notifier).removeComponent(category),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------
  // ADD COMPONENT BUTTON (Better UI)
  // --------------------------------------------------------------
  Widget _addComponentButton(BuildContext context, Map<String, dynamic> build) {
    return SizedBox(
      // ← ADDED SizedBox for full width
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade600,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.add_circle_outline),
        label: const Text("Add Component", style: TextStyle(fontSize: 16)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BuildCategoryScreen(
                selectedCategories: build.keys
                    .toSet(), // ⭐ pass selected categories
              ),
            ),
          );
        },
      ),
    );
  }

  // --------------------------------------------------------------
  // SUMMARY CARD (polished UI)
  // --------------------------------------------------------------
  Widget _summaryCard(int totalPrice, int powerUsage) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Price: ₱$totalPrice",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            "Power Usage: ${powerUsage}W",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _scrollingActionButtons(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.auto_fix_high, color: Colors.white),
            label: const Text("Auto", style: TextStyle(color: Colors.white)),
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
        ),

        const SizedBox(width: 10),

        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text("Save", style: TextStyle(color: Colors.white)),
            onPressed: () => _saveBuildDialog(context, ref),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            label: const Text("Cart", style: TextStyle(color: Colors.white)),
            onPressed: () async {
              try {
                final res = await ref
                    .read(apiClientProvider)
                    .post("/cart/addTempBuild", {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Added ${res['count']} to cart!")),
                );
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            },
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------
  // EMPTY STATE
  // --------------------------------------------------------------
  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 20),
      child: Column(
        children: [
          Icon(
            Icons.build_circle,
            size: 80,
            color: Colors.grey.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          const Text(
            "Your build is empty",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            "Start adding PC components to begin your build.",
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------
  // ACTION BUTTONS
  // --------------------------------------------------------------
  Widget _actionButtons(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _roundedActionButton(
          icon: Icons.auto_fix_high,
          label: "Auto Complete",
          color: Colors.teal,
          onTap: () async {
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
        _roundedActionButton(
          icon: Icons.save,
          label: "Save Build",
          color: Colors.orange,
          onTap: () => _saveBuildDialog(context, ref),
        ),
        const SizedBox(height: 12),
        _roundedActionButton(
          icon: Icons.shopping_cart,
          label: "Add Build to Cart",
          color: Colors.green,
          onTap: () async {
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

  // --------------------------------------------------------------
  // Reusable rounded button
  // --------------------------------------------------------------
  Widget _roundedActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      // ← ADDED SizedBox for full width
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        onPressed: onTap,
      ),
    );
  }

  // --------------------------------------------------------------
  // Save Build Dialog
  // --------------------------------------------------------------
  void _saveBuildDialog(BuildContext context, WidgetRef ref) {
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
                await ref.read(buildProvider.notifier).save(name);
                Navigator.pushNamed(context, "/saved");

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Build saved successfully!")),
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
  }
}
