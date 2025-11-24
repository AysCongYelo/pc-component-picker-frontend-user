// lib/features/save/screens/saved_screen.dart
import 'package:flutter/material.dart';

/// Self-contained Saved Builds screen with working UI + logic.
/// - If you have your own GradientAppBar widget, remove the internal one below
///   and replace with your import:
///   import 'package:capstone_project/widgets/appbar.dart';
///
/// - If you have PCComponent model, you can convert `Map<String,dynamic>` back
///   to your typed model where noted.

// -----------------------------
// Simple Gradient AppBar (fallback)
// -----------------------------
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const GradientAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF4CAF50)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// -----------------------------
// SavedBuild model (simple, self-contained)
// -----------------------------
class SavedBuild {
  final String name;
  final double price;
  final bool isCompatible;
  final String statusMessage;
  final List<Map<String, dynamic>>
  components; // use your PCComponent model if available

  SavedBuild({
    required this.name,
    required this.price,
    required this.isCompatible,
    required this.statusMessage,
    required this.components,
  });
}

// -----------------------------
// UI Screen
// -----------------------------
class SavedBuildsPage extends StatefulWidget {
  final Function(SavedBuild)? onEditSavedBuild;
  final VoidCallback? onAutoBuild;

  const SavedBuildsPage({Key? key, this.onEditSavedBuild, this.onAutoBuild})
    : super(key: key);

  @override
  _SavedBuildsPageState createState() => _SavedBuildsPageState();
}

class _SavedBuildsPageState extends State<SavedBuildsPage> {
  // In-memory store. Replace with API / provider as needed.
  static final List<SavedBuild> _savedBuilds = [];

  // Expose a notifier so other parts of the app can listen if you wire it.
  static final ValueNotifier<List<SavedBuild>> savedBuildsNotifier =
      ValueNotifier<List<SavedBuild>>(_savedBuilds);

  @override
  void dispose() {
    // If other parts listen, you may want to keep notifier alive.
    // savedBuildsNotifier.dispose();
    super.dispose();
  }

  // Helper to format price with comma separators
  static String formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  void _deleteBuild(int index) {
    final removed = _savedBuilds[index];
    setState(() {
      _savedBuilds.removeAt(index);
      savedBuildsNotifier.value = List.from(_savedBuilds);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted build "${removed.name}"'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  // Add a build (for testing). In your app, call this when backend confirms saved.
  void _addTestBuild() {
    final b = SavedBuild(
      name: 'My Build ${_savedBuilds.length + 1}',
      price: (1000 + _savedBuilds.length * 100).toDouble(),
      isCompatible: _savedBuilds.length % 2 == 0,
      statusMessage: _savedBuilds.length % 2 == 0 ? 'All Good' : 'Issues Found',
      components: [
        {'category': 'cpu', 'name': 'Ryzen 7', 'price': 18000},
        {'category': 'gpu', 'name': 'RTX 4070', 'price': 40000},
      ],
    );
    setState(() {
      _savedBuilds.add(b);
      savedBuildsNotifier.value = List.from(_savedBuilds);
    });
  }

  // Edit stub: open editor or call callback
  void _editBuild(SavedBuild build) {
    if (widget.onEditSavedBuild != null) {
      widget.onEditSavedBuild!(build);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit "${build.name}" — feature not implemented.'),
      ),
    );
  }

  // Checkout stub
  void _checkoutBuild(SavedBuild build) {
    // Replace with your checkout navigation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Checkout "${build.name}" — feature not implemented.'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // Share stub
  void _shareBuild(SavedBuild build) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share "${build.name}" — feature not implemented.'),
      ),
    );
  }

  // Simple tile helper for action buttons
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.18), width: 1.2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutButton({required VoidCallback onPressed}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Checkout',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.10),
                    Colors.blue.withOpacity(0.04),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bookmark_border_rounded,
                size: 80,
                color: Color(0xFF00BCD4),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'No Saved Builds Yet',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Start building your dream PC\nor let us create one for you',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF757575),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: widget.onAutoBuild ?? _addTestBuild,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BCD4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                shadowColor: const Color(0xFF00BCD4).withOpacity(0.4),
                elevation: 8,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Auto Build For Me',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _addTestBuild,
              child: const Text('(Dev) Add test build'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuildCard(SavedBuild build, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: title + status + price box
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF5F7FA), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            build.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: build.isCompatible
                                  ? const Color(0xFFE8F5E9)
                                  : const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: build.isCompatible
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFFFF9800),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  build.isCompatible
                                      ? Icons.verified_rounded
                                      : Icons.warning_amber_rounded,
                                  size: 16,
                                  color: build.isCompatible
                                      ? const Color(0xFF4CAF50)
                                      : const Color(0xFFFF9800),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  build.statusMessage,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: build.isCompatible
                                        ? const Color(0xFF4CAF50)
                                        : const Color(0xFFFF9800),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00BCD4).withOpacity(0.28),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            '₱${formatPrice(build.price.toInt())}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),

          // Actions + checkout
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.edit_rounded,
                    label: 'Edit',
                    color: const Color(0xFF5C6BC0),
                    onPressed: () => _editBuild(build),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.share_rounded,
                    label: 'Share',
                    color: const Color(0xFF42A5F5),
                    onPressed: () => _shareBuild(build),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.delete_rounded,
                    label: 'Delete',
                    color: const Color(0xFFF44336),
                    onPressed: () => _deleteBuild(index),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _buildCheckoutButton(
                    onPressed: () => _checkoutBuild(build),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Main scaffold
  @override
  Widget build(BuildContext context) {
    final isEmpty = _savedBuilds.isEmpty;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.white],
          ),
        ),
        child: isEmpty ? _buildEmptyState(context) : _buildBuildsList(context),
      ),
    );
  }

  Widget _buildBuildsList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _savedBuilds.length,
      itemBuilder: (context, index) {
        final build = _savedBuilds[index];
        return _buildBuildCard(build, index);
      },
    );
  }
}
