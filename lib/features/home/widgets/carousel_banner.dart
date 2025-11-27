import 'package:flutter/material.dart';

class CarouselBanner extends StatefulWidget {
  const CarouselBanner({super.key});

  @override
  State<CarouselBanner> createState() => _CarouselBannerState();
}

class _CarouselBannerState extends State<CarouselBanner> {
  int pageIndex = 0;

  final List<Map<String, String>> banners = [
    {
      "image": "assets/banners/autobuild.jpg",
      "title": "🔥 Auto Build Your PC!",
      "subtitle": "Choose purpose + budget — generate instantly.",
    },
    {
      "image": "assets/banners/featured.jpg",
      "title": "⭐ Featured Build of the Week",
      "subtitle": "Check this optimized 1080p gaming setup.",
    },
    {
      "image": "assets/banners/tips.jpg",
      "title": "📘 Tips & Guides",
      "subtitle": "Learn how to choose PC parts wisely.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: PageView.builder(
              itemCount: banners.length,
              onPageChanged: (i) => setState(() => pageIndex = i),
              itemBuilder: (context, i) {
                final banner = banners[i];

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // 🔵 Background Image
                    Image.asset(banner["image"]!, fit: BoxFit.cover),

                    // 🔵 Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                    ),

                    // 🔵 Title + Subtitle
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            banner["title"]!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            banner["subtitle"]!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 8),

        // 🔵 Page Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            banners.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
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
