import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_firestore/models/product.dart';

class FirestoreService {
  static final _collection = FirebaseFirestore.instance.collection('products');

  static Future<void> createProduct(
      {required String name, required String price}) async {
    try {
      final data = {
        'name': name,
        'price': int.parse(price),
        // created_at sama update_at nya dibuat beda karena udah d bikin d Firestore
        'created_at': FieldValue.serverTimestamp(),
        'update_at': FieldValue.serverTimestamp(),
      };
      await _collection.add(data);
      // Setelah ditambahin ktia Refresh datanya
      await getProducts();
    } on FirebaseException catch (e) {
      log('Error $e');
    }
  }

  static Future<List<Product>?> getProducts() async {
    try {
      final dataCollection = await _collection.get();
      final listData = dataCollection.docs;
      final List<Product> products = [];
      
      for (var element in listData) {
        final json = element.data();
        products.add(Product.fromJson(element.id, json));

        log(element.id);
        log(json.toString());
      }
      log(products.length.toString());
      return products;
    } on FirebaseException catch (e) {
      return null;
    }
  }
  static Future<void> deleteProduct({
  required String id,
}) async {
    try {
      // Cari Product
      final product = _collection.doc(id);

      // Delete d DB
      await product.delete();

      // Refresh List
      await getProducts();
    } catch (e) {
      log(e.toString());
    }
  }
  static Future<void> updateProduct({
  required String id,
  required String name,
  required String price,
}) async {
    try {
      final product = _collection.doc(id);
      final Map<String, dynamic> data = {
        'name' : name,
        'price' : int.parse(price),
        'updated_at' : FieldValue.serverTimestamp(),
      };
      await product.update(data);
      await getProducts();
    } on FirebaseException catch (e) {
      log(e.toString());
    }
  }
}
