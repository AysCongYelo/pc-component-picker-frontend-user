import 'package:flutter/material.dart';

class BuildItemTile extends StatelessWidget {
  final String label;
  final String name;
  final String price;
  final String? imageUrl;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;

  const BuildItemTile({
    super.key,
    required this.label,
    required this.name,
    required this.price,
    this.imageUrl,
    this.onEdit,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? Image.network(
                      imageUrl!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 56,
                      height: 56,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image, color: Colors.white),
                    ),
            ),

            const SizedBox(width: 14),

            // Name + type + price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "₱$price",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                ],
              ),
            ),

            // Actions
            Row(
              children: [
                _actionButton(
                  icon: Icons.edit,
                  color: Colors.grey.shade700,
                  bg: Colors.grey.shade100,
                  onTap: onEdit,
                ),
                const SizedBox(width: 8),
                _actionButton(
                  icon: Icons.delete_outline,
                  color: Colors.red.shade400,
                  bg: Colors.red.shade50,
                  onTap: onRemove,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required Color bg,
    required VoidCallback? onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Material(
        color: bg,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 20, color: color),
          ),
        ),
      ),
    );
  }
}
