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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            if (image.startsWith("assets"))
              Image.asset(
                image,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              )
            else
              CachedNetworkImage(
                imageUrl: image,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(height: 220, color: Colors.grey[300]),
                errorWidget: (_, __, ___) =>
                    Container(height: 220, color: Colors.grey[300]),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
