import 'package:flutter/material.dart';

class CarouselBanner extends StatefulWidget {
  const CarouselBanner({super.key});

  @override
  State<CarouselBanner> createState() => _CarouselBannerState();
}

class _CarouselBannerState extends State<CarouselBanner> {
  int pageIndex = 0;

  final List<String> promoTexts = [
    "🔥 Build Your Dream PC!",
    "⚡ Fast & Compatible Parts",
    "💻 Best Deals for Your Budget",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: PageView.builder(
              itemCount: promoTexts.length,
              onPageChanged: (i) => setState(() => pageIndex = i),
              itemBuilder: (context, i) {
                return Container(
                  color: Colors.blue[50],
                  child: Center(
                    child: Text(
                      promoTexts[i],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            promoTexts.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: pageIndex == i ? 18 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: pageIndex == i ? Colors.blue : Colors.grey[400],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
