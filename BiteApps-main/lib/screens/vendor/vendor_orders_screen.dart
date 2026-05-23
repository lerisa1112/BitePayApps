import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class VendorOrdersScreen extends StatefulWidget {
  const VendorOrdersScreen({super.key});

  @override
  State<VendorOrdersScreen> createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends State<VendorOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool isLoading = true;

  List<dynamic> activeOrders = [];
  List<dynamic> pastOrders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    getOrders();
  }

  Future<void> getOrders() async {
    setState(() => isLoading = true);

    final response = await AuthService.getVendorOrders();

    if (response != null && response["success"] == true) {
      final orders = response["orders"] ?? [];

      activeOrders = (orders as List).where((o) {
        final status =
            (o["orderStatus"] ?? "").toString().toLowerCase();
        return status == "pending" || status == "preparing";
      }).toList();

      pastOrders = (orders as List).where((o) {
        final status =
            (o["orderStatus"] ?? "").toString().toLowerCase();
        return status == "ready" || status == "completed";
      }).toList();
    } else {
      activeOrders = [];
      pastOrders = [];
    }

    setState(() => isLoading = false);
  }

  Future<void> acceptOrder(String id) async {
    final res = await AuthService.acceptOrder(id);
    if (res["success"] == true) {
      getOrders();
    }
  }

  Future<void> readyOrder(String id) async {
    final res = await AuthService.readyOrder(id);
    if (res["success"] == true) {
      getOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF7B61FF),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF7B61FF),
            tabs: const [
              Tab(text: "Active"),
              Tab(text: "Past"),
            ],
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildList(activeOrders, true),
                      _buildList(pastOrders, false),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // =========================
  // COMMON LIST UI
  // =========================
  Widget _buildList(List orders, bool isActive) {
    if (orders.isEmpty) {
      return const Center(child: Text("No Orders"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];

        final orderId = order["orderId"] ?? "";
        final status = (order["orderStatus"] ?? "").toString();

        final user = order["user"] ?? {};
        final items = order["items"] ?? [];

        return Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      orderId,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(status),
                    )
                  ],
                ),

                const SizedBox(height: 10),

                // ================= USER INFO
                Text("👤 ${user["name"] ?? "Unknown"}"),
                Text("📞 ${user["phone"] ?? ""}"),
                Text("📧 ${user["email"] ?? ""}"),

                const Divider(),

                // ================= ITEMS
                const Text(
                  "Items:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),

                ...items.map<Widget>((item) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "${item["foodName"]} x${item["quantity"]}",
                        ),
                      ),
                      Text("₹${item["price"]}"),
                    ],
                  );
                }).toList(),

                const SizedBox(height: 10),

                Text(
                  "Total: ₹${order["totalAmount"]}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                // ================= BUTTONS
                if (isActive)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (status.toLowerCase() == "pending")
                        ElevatedButton(
                          onPressed: () => acceptOrder(order["_id"]),
                          child: const Text("Accept"),
                        )
                      else if (status.toLowerCase() == "preparing")
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () => readyOrder(order["_id"]),
                          child: const Text("Mark Ready"),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}