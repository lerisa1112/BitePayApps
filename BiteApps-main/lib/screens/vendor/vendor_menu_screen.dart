import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class VendorMenuScreen extends StatefulWidget {
  const VendorMenuScreen({super.key});

  @override
  State<VendorMenuScreen> createState() =>
      _VendorMenuScreenState();
}

class _VendorMenuScreenState
    extends State<VendorMenuScreen> {

  List<dynamic> menuItems = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMenu();
  }

  // =========================
  // LOAD MENU
  // =========================

  Future<void> loadMenu() async {

    try {

      final response =
          await AuthService.getMyMenu();

      debugPrint(
        "MENU RESPONSE => $response",
      );

      if (response["success"] == true) {

        setState(() {

          menuItems =
              response["menuItems"] ?? [];

          isLoading = false;

        });

      } else {

        setState(() {
          isLoading = false;
        });

      }

    } catch (e) {

      debugPrint(
        "MENU ERROR => $e",
      );

      setState(() {
        isLoading = false;
      });

    }

  }

  // =========================
  // ADD ITEM BOTTOM SHEET
  // =========================

  void _showAddItemBottomSheet() {

    showModalBottomSheet(

      context: context,

      isScrollControlled: true,

      shape:
          const RoundedRectangleBorder(

        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(25),
        ),

      ),

      builder: (context) {

        return AddItemForm(

          onItemAdded: () {

            loadMenu();

          },

        );

      },

    );

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

          : menuItems.isEmpty

              ? const Center(
                  child: Text(
                    "No Menu Items Found",
                  ),
                )

              : ListView.builder(

                  padding:
                      const EdgeInsets.all(
                    12,
                  ),

                  itemCount:
                      menuItems.length,

                  itemBuilder:
                      (context, index) {

                    final item =
                        menuItems[index];

                    final bool inStock =
                        item["stockStatus"] ==
                            "In Stock";

                    return Container(

                      margin:
                          const EdgeInsets.symmetric(
                        vertical: 6,
                      ),

                      padding:
                          const EdgeInsets.all(
                        10,
                      ),

                      decoration:
                          BoxDecoration(

                        color:
                            Colors.grey[100],

                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),

                      ),

                      child: Row(

                        children: [

                          ClipRRect(

                            borderRadius:
                                BorderRadius.circular(
                              10,
                            ),

                            child: Image.network(

                              item["image"] ?? "",

                              width: 70,
                              height: 70,

                              fit: BoxFit.cover,

                              errorBuilder:
                                  (
                                context,
                                error,
                                stackTrace,
                              ) {

                                return Container(

                                  width: 70,
                                  height: 70,

                                  color: Colors.grey
                                      .shade300,

                                  child: const Icon(
                                    Icons.fastfood,
                                  ),

                                );

                              },

                            ),

                          ),

                          const SizedBox(
                              width: 15),

                          Expanded(

                            child: Column(

                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                Text(

                                  item["foodName"] ??
                                      "",

                                  style:
                                      const TextStyle(

                                    fontWeight:
                                        FontWeight.bold,

                                    fontSize: 16,

                                  ),

                                ),

                                const SizedBox(
                                    height: 5),

                                Text(

                                  "₹${item["price"]}",

                                  style:
                                      const TextStyle(

                                    color: Color(
                                      0xFF9370DB,
                                    ),

                                    fontWeight:
                                        FontWeight.bold,

                                  ),

                                ),

                                const SizedBox(
                                    height: 5),

                                Text(

                                  item["description"] ??
                                      "",

                                  maxLines: 2,

                                  overflow:
                                      TextOverflow
                                          .ellipsis,

                                  style:
                                      const TextStyle(

                                    color:
                                        Colors.grey,

                                    fontSize: 12,

                                  ),

                                ),

                              ],

                            ),

                          ),

                          Column(

                            children: [

                              Text(

                                inStock
                                    ? "In Stock"
                                    : "Out Of Stock",

                                style: TextStyle(

                                  fontSize: 12,

                                  color: inStock
                                      ? Colors.green
                                      : Colors.red,

                                ),

                              ),

                              Switch(

                                value: inStock,

                                activeColor:
                                    const Color(
                                  0xFF9370DB,
                                ),

                                onChanged:
                                    (val) async {

                                  final response =
                                      await AuthService
                                          .updateMenuStock(

                                    menuId:
                                        item["_id"],

                                    stockStatus:
                                        val
                                            ? "In Stock"
                                            : "Out Of Stock",

                                  );

                                  if (response[
                                          "success"] ==
                                      true) {

                                    loadMenu();

                                  } else {

                                    ScaffoldMessenger.of(
                                            context)
                                        .showSnackBar(

                                      const SnackBar(

                                        content: Text(
                                          "Failed To Update Stock",
                                        ),

                                        backgroundColor:
                                            Colors.red,

                                      ),

                                    );

                                  }

                                },

                              ),

                            ],

                          ),

                        ],

                      ),

                    );

                  },

                ),

      floatingActionButton:
          FloatingActionButton(

        backgroundColor:
            const Color(
          0xFF9370DB,
        ),

        onPressed:
            _showAddItemBottomSheet,

        child: const Icon(

          Icons.add,

          color: Colors.white,

        ),

      ),

    );

  }

}

// =========================
// ADD ITEM FORM
// =========================

