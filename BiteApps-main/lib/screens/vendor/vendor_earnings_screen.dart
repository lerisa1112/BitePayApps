import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class VendorEarningsScreen extends StatefulWidget {
  const VendorEarningsScreen({super.key});

  @override
  State<VendorEarningsScreen> createState() =>
      _VendorEarningsScreenState();
}

class _VendorEarningsScreenState
    extends State<VendorEarningsScreen> {

  bool isLoading = true;

  double totalRevenue = 0;

  int completedOrders = 0;

  List recentTransactions = [];

  @override
  void initState() {

    super.initState();

    loadDashboard();

  }

  // =========================
  // LOAD DASHBOARD
  // =========================

  Future<void> loadDashboard() async {

    try {

      final response =
          await AuthService
              .getVendorDashboard();

      if (response["success"] == true) {

        setState(() {

          totalRevenue =
              (response["totalRevenue"] ?? 0)
                  .toDouble();

          completedOrders =
              response["completedOrders"] ?? 0;

          recentTransactions =
              response["recentTransactions"] ?? [];

          isLoading = false;

        });

      } else {

        setState(() {
          isLoading = false;
        });

      }

    } catch (e) {

      debugPrint(
        "DASHBOARD ERROR => $e",
      );

      setState(() {
        isLoading = false;
      });

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      body: isLoading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : Padding(

              padding:
                  const EdgeInsets.all(16),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const Text(

                    "Sales Overview",

                    style: TextStyle(

                      fontSize: 18,

                      fontWeight:
                          FontWeight.bold,

                    ),

                  ),

                  const SizedBox(
                      height: 15),

                  // ======================
                  // CARDS
                  // ======================

                  Row(

                    children: [

                      Expanded(

                        child: _buildStatCard(

                          "Today's Revenue",

                          "₹${totalRevenue.toStringAsFixed(0)}",

                          Icons.attach_money,

                          Colors.green,

                        ),

                      ),

                      const SizedBox(
                          width: 12),

                      Expanded(

                        child: _buildStatCard(

                          "Orders Completed",

                          completedOrders
                              .toString(),

                          Icons.done_all,

                          Colors.blue,

                        ),

                      ),

                    ],

                  ),

                  const SizedBox(
                      height: 25),

                  const Text(

                    "Recent Transactions",

                    style: TextStyle(

                      fontSize: 18,

                      fontWeight:
                          FontWeight.bold,

                    ),

                  ),

                  const SizedBox(
                      height: 10),

                  Expanded(

                    child:
                        recentTransactions
                                .isEmpty

                            ? const Center(

                                child: Text(
                                  "No Transactions Found",
                                ),

                              )

                            : ListView.builder(

                                itemCount:
                                    recentTransactions
                                        .length,

                                itemBuilder:
                                    (
                                  context,
                                  index,
                                ) {

                                  final transaction =
                                      recentTransactions[
                                          index];

                                  return ListTile(

                                    leading:
                                        CircleAvatar(

                                      backgroundColor:
                                          Colors.green
                                              .withOpacity(
                                        0.1,
                                      ),

                                      child:
                                          const Icon(

                                        Icons
                                            .arrow_downward,

                                        color:
                                            Colors.green,

                                      ),

                                    ),

                                    title: Text(

                                      transaction[
                                              "title"] ??
                                          "Payment Received",

                                    ),

                                    subtitle: Text(

                                      transaction[
                                              "paymentMethod"] ??
                                          "Wallet Payment",

                                    ),

                                    trailing:
                                        Text(

                                      "+₹${transaction["amount"] ?? 0}",

                                      style:
                                          const TextStyle(

                                        fontWeight:
                                            FontWeight.bold,

                                        color:
                                            Colors.green,

                                      ),

                                    ),

                                  );

                                },

                              ),

                  ),

                ],

              ),

            ),

    );

  }

  // =========================
  // STAT CARD
  // =========================

  Widget _buildStatCard(

    String title,
    String value,
    IconData icon,
    Color color,

  ) {

    return Container(

      padding:
          const EdgeInsets.all(20),

      decoration: BoxDecoration(

        color:
            color.withOpacity(0.1),

        borderRadius:
            BorderRadius.circular(15),

      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Icon(

            icon,

            color: color,

            size: 30,

          ),

          const SizedBox(
              height: 15),

          Text(

            title,

            style: const TextStyle(

              color: Colors.grey,

              fontSize: 14,

            ),

          ),

          Text(

            value,

            style: TextStyle(

              fontSize: 24,

              fontWeight:
                  FontWeight.bold,

              color: color,

            ),

          ),

        ],

      ),

    );

  }

}