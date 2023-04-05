import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class Product {
  String? id;
  String? name;
  int? price;
  Timestamp? createdAt;
  Timestamp? updatedAt;

//Constructor
  Product({
    this.id,
    this.name,
    this.price,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(String id, Map<String, dynamic> json) {
    return Product(
      id: id,
      name: json['name'],
      price: json['price'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (price != null) 'price': price,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }
}
