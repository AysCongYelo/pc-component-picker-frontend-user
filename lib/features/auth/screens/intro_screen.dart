import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pc_component_picker/features/auth/providers/intro_provider.dart';
import 'login_screen.dart';

class IntroScreen extends ConsumerStatefulWidget {
  static const routeName = '/intro';
  const IntroScreen({super.key});

  @override
  ConsumerState<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pc = PageController();
  int _index = 0;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final pages = [
    {
      'icon': Icons.build_rounded,
      'title': 'Build & Customize',
      'desc': 'Create your perfect PC using thousands of components.',
    },
    {
      'icon': Icons.check_circle_outline,
      'title': 'Compatibility Check',
      'desc': 'Automatically checks if every part works together.',
    },
    {
      'icon': Icons.auto_fix_high,
      'title': 'Auto Build',
      'desc':
          'Generate Gaming, Workstation, Streaming or Budget builds instantly.',
    },
    {
      'icon': Icons.save_alt_rounded,
      'title': 'Save & Share',
      'desc': 'Save builds and revisit them anytime.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _pc.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _finishIntro() async {
    await ref.read(introProvider.notifier).markSeen();
    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.purple.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Skip
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _finishIntro,
                    child: const Text("Skip", style: TextStyle(fontSize: 15)),
                  ),
                ),

                // Main content
                Expanded(
                  child: PageView.builder(
                    controller: _pc,
                    onPageChanged: (v) => setState(() => _index = v),
                    itemCount: pages.length,
                    itemBuilder: (context, i) {
                      final p = pages[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 20,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                p['icon'] as IconData,
                                size: 70,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            const SizedBox(height: 28),

                            Text(
                              p['title'] as String,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 12),

                            Text(
                              p['desc'] as String,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Dots + Next
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Row(
                    children: [
                      Row(
                        children: List.generate(
                          pages.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _index == i ? 18 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: _index == i
                                  ? Colors.blue.shade600
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () async {
                          if (_index == pages.length - 1) {
                            await _finishIntro();
                          } else {
                            _pc.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: Text(
                          _index == pages.length - 1 ? "Get Started" : "Next →",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
