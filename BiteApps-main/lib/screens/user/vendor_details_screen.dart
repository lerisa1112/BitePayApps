import 'package:flutter/material.dart';

class VendorDetailsScreen extends StatefulWidget {
  final String vendorName;
  const VendorDetailsScreen({super.key, required this.vendorName});

  @override
  State<VendorDetailsScreen> createState() => _VendorDetailsScreenState();
}

class _VendorDetailsScreenState extends State<VendorDetailsScreen> {
  final List<Map<String, dynamic>> menuItems = [
    {"name": "Burger", "price": 80, "icon": Icons.fastfood},
    {"name": "Pizza", "price": 120, "icon": Icons.local_pizza},
    {"name": "Cold Coffee", "price": 60, "icon": Icons.coffee},
  ];

  final Map<String, int> cart = {};
  String selectedTime = "ASAP";

  // Add to cart
  void addToCart(String name) {
    setState(() {
      cart[name] = (cart[name] ?? 0) + 1;
    });
  }

  // Remove from cart
  void removeFromCart(String name) {
    setState(() {
      if ((cart[name] ?? 0) > 1) {
        cart[name] = cart[name]! - 1;
      } else {
        cart.remove(name);
      }
    });
  }

  // Calculate total
  int getTotalAmount() {
    int total = 0;
    cart.forEach((name, qty) {
      final item = menuItems.firstWhere((e) => e['name'] == name);
      total += (item['price'] as int) * qty;
    });
    return total;
  }

  // Show cart bottom sheet
  void showCheckoutSheet() {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cart is empty!")),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              left: 20,
              right: 20,
              top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                  child: Text("Your Cart",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
              const SizedBox(height: 20),

              // Cart Items
              ...cart.entries.map((entry) {
                final item = menuItems.firstWhere((e) => e['name'] == entry.key);
                int itemTotal = (item['price'] as int) * entry.value;
                return ListTile(
                  leading: Icon(item['icon'], color: const Color(0xFF9370DB)),
                  title: Text("${entry.key} x${entry.value}"),
                  trailing: Text("₹$itemTotal",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                );
              }).toList(),

              const SizedBox(height: 20),

              // Pickup time selection
              const Text("Pick-up Time",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: ["ASAP", "15 Min", "30 Min", "1 Hour"].map((time) {
                  return ChoiceChip(
                    label: Text(time),
                    selected: selectedTime == time,
                    selectedColor: const Color(0xFF9370DB).withOpacity(0.3),
                    onSelected: (selected) {
                      setModalState(() {
                        selectedTime = time;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 25),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("₹${getTotalAmount()}",
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9370DB))),
                ],
              ),

              const SizedBox(height: 25),

              // Place Order Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // close bottom sheet
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle,
                                      color: Colors.green, size: 80),
                                  const SizedBox(height: 20),
                                  const Text("Order Placed!",
                                      style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 10),
                                  Text("Pickup Time: $selectedTime"),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      setState(() {
                                        cart.clear();
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF9370DB)),
                                    child: const Text("Done",
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            ));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9370DB),
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text("Place Order",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(widget.vendorName), backgroundColor: const Color(0xFF9370DB)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          int qty = cart[item['name']] ?? 0;
          int total = qty * item['price'];
          return Card(
            margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    height: 65,
                    width: 65,
                    decoration: BoxDecoration(
                        color: const Color(0xFF9370DB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15)),
                    child: Icon(item['icon'], size: 35, color: const Color(0xFF9370DB)),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['name'],
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text("₹${item['price']}"),
                        if (qty > 0)
                          Text("Total: ₹$total",
                              style: const TextStyle(
                                  color: Color(0xFF9370DB), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  qty == 0
                      ? ElevatedButton(
                          onPressed: () => addToCart(item['name']),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9370DB)),
                          child: const Text("Add", style: TextStyle(color: Colors.white)),
                        )
                      : Row(
                          children: [
                            IconButton(
                                onPressed: () => removeFromCart(item['name']),
                                icon: const Icon(Icons.remove_circle, color: Colors.red)),
                            Text("$qty", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            IconButton(
                                onPressed: () => addToCart(item['name']),
                                icon: const Icon(Icons.add_circle, color: Color(0xFF9370DB))),
                          ],
                        ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: showCheckoutSheet,
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9370DB), padding: const EdgeInsets.symmetric(vertical: 16)),
          child: Text("View Cart • ₹${getTotalAmount()}",
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
        ),
      ),
    );
  }
}