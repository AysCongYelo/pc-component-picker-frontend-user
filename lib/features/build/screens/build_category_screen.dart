import 'package:flutter/material.dart';
import 'build_components_screen.dart';

class BuildCategoryScreen extends StatelessWidget {
  final String? preselectedCategory;
  final Set<String> selectedCategories; // ⭐ NEW

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Category"),
        backgroundColor: Colors.blueAccent,
      ),

      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final cat = categories[i];

          final bool isHighlighted =
              preselectedCategory != null &&
              preselectedCategory == cat["value"];

          final bool isSelectedAlready = selectedCategories.contains(
            cat["value"],
          ); // ⭐ NEW

          return Opacity(
            opacity: isSelectedAlready ? 0.4 : 1.0, // ⭐ gray out selected
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isHighlighted
                    ? Colors.blue.withOpacity(0.12)
                    : Colors.white,
                border: isHighlighted
                    ? Border.all(color: Colors.blueAccent, width: 2)
                    : null,
              ),
              child: ListTile(
                enabled: !isSelectedAlready, // ⭐ cannot tap
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: Icon(
                  cat["icon"],
                  color: isSelectedAlready
                      ? Colors.grey
                      : isHighlighted
                      ? Colors.blueAccent
                      : Colors.grey[700],
                ),
                title: Text(
                  cat["label"],
                  style: TextStyle(
                    fontWeight: isHighlighted
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelectedAlready
                        ? Colors.grey
                        : isHighlighted
                        ? Colors.blueAccent
                        : Colors.black87,
                  ),
                ),

                // ⭐ checkmark or arrow
                trailing: isSelectedAlready
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.arrow_forward_ios, size: 16),

                onTap: isSelectedAlready
                    ? null // disabled
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
