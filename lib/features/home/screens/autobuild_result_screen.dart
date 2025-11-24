// frontend/lib/features/autobuild/screens/autobuild_result_screen.dart
import 'package:flutter/material.dart';

class AutoBuildResultScreen extends StatelessWidget {
  static const routeName = '/autobuild-result';

  final Map<String, dynamic>? result;

  const AutoBuildResultScreen({Key? key, this.result}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // allow navigation via named route (ModalRoute) or direct constructor
    final args =
        result ??
        (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?);

    final title = args?['title'] ?? 'Your Suggested Build';
    final summary = args?['summary'] ?? args?['description'] ?? '';
    final parts = (args?['parts'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final estimatedPrice = args?['estimated_price'] ?? args?['price'] ?? null;

    return Scaffold(
      appBar: AppBar(title: Text('AutoBuild Result'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (estimatedPrice != null)
                    Text(
                      '₱${estimatedPrice.toString()}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (summary.isNotEmpty)
                Text(summary, style: const TextStyle(color: Colors.black87)),
              const SizedBox(height: 12),

              // Parts list
              Expanded(
                child: parts.isEmpty
                    ? const Center(
                        child: Text('No parts returned by autobuild.'),
                      )
                    : ListView.separated(
                        itemCount: parts.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, i) {
                          final p = parts[i];
                          final name = p['name'] ?? p['title'] ?? 'Part';
                          final category = p['category'] ?? p['type'] ?? '';
                          final price = p['price'] != null
                              ? '₱${p['price']}'
                              : '';
                          final vendor = p['vendor'] ?? '';
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                name.toString().substring(0, 1).toUpperCase(),
                              ),
                            ),
                            title: Text(
                              name.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              [
                                category,
                                vendor,
                              ].where((s) => s != '').join(' • '),
                            ),
                            trailing: Text(
                              price,
                              style: const TextStyle(color: Colors.blueAccent),
                            ),
                          );
                        },
                      ),
              ),

              // Footer actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: wire save-to-user-build endpoint
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Save build not implemented in demo'),
                          ),
                        );
                      },
                      child: const Text('Save Build'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
