import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/services/api_client_provider.dart';
import 'package:frontend/features/build/providers/build_provider.dart';
import 'package:frontend/features/build/providers/build_state.dart';
import 'package:frontend/features/save/screens/saved_builds_screen.dart';
import 'build_category_screen.dart';
import 'package:frontend/features/build/screens/build_components_screen.dart';

class BuildTab extends ConsumerStatefulWidget {
  const BuildTab({super.key});

  @override
  ConsumerState<BuildTab> createState() => _BuildTabState();
}

class _BuildTabState extends ConsumerState<BuildTab> {
  // ---------------- SHARED COLORS (same vibes as Cart) ----------------
  Color get _primaryBlue => const Color(0xFF2563EB);
  Color get _softGreyBg => const Color(0xFFF3F4F6);
  Color get _softGreen => const Color(0xFF22C55E);
  Color get _textDark => const Color(0xFF111827);

  // control kung lalabas yung Add Component + Auto Build row
  bool _showAddAutoButtons = true;

  // ---------------- PRICE FORMATTER ----------------
  String _formatCurrency(num value) {
    final s = value.toStringAsFixed(2);
    final parts = s.split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formattedInt = intPart.replaceAllMapped(reg, (m) => '${m[1]},');

    return '₱$formattedInt.$decPart';
  }

  String _formatCurrencyFromRaw(dynamic raw) {
    final v = double.tryParse(raw?.toString() ?? '') ?? 0;
    return _formatCurrency(v);
  }

