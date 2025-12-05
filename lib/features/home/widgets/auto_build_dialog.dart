import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pc_component_picker/core/services/api_client_provider.dart';

import 'package:pc_component_picker/features/build/services/build_service.dart';
import 'package:pc_component_picker/features/build/providers/build_provider.dart';
import 'package:pc_component_picker/features/navigation/providers/nav_provider.dart';
import 'package:pc_component_picker/features/auth/providers/auth_provider.dart';
import 'package:pc_component_picker/core/services/api_client.dart';

class AutoBuildDialog {
  static void show(BuildContext context, WidgetRef ref) {
    double budget = 25000;
    String selected = "gaming";

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (_, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 80,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Auto Build My PC",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Choose your purpose and set your budget",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),

                    // PURPOSE GRID
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      childAspectRatio: 1.15,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _purposeCard(
                          label: "Gaming",
                          icon: Icons.videogame_asset_rounded,
                          active: selected == "gaming",
                          onTap: () => setState(() => selected = "gaming"),
                        ),
                        _purposeCard(
                          label: "Workstation",
                          icon: Icons.work_outline_rounded,
                          active: selected == "workstation",
                          onTap: () => setState(() => selected = "workstation"),
                        ),
                        _purposeCard(
                          label: "Streaming",
                          icon: Icons.videocam_rounded,
                          active: selected == "streaming",
                          onTap: () => setState(() => selected = "streaming"),
                        ),
                        _purposeCard(
                          label: "Basic",
                          icon: Icons.computer_rounded,
                          active: selected == "basic",
                          onTap: () => setState(() => selected = "basic"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Budget: ₱${budget.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    Slider(
                      value: budget,
                      min: 25000,
                      max: 150000,
                      activeColor: Colors.blue,
                      divisions: 25,
                      label: "₱${budget.toInt()}",
                      onChanged: (v) => setState(() => budget = v),
                    ),

                    const SizedBox(height: 12),

                    // GENERATE BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Show loader (above dialog)
                          showDialog(
                            context: dialogContext,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          try {
                            // USE API CLIENT WITH TOKEN
                            final api = ref.read(apiClientProvider);
                            final buildService = BuildService(api);

                            final res = await buildService.autoBuild(
                              selected,
                              budget.toInt(),
                            );

                            // TRY TO EXTRACT BUILD RESULT
                            final build =
                                res['build'] ??
                                res['data']?['build'] ??
                                res['data'];

                            if (build == null) {
                              Navigator.of(dialogContext).pop(); // loader
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Auto build returned no data"),
                                ),
                              );
                              return;
                            }

                            // UPDATE TEMP BUILD PROVIDER
                            ref
                                .read(buildProvider.notifier)
                                .setTempBuild(
                                  Map<String, dynamic>.from(build),
                                  Map<String, dynamic>.from(
                                    res["summary"] ?? {},
                                  ),
                                );

                            // SWITCH TO BUILD TAB
                            ref.read(navIndexProvider.notifier).state = 1;

                            // CLOSE LOADER then DIALOG
                            Navigator.of(dialogContext).pop(); // loader
                            Navigator.of(context).pop(); // dialog
                          } catch (e) {
                            Navigator.of(dialogContext).pop(); // loader
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Auto build failed: $e")),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Generate Build",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // PURPOSE CARD WIDGET
  static Widget _purposeCard({
    required String label,
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1976D2) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? const Color(0xFF1976D2) : Colors.grey[300]!,
            width: 1.6,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: const Color(0xFF1976D2).withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 36,
              color: active ? Colors.white : const Color(0xFF1976D2),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
