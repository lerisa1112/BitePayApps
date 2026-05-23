import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  final int totalItems;
  final int totalPrice;

  const PaymentScreen({super.key, required this.totalItems, required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF9370DB),
        elevation: 1,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Total Items: $totalItems", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Total Price: ₹$totalPrice", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Here you can integrate actual payment gateway
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Payment Successful!")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9370DB),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Pay Now", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}