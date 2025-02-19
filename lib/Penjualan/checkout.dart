import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk/detail/strukpenjualan.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: COpage(cart: [], totalHarga: 0),
    );
  }
}

class COpage extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  num totalHarga;

  COpage({required this.cart, required this.totalHarga});

  @override
  State<COpage> createState() => _COpageState();
}

class _COpageState extends State<COpage> {
  final SingleValueDropDownController nameController = SingleValueDropDownController();
  final SingleValueDropDownController produkController = SingleValueDropDownController();
  final TextEditingController quantityController = TextEditingController();
  List<Map<String, dynamic>> myproduct = [];
  List<Map<String, dynamic>> user = [];

  takeProduct() async {
    var product = await Supabase.instance.client.from('produk').select();
    if (product != null && product.isNotEmpty) {
      setState(() {
        myproduct = List<Map<String, dynamic>>.from(product);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Tidak ada produk tersedia'),
      ));
    }
  }

  takePelanggan() async {
    var pelanggan = await Supabase.instance.client.from('pelanggan').select();
    if (pelanggan != null && pelanggan.isNotEmpty) {
      setState(() {
        user = List<Map<String, dynamic>>.from(pelanggan);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Tidak ada data pelanggan'),
      ));
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    takeProduct();
    takePelanggan();
  }

  void showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tambah Produk'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropDownTextField(
                dropDownList: myproduct
                    .map((p) => DropDownValueModel(name: p['NamaProduk'], value: p))
                    .toList(),
                controller: produkController,
                textFieldDecoration: InputDecoration(labelText: "Pilih Produk"),
              ),
              TextField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: quantityController,
                decoration: InputDecoration(labelText: 'Jumlah'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Kembali'),
            ),
            ElevatedButton(
              onPressed: () {
                addProductToCart();
                Navigator.pop(context);
              },
              child: Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  void addProductToCart() {
    final selectedProduct = produkController.dropDownValue?.value;
    final int quantity = int.tryParse(quantityController.text) ?? 0;

    if (selectedProduct != null && quantity > 0) {
      setState(() {
        widget.cart.add({
          "ProdukID": selectedProduct["ProdukID"],
          "NamaProduk": selectedProduct["NamaProduk"],
          "Harga": selectedProduct["Harga"],
          "Stok": selectedProduct["Stok"],
          "Jumlah": quantity,
          "Subtotal": (selectedProduct["Harga"] * quantity).toInt()
        });
        widget.totalHarga += selectedProduct["Harga"] * quantity;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Checkout Page")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropDownTextField(
              dropDownList: user
                  .map((u) => DropDownValueModel(name: u['NamaPelanggan'], value: u))
                  .toList(),
              controller: nameController,
              textFieldDecoration: InputDecoration(labelText: "Select User"),
              onChanged: (value) {
                setState(() {});
              },
            ),
            if (nameController.dropDownValue != null) ...[
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: showAddProductDialog,
                child: Text('Tambah Produk'),
              ),
            ],
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: widget.cart.length,
                itemBuilder: (context, index) {
                  final item = widget.cart[index];
                  return ListTile(
                    title: Text(item["NamaProduk"]),
                    subtitle: Text(
                        "Jumlah: ${item["Jumlah"]}, Subtotal: ${item["Subtotal"]}"),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (nameController.dropDownValue != null) {
                  final user = nameController.dropDownValue?.value;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPenjualanPage(
                        cart: widget.cart,
                        totalHarga: widget.totalHarga,
                        user: user!,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Pilih pengguna terlebih dahulu")),
                  );
                }
              },
              child: const Text('Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}

// // class DetailPenjualanPage extends StatelessWidget {
// //   final List<Map<String, dynamic>> cart;
// //   final num totalHarga;
// //   final Map<String, dynamic> user;

// //   DetailPenjualanPage({
// //     required this.cart,
// //     required this.totalHarga,
// //     required this.user,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text("Struk Penjualan")),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [  

// //             Text("Nama Pelanggan: ${user['NamaPelanggan']}", style: TextStyle(fontSize: 16)),
// //             Text("Alamat: ${user['Alamat']}", style: TextStyle(fontSize: 16)),
// //             SizedBox(height: 20),
            
// //             Expanded(
// //               child: ListView.builder(
// //                 itemCount: cart.length,
// //                 itemBuilder: (context, index) {
// //                   final item = cart[index];
// //                   return Card(
// //                     margin: EdgeInsets.only(bottom: 10),
// //                     child: ListTile(
// //                       title: Text(item["NamaProduk"]),
// //                       subtitle: Text("Jumlah: ${item['Jumlah']}, Subtotal: ${item['Subtotal']}"),
// //                     ),
// //                   );
// //                 },
// //               ),
// //             ),
// //             SizedBox(height: 20),

// //             Text("Total Harga: $totalHarga", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

// //             SizedBox(height: 20),
// //             ElevatedButton(
// //               onPressed: () {
// //                 saveTransaction();
// //                 Navigator.pop(context);
// //               },
// //               child: Text("Simpan Transaksi"),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   void saveTransaction() {
    
// //     print("Transaksi Disimpan:");
// //     print("User: ${user['NamaPelanggan']}");
// //     print("Total Harga: $totalHarga");
// //     print("Cart Items: $cart");
// //   }
// }
