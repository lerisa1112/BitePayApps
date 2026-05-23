import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class OrdersScreen extends StatefulWidget {

  const OrdersScreen({
    super.key,
  });

  @override
  State<OrdersScreen> createState() =>
      _OrdersScreenState();

}

class _OrdersScreenState
    extends State<OrdersScreen> {

  bool isLoading = true;

  List<dynamic> activeOrders = [];

  List<dynamic> historyOrders = [];

  @override
  void initState() {

    super.initState();

    fetchOrders();

  }

  // ================= FETCH ORDERS =================

  Future<void> fetchOrders() async {

    try {

      final userId =
          await AuthService.getUserId();

      if (userId == null) {

        setState(() {
          isLoading = false;
        });

        return;
      }

      final res =
          await AuthService.getOrdersByUser(
        userId,
      );

      debugPrint(
        "USER ORDERS => $res",
      );

      if (res["success"] == true) {

        final List orders =
            res["orders"] ?? [];

        activeOrders =
            orders.where((order) {

          final status =
              order["orderStatus"] ?? "";

          return status != "Completed" &&
              status != "Cancelled";

        }).toList();

        historyOrders =
            orders.where((order) {

          final status =
              order["orderStatus"] ?? "";

          return status == "Completed" ||
              status == "Cancelled";

        }).toList();
      }

      setState(() {
        isLoading = false;
      });

    } catch (e) {

      debugPrint(
        "FETCH ORDER ERROR => $e",
      );

      setState(() {
        isLoading = false;
      });

    }

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

    return DefaultTabController(

      length: 2,

      child: Scaffold(

        appBar: PreferredSize(

          preferredSize:
              const Size.fromHeight(50),

          child: AppBar(

            bottom: const TabBar(

              indicatorColor:
                  Color(0xFF9370DB),

              labelColor:
                  Color(0xFF9370DB),

              unselectedLabelColor:
                  Colors.grey,

              tabs: [

                Tab(
                  text: "Active Orders",
                ),

                Tab(
                  text: "Order History",
                ),

              ],

            ),

          ),

        ),

        body: TabBarView(

          children: [

            // ================= ACTIVE ORDERS =================

            activeOrders.isEmpty

                ? const Center(
                    child: Text(
                      "No Active Orders",
                    ),
                  )

                : RefreshIndicator(

                    onRefresh: fetchOrders,

                    child: ListView.builder(

                      padding:
                          const EdgeInsets.all(
                        16,
                      ),

                      itemCount:
                          activeOrders.length,

                      itemBuilder:
                          (context, index) {

                        final order =
                            activeOrders[index];

                        return _orderCard(
                          order,
                          true,
                        );

                      },

                    ),

                  ),

            // ================= HISTORY =================

            historyOrders.isEmpty

                ? const Center(
                    child: Text(
                      "No Order History",
                    ),
                  )

                : RefreshIndicator(

                    onRefresh: fetchOrders,

                    child: ListView.builder(

                      padding:
                          const EdgeInsets.all(
                        16,
                      ),

                      itemCount:
                          historyOrders.length,

                      itemBuilder:
                          (context, index) {

                        final order =
                            historyOrders[index];

                        return _orderCard(
                          order,
                          false,
                        );

                      },

                    ),

                  ),

          ],

        ),

      ),

    );

  }

  // ================= ORDER CARD =================

  Widget _orderCard(
    dynamic order,
    bool isActive,
  ) {

    final vendor =
        order["vendor"];

    final status =
        order["orderStatus"] ?? "";

    final items =
        order["items"] ?? [];

    // ================= FOOD NAMES =================

    String itemText = "";

    if (items is List &&
        items.isNotEmpty) {

      itemText = items.map((item) {

        // IMPORTANT FIX

        final foodName =
            item["foodName"] ??
            item["name"] ??
            "Food";

        final qty =
            item["quantity"] ?? 1;

        return "$foodName x$qty";

      }).join(", ");

    }

    Color statusColor =
        status == "Ready"
            ? Colors.green
            : status == "Cancelled"
                ? Colors.red
                : status == "Completed"
                    ? Colors.blue
                    : Colors.orange;

    return Card(

      margin:
          const EdgeInsets.only(
        bottom: 16,
      ),

      shape: RoundedRectangleBorder(

        borderRadius:
            BorderRadius.circular(15),

      ),

      elevation: 3,

      child: Padding(

        padding:
            const EdgeInsets.all(15),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // ================= TOP =================

            Row(

              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

              children: [

                Expanded(

                  child: Text(

                    vendor != null
                        ? vendor["canteenName"] ??
                            "Food Order"
                        : "Food Order",

                    style:
                        const TextStyle(

                      fontWeight:
                          FontWeight.bold,

                      fontSize: 16,

                    ),

                  ),

                ),

                Container(

                  padding:
                      const EdgeInsets.symmetric(

                    horizontal: 8,
                    vertical: 4,

                  ),

                  decoration: BoxDecoration(

                    color:
                        statusColor.withOpacity(
                      0.1,
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      8,
                    ),

                  ),

                  child: Text(

                    status,

                    style: TextStyle(

                      color: statusColor,

                      fontWeight:
                          FontWeight.bold,

                      fontSize: 12,

                    ),

                  ),

                ),

              ],

            ),

            const Divider(
              height: 20,
            ),

            // ================= FOOD ITEMS =================

            Text(

              itemText.isEmpty
                  ? "No Items"
                  : itemText,

              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),

            ),

            const SizedBox(
              height: 10,
            ),

            // ================= ORDER ID =================

            Text(
              "Order ID: ${order["orderId"] ?? ""}",
            ),

            const SizedBox(
              height: 5,
            ),

            // ================= PRICE =================

            Row(

              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

              children: [

                Text(

                  order["createdAt"] != null

                      ? order["createdAt"]
                          .toString()
                          .substring(0, 10)

                      : "",

                  style:
                      const TextStyle(

                    color: Colors.grey,

                    fontSize: 12,

                  ),

                ),

                Text(

                  "₹${order["totalAmount"] ?? 0}",

                  style:
                      const TextStyle(

                    fontWeight:
                        FontWeight.bold,

                    color:
                        Color(0xFF9370DB),

                  ),

                ),

              ],

            ),

            // ================= QR BUTTON =================

            if (isActive &&
                status == "Ready") ...[

              const SizedBox(
                height: 15,
              ),

              SizedBox(

                width: double.infinity,

                child: ElevatedButton(

                  onPressed: () {

                    final qr =
                        order["qrCode"];

                    if (qr != null &&
                        qr.toString().isNotEmpty) {

                      showDialog(

                        context: context,

                        builder: (context) {

                          return AlertDialog(

                            title: const Text(
                              "QR Code",
                            ),

                            content: Image.network(
                              qr,
                              height: 200,
                            ),

                          );

                        },

                      );

                    }

                  },

                  style:
                      ElevatedButton.styleFrom(

                    backgroundColor:
                        const Color(
                      0xFF9370DB,
                    ),

                    shape:
                        RoundedRectangleBorder(

                      borderRadius:
                          BorderRadius.circular(
                        10,
                      ),

                    ),

                  ),

                  child: const Text(

                    "Show QR Code",

                    style: TextStyle(
                      color: Colors.white,
                    ),

                  ),

                ),

              ),

            ],

          ],

        ),

      ),

    );

  }

}