  @override
  Widget build(BuildContext context) {
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
    return Scaffold(
      backgroundColor: _softGreyBg,
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        elevation: 2,
        centerTitle: true,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Build Workspace",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        // Sa error state, pinabayaan ko pa ring may RESET
        actions: [
          TextButton(
            onPressed: () {
              ref.read(buildProvider.notifier).reset();
              setState(() => _showAddAutoButtons = true);

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 12),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    ref.read(buildProvider.notifier).loadTempBuild(),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------
  // MAIN CONTENT
  // --------------------------------------------------------------
  Widget _content(BuildContext context, WidgetRef ref, BuildState state) {
    // original build galing sa provider
    final rawBuild = state.build;

    // alisin yung __source_build_id key para hindi lumabas sa UI
    final filteredBuild = Map<String, dynamic>.from(rawBuild)
      ..remove("__source_build_id");

    final summary = state.summary;

    final entries = filteredBuild.entries.toList();
    final totalPrice = (summary["total_price"] ?? 0) as num;
    final powerUsage = (summary["power_usage"] ?? 0) as num;
    final hasComponents = entries.isNotEmpty;

    return Scaffold(
      backgroundColor: _softGreyBg,
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        elevation: 2,
        centerTitle: true,
        automaticallyImplyLeading: true, // back arrow
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Build Workspace",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        // ✅ RESET lalabas lang kapag may components
        actions: hasComponents
            ? [
                TextButton(
                  onPressed: () {
                    ref.read(buildProvider.notifier).reset();
                    setState(() => _showAddAutoButtons = true);

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
              ]
            : [],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => ref.read(buildProvider.notifier).loadTempBuild(),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                hasComponents ? 220 : 160, // space para sa bottom bar
              ),
              children: [
                if (entries.isEmpty) ...[
                  _emptyState(),
                  const SizedBox(height: 32),
                  if (_showAddAutoButtons)
                    _addAndAutoButtons(context, ref, filteredBuild),
                ] else ...[
                  ...entries.map((item) {
                    final cat = item.key;
                    final comp = item.value;
                    return _componentCard(
                      context,
                      ref,
                      cat,
                      comp,
                      filteredBuild,
                    );
                  }),
                  const SizedBox(height: 24),
                  if (_showAddAutoButtons)
                    _addAndAutoButtons(context, ref, filteredBuild),
                ],
              ],
            ),
          ),

          // BOTTOM SUMMARY + ACTIONS (Save + Cart lang)
          if (hasComponents)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _bottomSummaryStrip(totalPrice, powerUsage),
                      const SizedBox(height: 10),
                      _bottomActionButtons(context, ref),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------
  // COMPONENT CARD (New Layout, similar vibes to Cart item)
  // --------------------------------------------------------------
  Widget _componentCard(
    BuildContext context,
    WidgetRef ref,
    String category,
    dynamic comp,
    Map<String, dynamic> build,
  ) {
    final isMap = comp is Map<String, dynamic>;
    final name = isMap
        ? comp["name"]?.toString() ?? "Unknown Component"
        : comp.toString();
    final rawPrice = isMap ? (comp["price"]?.toString() ?? "0") : "0";
    final priceText = _formatCurrencyFromRaw(rawPrice);
    final imageUrl = isMap ? (comp["image_url"]?.toString() ?? "") : "";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 70,
              height: 70,
              color: _primaryBlue.withOpacity(0.05),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                      ),
                    )
                  : const Icon(
                      Icons.memory,
                      size: 28,
                      color: Colors.grey,
                    ),
            ),
          ),

          const SizedBox(width: 12),

          // TEXTS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CATEGORY CHIP
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    category.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // NAME
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 4),
                // PRICE
                Text(
                  priceText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _softGreen,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 4),

          // ACTIONS
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                splashRadius: 18,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BuildComponentsScreen(
                        category: category.toLowerCase(),
                        isEditing: true,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                splashRadius: 18,
                onPressed: () {
                  ref.read(buildProvider.notifier).removeComponent(category);
                  // kapag nag-delete, ibalik yung Add + Auto buttons
                  setState(() => _showAddAutoButtons = true);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------
  // ADD COMPONENT + AUTO BUILD ROW (scrollable, nasa pinakababa ng list)
  // --------------------------------------------------------------
  Widget _addAndAutoButtons(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> build,
  ) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryBlue, // blue
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            label: const Text(
              "Add Component",
              style: TextStyle(fontSize: 15, color: Colors.white),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BuildCategoryScreen(
                    selectedCategories: build.keys.toSet(),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal, // teal
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.auto_fix_high, color: Colors.white),
            label: const Text(
              "Auto Complete",
              style: TextStyle(fontSize: 15, color: Colors.white),
            ),
            onPressed: () async {
              try {
                await ref.read(buildProvider.notifier).autoComplete();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Auto-complete successful!"),
                  ),
                );

                // pag nag-Auto Build, itago yung Add + Auto row
                setState(() => _showAddAutoButtons = false);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: $e")),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------
  // BOTTOM SUMMARY STRIP (inside fixed bottom bar)
  // --------------------------------------------------------------
  Widget _bottomSummaryStrip(num totalPrice, num powerUsage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Total
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatCurrency(totalPrice),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Power usage pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt, size: 14, color: Colors.orange),
                const SizedBox(width: 4),
                Text(
                  "${powerUsage.toStringAsFixed(0)}W",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  // --------------------------------------------------------------
  // BOTTOM ACTION BUTTONS (Save + Cart only)
  // --------------------------------------------------------------
  Widget _bottomActionButtons(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.save, color: Colors.white, size: 18),
            label: const Text(
              "Save",
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            onPressed: () => _saveBuildDialog(context, ref),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon:
                const Icon(Icons.shopping_cart, color: Colors.white, size: 18),
            label: const Text(
              "Cart",
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            onPressed: () async {
              try {
                final res = await ref
                    .read(apiClientProvider)
                    .post("/cart/addTempBuild", {});

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Added ${res['count']} items to cart!"),
                  ),
                );

                await ref.read(buildProvider.notifier).reset();
                setState(() => _showAddAutoButtons = true);
                await ref.read(buildProvider.notifier).loadTempBuild();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: $e")),
                );
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
  // Save Build Dialog (Save button blue)
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
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryBlue,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final name = controller.text.trim();

              Navigator.of(context, rootNavigator: true).pop();

              try {
                await ref.read(buildProvider.notifier).save(name);
                SavedBuildsPage.shouldRefresh = true;

                if (!mounted) return;

                // Pagkatapos mag-save, siguraduhin na visible ulit Add + Auto buttons
                setState(() => _showAddAutoButtons = true);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Build saved successfully!"),
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: $e")),
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
