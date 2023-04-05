import 'package:crud_firestore/models/product.dart';
import 'package:crud_firestore/services/firestore_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = true;

  void _BottomSheet(bool isUpdate, {Product? product}) {
    if (isUpdate) {
      _nameController.text = product!.name!;
      _priceController.text = product!.price.toString();
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              top: 15,
              left: 15,
              right: 15,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(isUpdate ? 'Update ${product!.name}' :'Create Product'),
                SizedBox(height: 10),
                TextFormField(
                  controller: _nameController,
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return 'Nama Product Tidak Boleh Kosong';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: 'Buku',
                      labelText: 'Nama Product'),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return 'Nama Product Tidak Boleh Kosong';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: '4000',
                      labelText: 'Harga Product'),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Tutup Bottom Sheet
                      Navigator.of(context).pop();
                      // Sedang Loading
                      setState(() {
                        isLoading = true;
                      });
                      if (isUpdate) {
                        await FirestoreService.updateProduct(
                            id: product!.id!,
                            name: _nameController.text,
                            price: _priceController.text);
                      } else {
                        // Trigger Servicenya dan kirim data name sama price
                        await FirestoreService.createProduct(
                          name: _nameController.text,
                          price: _priceController.text,
                        );
                        // Hapus Ketikan di Textfield
                        _nameController.clear();
                        _priceController.clear();
                      }
                      // Loading Selesai
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  icon: Icon(Icons.save),
                  label: Text('Simpan'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    FirestoreService.getProducts().then((_) {
      setState(() {
        isLoading = false;
      });
    }).onError((_, __) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          _BottomSheet(false);
        },
        child: Icon(Icons.add),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        title: Text('CRUD Firestore'),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : FutureBuilder(
              future: FirestoreService.getProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    final List<Product> listData = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ListView.separated(
                        itemBuilder: (context, index) {
                          final product = listData[index];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('${product.name}'),
                                  Text('Rp ${product.price}'),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.amber,
                                        ),
                                        onPressed: () {
                                          _BottomSheet(true, product: product);
                                        },
                                        icon: Icon(Icons.edit),
                                        label: Text('Edit'),
                                      ),
                                      const SizedBox(width: 10),
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        onPressed: () async {
                                          setState(() {
                                            // True buat ngerubah UI
                                            isLoading = true;
                                          });
                                          await FirestoreService.deleteProduct(
                                              id: product.id!);
                                          setState(() {
                                            isLoading = false;
                                          });
                                        },
                                        icon: Icon(Icons.delete),
                                        label: Text('Delete'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return SizedBox(height: 10);
                        },
                        itemCount: listData.length,
                      ),
                    );
                  }
                }

                return const SizedBox.shrink();
              },
            ),
    );
  }
}
