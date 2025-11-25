import 'package:flutter/material.dart';
import 'login_screen.dart';

class IntroScreen extends StatefulWidget {
  static const routeName = '/intro';
  const IntroScreen({Key? key}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pc = PageController();
  int _index = 0;

  final pages = [
    {
      'title': 'Build and customize',
      'desc': 'Build and customize the perfect PC.',
    },
    {
      'title': 'Compatibility',
      'desc': 'Automatic component compatibility checking.',
    },
    {
      'title': 'Auto Build',
      'desc': 'Auto-build for Gaming / Workstation / Streaming / Basic.',
    },
    {'title': 'Save & Share', 'desc': 'Save and revisit your builds anytime.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, LoginScreen.routeName);
            },
            child: const Text('Skip'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pc,
              onPageChanged: (v) => setState(() => _index = v),
              itemCount: pages.length,
              itemBuilder: (context, i) {
                final p = pages[i];
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.widgets, size: 96),
                        const SizedBox(height: 20),
                        Text(
                          p['title']!,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          p['desc']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
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
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    if (_index == pages.length - 1) {
                      Navigator.pushReplacementNamed(
                        context,
                        LoginScreen.routeName,
                      );
                    } else {
                      _pc.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(
                    _index == pages.length - 1
                        ? 'Get Started → Login'
                        : 'Next →',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
