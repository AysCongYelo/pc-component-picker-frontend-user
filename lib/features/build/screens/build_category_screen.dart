import 'package:flutter/material.dart';
import 'build_components_screen.dart';

class BuildCategoryScreen extends StatelessWidget {
  final String? preselectedCategory;
  final Set<String> selectedCategories;

  const BuildCategoryScreen({
    super.key,
    this.preselectedCategory,
    this.selectedCategories = const {},
  });

  static const routeName = '/build-category';

  final List<Map<String, dynamic>> categories = const [
    {"label": "CPU", "value": "cpu", "icon": Icons.memory},
    {"label": "GPU", "value": "gpu", "icon": Icons.graphic_eq},
    {
      "label": "Motherboard",
      "value": "motherboard",
      "icon": Icons.developer_board,
    },
    {"label": "Memory", "value": "memory", "icon": Icons.storage},
    {"label": "Storage", "value": "storage", "icon": Icons.sd_storage},
    {"label": "Power Supply", "value": "psu", "icon": Icons.power},
    {"label": "Case", "value": "case", "icon": Icons.devices},
    {"label": "Cooler", "value": "cpu_cooler", "icon": Icons.ac_unit},
  ];

  @override
  Widget build(BuildContext context) {
    const mainBlue = Color(0xFF2563EB);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Select Category",
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
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

      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, i) {
          final cat = categories[i];
          final bool isHighlighted = preselectedCategory == cat["value"];
          final bool isSelectedAlready = selectedCategories.contains(
            cat["value"],
          );

          return Opacity(
            opacity: isSelectedAlready ? 0.45 : 1.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isHighlighted ? mainBlue : Colors.grey.shade200,
                  width: isHighlighted ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),

              child: ListTile(
                enabled: !isSelectedAlready,
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),

                leading: Icon(
                  cat["icon"],
                  size: 28,
                  color: isSelectedAlready
                      ? Colors.grey
                      : isHighlighted
                      ? mainBlue
                      : Colors.grey[700],
                ),

                title: Text(
                  cat["label"],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isHighlighted
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: isSelectedAlready
                        ? Colors.grey
                        : isHighlighted
                        ? mainBlue
                        : const Color(0xFF1E293B),
                  ),
                ),

                trailing: isSelectedAlready
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),

                onTap: isSelectedAlready
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                BuildComponentsScreen(category: cat["value"]),
                          ),
                        );
                      },
              ),
            ),
          );
        },
      ),
    );
  }
}
