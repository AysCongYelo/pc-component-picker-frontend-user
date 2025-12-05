import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ArticleDetailScreen extends StatelessWidget {
  static const routeName = "/article-detail";

  final String title;
  final String image;
  final String content;

  const ArticleDetailScreen({
    super.key,
    required this.title,
    required this.image,
    required this.content,
  });

  // ----------- FORMAT PARAGRAPHS -----------
  List<Widget> _buildParagraphs() {
    final paragraphs = content.split("\n");

    return paragraphs.map((p) {
      if (p.trim().isEmpty) return const SizedBox(height: 12);

      // Highlighted Quote Block (auto-detect using >>)
      if (p.trim().startsWith(">>")) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: Colors.blue, width: 4)),
          ),
          child: Text(
            p.replaceFirst(">>", "").trim(),
            style: const TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(
          p.trim(),
          style: const TextStyle(
            fontSize: 16,
            height: 1.65,
            color: Colors.black87,
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final hasNetworkImage = image.startsWith("http");

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),

      // ----------------- APP BAR -----------------
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),

      // ----------------- CONTENT -----------------
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            hasNetworkImage
                ? CachedNetworkImage(
                    imageUrl: image,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(height: 220, color: Colors.grey[300]),
                    errorWidget: (_, __, ___) =>
                        Container(height: 220, color: Colors.grey[300]),
                  )
                : Image.asset(
                    image,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                  ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildParagraphs(),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),

      // ----------------- SHARE BUTTON -----------------
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.share, color: Colors.white),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Share this article",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),

                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Share feature coming soon!"),
                        ),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text("Share"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
