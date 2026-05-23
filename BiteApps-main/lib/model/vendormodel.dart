class MenuItemModel {
  final String id;
  final String name;
  final int price;
  final String image;
  final String description;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json["_id"],
      name: json["foodName"] ?? "",
      price: json["price"] ?? 0,
      image: json["image"] ?? "",
      description: json["description"] ?? "",
    );
  }
}

class VendorModel {
  final String id;
  final String canteenName;
  final String address;
  final List<MenuItemModel> menuItems;

  VendorModel({
    required this.id,
    required this.canteenName,
    required this.address,
    required this.menuItems,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      id: json["vendor"]["_id"],
      canteenName: json["vendor"]["canteenName"] ?? "",
      address: json["vendor"]["canteenLocation"] ?? "",
      menuItems: (json["menuItems"] as List)
          .map((e) => MenuItemModel.fromJson(e))
          .toList(),
    );
  }
}