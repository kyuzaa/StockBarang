import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String image;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.stock,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "price": price,
      "image": image,
      "stock": stock,
    };
  }

  factory Product.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: data["id"]??"",
      name: data["name"] ?? "Tanpa Nama",
      price: (data["price"] ?? 0).toDouble(),
      image: data["image"] ?? "",
      stock: data["stock"] ?? 0,
    );
  }

}