class AddItemForm extends StatefulWidget {

  final VoidCallback onItemAdded;

  const AddItemForm({

    super.key,

    required this.onItemAdded,

  });

  @override
  State<AddItemForm> createState() =>
      _AddItemFormState();

}

class _AddItemFormState
    extends State<AddItemForm> {

  final _formKey =
      GlobalKey<FormState>();

  final _foodNameController =
      TextEditingController();

  final _priceController =
      TextEditingController();

  final _imageController =
      TextEditingController();

  final _descriptionController =
      TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {

    _foodNameController.dispose();

    _priceController.dispose();

    _imageController.dispose();

    _descriptionController.dispose();

    super.dispose();

  }

  @override
  Widget build(BuildContext context) {

    return Padding(

      padding: EdgeInsets.only(

        top: 20,

        left: 20,

        right: 20,

        bottom:
            MediaQuery.of(context)
                    .viewInsets
                    .bottom +
                20,

      ),

      child: Form(

        key: _formKey,

        child: SingleChildScrollView(

          child: Column(

            mainAxisSize:
                MainAxisSize.min,

            children: [

              const Text(

                "Add New Food Item",

                style: TextStyle(

                  fontSize: 20,

                  fontWeight:
                      FontWeight.bold,

                ),

              ),

              const SizedBox(
                  height: 20),

              TextFormField(

                controller:
                    _foodNameController,

                decoration:
                    InputDecoration(

                  labelText:
                      "Food Name",

                  prefixIcon:
                      const Icon(
                    Icons.fastfood,
                  ),

                  border:
                      OutlineInputBorder(

                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),

                  ),

                ),

                validator: (val) {

                  if (val == null ||
                      val.trim().isEmpty) {

                    return "Enter Food Name";

                  }

                  return null;

                },

              ),

              const SizedBox(
                  height: 15),

              TextFormField(

                controller:
                    _priceController,

                keyboardType:
                    TextInputType.number,

                decoration:
                    InputDecoration(

                  labelText:
                      "Price",

                  prefixIcon:
                      const Icon(
                    Icons.currency_rupee,
                  ),

                  border:
                      OutlineInputBorder(

                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),

                  ),

                ),

                validator: (val) {

                  if (val == null ||
                      val.trim().isEmpty) {

                    return "Enter Price";

                  }

                  return null;

                },

              ),

              const SizedBox(
                  height: 15),

              TextFormField(

                controller:
                    _imageController,

                decoration:
                    InputDecoration(

                  labelText:
                      "Image URL",

                  prefixIcon:
                      const Icon(
                    Icons.image,
                  ),

                  border:
                      OutlineInputBorder(

                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),

                  ),

                ),

                validator: (val) {

                  if (val == null ||
                      val.trim().isEmpty) {

                    return "Enter Image URL";

                  }

                  return null;

                },

              ),

              const SizedBox(
                  height: 15),

              TextFormField(

                controller:
                    _descriptionController,

                maxLines: 3,

                decoration:
                    InputDecoration(

                  labelText:
                      "Description",

                  prefixIcon:
                      const Icon(
                    Icons.description,
                  ),

                  border:
                      OutlineInputBorder(

                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),

                  ),

                ),

                validator: (val) {

                  if (val == null ||
                      val.trim().isEmpty) {

                    return "Enter Description";

                  }

                  return null;

                },

              ),

              const SizedBox(
                  height: 25),

              SizedBox(

                width: double.infinity,

                height: 50,

                child: ElevatedButton(

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
                        12,
                      ),

                    ),

                  ),

                  onPressed: isLoading
                      ? null
                      : () async {

                          if (_formKey
                              .currentState!
                              .validate()) {

                            setState(() {
                              isLoading = true;
                            });

                            final response =
                                await AuthService
                                    .addMenuItem(

                              foodName:
                                  _foodNameController
                                      .text
                                      .trim(),

                              price: int.parse(
                                _priceController
                                    .text
                                    .trim(),
                              ),

                              image:
                                  _imageController
                                      .text
                                      .trim(),

                              description:
                                  _descriptionController
                                      .text
                                      .trim(),

                            );

                            setState(() {
                              isLoading = false;
                            });

                            if (response[
                                    "success"] ==
                                true) {

                              widget
                                  .onItemAdded();

                              Navigator.pop(
                                  context);

                              ScaffoldMessenger.of(
                                      context)
                                  .showSnackBar(

                                const SnackBar(

                                  content: Text(
                                    "Menu Item Added Successfully",
                                  ),

                                  backgroundColor:
                                      Colors.green,

                                ),

                              );

                            } else {

                              ScaffoldMessenger.of(
                                      context)
                                  .showSnackBar(

                                SnackBar(

                                  content: Text(

                                    response["message"] ??
                                        "Failed To Add Item",

                                  ),

                                  backgroundColor:
                                      Colors.red,

                                ),

                              );

                            }

                          }

                        },

                  child: isLoading

                      ? const CircularProgressIndicator(
                          color:
                              Colors.white,
                        )

                      : const Text(

                          "ADD ITEM",

                          style: TextStyle(

                            color:
                                Colors.white,

                            fontWeight:
                                FontWeight.bold,

                            fontSize: 16,

                          ),

                        ),

                ),

              ),

            ],

          ),

        ),

      ),

    );

  }

}