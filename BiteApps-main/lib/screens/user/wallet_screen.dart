import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {

  double balance = 0;

  bool isLoading = true;

  List<dynamic> walletOrders = [];

  final TextEditingController amountController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchWallet();
  }

  // ================= FETCH WALLET =================
  Future<void> fetchWallet() async {

    try {

      final res = await AuthService.getWallet();

      final orderRes =
          await AuthService.getWalletOrders();

      setState(() {

        balance =
            (res["balance"] ?? 0).toDouble();

        if (orderRes["orders"] != null &&
            orderRes["orders"] is List) {

          walletOrders =
              orderRes["orders"];

        } else {

          walletOrders = [];
        }

        isLoading = false;
      });

    } catch (e) {

      setState(() {
        isLoading = false;
        walletOrders = [];
      });
    }
  }

  // ================= ADD MONEY =================
  Future<void> addMoney() async {

    final amount =
        int.tryParse(amountController.text) ?? 0;

    if (amount <= 0) return;

    Navigator.pop(context);

    final res =
        await AuthService.addMoneyToWallet(amount);

    if (res["success"] == true) {

      fetchWallet();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Money Added Successfully"),
        ),
      );

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(res["message"] ?? "Failed"),
        ),
      );
    }
  }

  // ================= STATUS COLOR =================
  Color getStatusColor(String status) {

    switch (status) {

      case "Pending":
        return Colors.orange;

      case "Preparing":
        return Colors.deepOrange;

      case "Ready":
        return Colors.green;

      case "Completed":
        return Colors.blue;

      default:
        return Colors.grey;
    }
  }

  // ================= ADD MONEY SHEET =================
  void _showAddMoneySheet() {

    amountController.clear();

    showModalBottomSheet(

      context: context,

      isScrollControlled: true,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),

      builder: (context) {

        return Padding(

          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context)
                    .viewInsets
                    .bottom,

            top: 20,
            left: 20,
            right: 20,
          ),

          child: Column(

            mainAxisSize: MainAxisSize.min,

            children: [

              const Text(
                "Add Money",

                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              TextField(

                controller: amountController,

                keyboardType:
                    TextInputType.number,

                decoration: InputDecoration(

                  hintText: "Enter Amount",

                  prefixIcon:
                      const Icon(
                    Icons.currency_rupee,
                  ),

                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(

                width: double.infinity,

                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF9370DB),

                    padding:
                        const EdgeInsets.all(14),
                  ),

                  onPressed: addMoney,

                  child:
                      const Text("Add Money"),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {

      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(

      appBar: AppBar(
        title: const Text("Wallet"),
      ),

      body: RefreshIndicator(

        onRefresh: fetchWallet,

        child: SingleChildScrollView(

          physics:
              const AlwaysScrollableScrollPhysics(),

          padding:
              const EdgeInsets.all(16),

          child: Column(

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              // ================= WALLET CARD =================
              Container(

                width: double.infinity,

                padding:
                    const EdgeInsets.all(25),

                decoration: BoxDecoration(

                  gradient:
                      const LinearGradient(
                    colors: [
                      Color(0xFF9370DB),
                      Color(0xFF8A2BE2),
                    ],
                  ),

                  borderRadius:
                      BorderRadius.circular(25),
                ),

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    const Text(
                      "Wallet Balance",

                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "₹$balance",

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ================= ADD MONEY =================
              ElevatedButton.icon(

                onPressed:
                    _showAddMoneySheet,

                icon:
                    const Icon(Icons.add),

                label:
                    const Text("Add Money"),

                style:
                    ElevatedButton.styleFrom(

                  backgroundColor:
                      const Color(0xFF9370DB),

                  padding:
                      const EdgeInsets.all(14),

                  minimumSize:
                      const Size(
                    double.infinity,
                    50,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ================= TRANSACTIONS =================
              const Text(
                "Transactions",

                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              walletOrders.isEmpty

                  ? const Center(
                      child: Padding(
                        padding:
                            EdgeInsets.all(20),
                        child: Text(
                          "No Transactions Yet",
                        ),
                      ),
                    )

                  : ListView.builder(

                      shrinkWrap: true,

                      physics:
                          const NeverScrollableScrollPhysics(),

                      itemCount:
                          walletOrders.length,

                      itemBuilder:
                          (context, index) {

                        final order =
                            walletOrders[index];

                        final items =
                            order["items"] ?? [];

                        String foodNames = "";

                        String qtyText = "";

                        if (items is List &&
                            items.isNotEmpty) {

                          foodNames = items
                              .map((e) =>
                                  e["name"] ?? "")
                              .join(", ");

                          qtyText = items
                              .map((e) =>
                                  "x${e["quantity"]}")
                              .join(", ");
                        }

                        final status =
                            order["orderStatus"] ?? "";

                        return Card(

                          elevation: 3,

                          margin:
                              const EdgeInsets.only(
                            bottom: 14,
                          ),

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),
                          ),

                          child: Padding(

                            padding:
                                const EdgeInsets.all(16),

                            child: Column(

                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                // ================= TOP =================
                                Row(

                                  children: [

                                    const CircleAvatar(

                                      radius: 24,

                                      backgroundColor:
                                          Color(
                                        0xFF9370DB,
                                      ),

                                      child: Icon(
                                        Icons.fastfood,
                                        color:
                                            Colors
                                                .white,
                                      ),
                                    ),

                                    const SizedBox(
                                        width: 12),

                                    Expanded(

                                      child: Column(

                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,

                                        children: [

                                          Text(

                                            order["vendor"] !=
                                                    null
                                                ? order["vendor"]
                                                            [
                                                            "canteenName"] ??
                                                        "Food Order"
                                                : "Food Order",

                                            style:
                                                const TextStyle(
                                              fontWeight:
                                                  FontWeight
                                                      .bold,

                                              fontSize:
                                                  17,
                                            ),
                                          ),

                                          const SizedBox(
                                              height:
                                                  4),

                                          Text(
                                            "Order ID: ${order["orderId"] ?? ""}",
                                          ),
                                        ],
                                      ),
                                    ),

                                    Text(
                                      "- ₹${order["totalAmount"] ?? 0}",

                                      style:
                                          const TextStyle(
                                        color:
                                            Colors.red,

                                        fontWeight:
                                            FontWeight
                                                .bold,

                                        fontSize:
                                            18,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                    height: 18),

                                // ================= FOOD BOX =================
                                Container(

                                  width:
                                      double.infinity,

                                  padding:
                                      const EdgeInsets
                                          .all(14),

                                  decoration:
                                      BoxDecoration(

                                    color: Colors
                                        .grey
                                        .shade100,

                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      14,
                                    ),
                                  ),

                                  child: Column(

                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,

                                    children: [

                                      const Text(

                                        "Food Items",

                                        style:
                                            TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .bold,

                                          fontSize:
                                              15,
                                        ),
                                      ),

                                      const SizedBox(
                                          height:
                                              10),

                                      Text(
                                        foodNames,
                                        style:
                                            const TextStyle(
                                          fontSize:
                                              14,
                                        ),
                                      ),

                                      const SizedBox(
                                          height:
                                              8),

                                      Text(
                                        "Quantity: $qtyText",
                                      ),

                                      const SizedBox(
                                          height:
                                              14),

                                      // ================= STATUS BADGE =================
                                      Container(

                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal:
                                              14,
                                          vertical:
                                              8,
                                        ),

                                        decoration:
                                            BoxDecoration(

                                          color:
                                              getStatusColor(
                                                  status),

                                          borderRadius:
                                              BorderRadius.circular(
                                            30,
                                          ),
                                        ),

                                        child: Text(

                                          status,

                                          style:
                                              const TextStyle(
                                            color:
                                                Colors
                                                    .white,

                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}