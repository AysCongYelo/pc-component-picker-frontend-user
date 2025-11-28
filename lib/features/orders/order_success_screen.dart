import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/navigation/main_navigation.dart';
import 'package:frontend/features/navigation/providers/nav_provider.dart';

class OrderSuccessScreen extends ConsumerWidget {
  final String orderId;

  const OrderSuccessScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 120),
              const SizedBox(height: 20),

              const Text(
                "Order Successful!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Text(
                "Your order has been placed.\nOrder ID: $orderId",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),

              const SizedBox(height: 40),

              // ➤ VIEW ORDERS
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, "/my-orders");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "View My Orders",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ➤ BACK TO HOME (ALWAYS GOES TO HOME TAB)
              TextButton(
                onPressed: () {
                  // ✅ Reset nav provider to Home tab FIRST
                  ref.read(navIndexProvider.notifier).state = 0;

                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    MainNavigation.routeName,
                    (route) => false,
                  );
                },
                child: const Text(
                  "Back to Home",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
