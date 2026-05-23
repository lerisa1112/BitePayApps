import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../model/vendormodel.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<VendorModel> vendors = [];
  bool isLoading = true;

  VendorModel? selectedVendor;
  Map<String, int> cart = {};
  bool isOrderConfirmed = false;

  TimeOfDay? pickupTime;
  bool isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    loadVendors();
  }

  Future<void> loadVendors() async {
    final res = await AuthService.getAllVendorsWithMenu();
    setState(() {
      vendors = res;
      isLoading = false;
    });
  }

  double get totalBill {
    double total = 0;
    if (selectedVendor == null) return 0;

    final menu = selectedVendor!.menuItems;

    for (var e in cart.entries) {
      final item = menu.firstWhere((i) => i.id == e.key);
      total += item.price * e.value;
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (isOrderConfirmed) return _successScreen();

    return Scaffold(
      body: Stack(
        children: [
          selectedVendor == null ? _vendorList() : _menuView(),
          if (cart.isNotEmpty) _cartBar(),
        ],
      ),
    );
  }

  // ================= VENDOR LIST =================
 Widget _vendorList() {
  return ListView.builder(
    padding: const EdgeInsets.all(12),
    itemCount: vendors.length,
    itemBuilder: (context, index) {
      final v = vendors[index];

      return GestureDetector(
        onTap: () {
          setState(() {
            selectedVendor = v;
            cart.clear();
          });
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [

              /// ICON BOX (LEFT)
              Container(
                height: 55,
                width: 55,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.deepPurple, Colors.purple],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.store,
                  color: Colors.white,
                  size: 28,
                ),
              ),

              const SizedBox(width: 12),

              /// DETAILS
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// NAME
                    Text(
                      v.canteenName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    /// ADDRESS
                    Text(
                      v.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// BADGE ROW (UI TOUCH)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Open",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Fast Service",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// ARROW
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      );
    },
  );
}

  // ================= MENU =================
Widget _menuView() {
  final vendor = selectedVendor!;
  final menu = vendor.menuItems;

  return Column(
    children: [

      /// ================= APP BAR =================
      Container(
        padding: const EdgeInsets.only(
          top: 25,
          left: 15,
          right: 15,
          bottom: 15,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          ),
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        child: Row(
          children: [

            /// BACK BUTTON
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedVendor = null;
                  cart.clear();
                  pickupTime = null;
                });
              },
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
            ),

            const SizedBox(width: 10),

            /// TITLE
            Expanded(
              child: Text(
                vendor.canteenName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const Icon(
              Icons.storefront,
              color: Colors.white,
            ),
          ],
        ),
      ),

      /// ================= MENU LIST =================
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: menu.length,
          itemBuilder: (context, index) {
            final item = menu[index];
            final qty = cart[item.id] ?? 0;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),

              child: Row(
                children: [

                  /// FOOD ICON
                  Container(
                    height: 65,
                    width: 65,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.fastfood,
                      color: Colors.grey,
                      size: 30,
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// NAME + PRICE
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          "₹${item.price}",
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// ================= ADD / COUNTER =================
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: qty == 0
                        ? ElevatedButton(
                            key: ValueKey("add_$index"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                cart[item.id] = 1;
                              });
                            },
                            child: const Text("ADD"),
                          )
                        : Container(
                            key: ValueKey("counter_$index"),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF7F00FF),
                                  Color(0xFFE100FF),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [

                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (qty == 1) {
                                        cart.remove(item.id);
                                      } else {
                                        cart[item.id] = qty - 1;
                                      }
                                    });
                                  },
                                  child: const Icon(
                                    Icons.remove,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Text(
                                  "$qty",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(width: 10),

                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      cart[item.id] = qty + 1;
                                    });
                                  },
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ],
  );
}

  // ================= CART BAR =================
 Widget _cartBar() {
  return Positioned(
    bottom: 15,
    left: 15,
    right: 15,
    child: GestureDetector(
      onTap: _showCart,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF6A11CB), // dark premium black-purple
              Color(0xFF2575FC), // soft grey purple
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            /// LEFT INFO
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "₹$totalBill",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "${cart.length} Items in cart",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            /// RIGHT BUTTON STYLE
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF7F00FF),
                    Color(0xFFE100FF),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "VIEW CART",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  // ================= CART =================
  void _showCart() {
  final menu = selectedVendor!.menuItems;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 14,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                /// HANDLE
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "Your Cart",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                /// EMPTY
                if (cart.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(25),
                    child: Column(
                      children: [
                        Icon(Icons.shopping_cart_outlined,
                            size: 60, color: Colors.grey),
                        SizedBox(height: 10),
                        Text("Cart is empty"),
                      ],
                    ),
                  )
                else
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: cart.entries.map((e) {
                        final item =
                            menu.firstWhere((i) => i.id == e.key);

                        return Dismissible(
                          key: ValueKey(e.key),

                          direction: DismissDirection.endToStart,

                          onDismissed: (_) {
                            setState(() {
                              cart.remove(e.key);
                            });

                            setModalState(() {}); // 🔥 important fix

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Item removed"),
                              ),
                            );
                          },

                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),

                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "₹${item.price} x ${e.value}",
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF7F00FF),
                                        Color(0xFFE100FF),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "${e.value}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Text(
                                  "₹${item.price * e.value}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                const SizedBox(height: 12),

                /// PICKUP TIME
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Pickup Time",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextButton(
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );

                        if (time != null) {
                          setState(() => pickupTime = time);
                          setModalState(() {});
                        }
                      },
                      child: Text(
                        pickupTime == null
                            ? "Select"
                            : pickupTime!.format(context),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// TOTAL
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF7F00FF),
                        Color(0xFFE100FF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    "TOTAL ₹$totalBill",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                /// CHECKOUT BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    onPressed: isPlacingOrder
                        ? null
                        : () async {

                            if (cart.isEmpty) return;
                            if (pickupTime == null) return;

                            setModalState(() {
                              isPlacingOrder = true;
                            });

                            final items = cart.entries.map((e) {
                              final item = selectedVendor!.menuItems
                                  .firstWhere((i) => i.id == e.key);

                              return {
                                "foodName": item.name,
                                "quantity": e.value,
                                "price": item.price,
                              };
                            }).toList();

                            final res = await AuthService.createOrder(
                              vendorId: selectedVendor!.id,
                              items: items,
                              totalAmount: totalBill,
                              pickupTime: pickupTime!.format(context),
                            );

                            setModalState(() {
                              isPlacingOrder = false;
                            });

                            /// 🔥 FINAL SUCCESS FIX
                            if (res["success"] == true ||
                                res["order"] != null) {

                              Navigator.pop(sheetContext);

                              setState(() {
                                cart.clear();
                                pickupTime = null;
                                isOrderConfirmed = true;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("🎉 Order placed successfully"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },

                    child: isPlacingOrder
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text("CONFIRM ORDER"),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

  // ================= SUCCESS =================
  Widget _successScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle,
                size: 100, color: Colors.green),
            const SizedBox(height: 10),
            const Text("Order Placed Successfully!"),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  isOrderConfirmed = false;
                  selectedVendor = null;
                  cart.clear();
                  pickupTime = null;
                });
              },
              child: const Text("Order More"),
            )
          ],
        ),
      ),
    );
  }
}