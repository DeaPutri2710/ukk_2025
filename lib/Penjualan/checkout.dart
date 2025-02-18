import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class COpage extends StatefulWidget {
  const COpage({super.key});

  @override
  State<COpage> createState() => _COpageState();
}

class _COpageState extends State<COpage> {
  final SingleValueDropDownController nameController =
      SingleValueDropDownController();
  final SingleValueDropDownController produkController =
      SingleValueDropDownController();
  final TextEditingController quantityController = TextEditingController();
  List<Map<String, dynamic>> myproduct = [];
  List<Map<String, dynamic>> user = [];
  List<Map<String, dynamic>> cart = [];
  
  takeProduct() async {
    var product = await Supabase.instance.client.from('produk').select();
    setState(() {
      myproduct = product;
    });
  }

  takePelanggan() async {
    var pelanggan = await Supabase.instance.client.from('pelanggan').select();
    setState(() {
      user = pelanggan;
    });
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
        cart.add({
          "ProdukID": selectedProduct["ProdukID"],
          "NamaProduk": selectedProduct["NamaProduk"],
          "Harga": selectedProduct["Harga"],
          "Stok": selectedProduct["Stok"],
          "Jumlah": quantity,
          "Subtotal": (selectedProduct["Harga"] * quantity).toInt()
        });
      });
    }
  }

  void executeSales() async {
  if (cart.isEmpty || nameController.dropDownValue == null) return;

  var pelangganID = nameController.dropDownValue!.value["PelangganID"];
  num totalHarga = cart.fold(0, (sum, item) => sum + item["Subtotal"]);

  var response = await Supabase.instance.client
      .from('penjualan')
      .insert({
        "PelangganID": pelangganID,
        "TotalHarga": totalHarga,
      })
      .select()
      .maybeSingle();

  if (response != null) {
    final penjualan = response;
    for (var item in cart) {
      await Supabase.instance.client.from('detailpenjualan').insert({
        "PenjualanID": penjualan["PenjualanID"],
        "ProdukID": item["ProdukID"],
        "JumlahProduk": item["Jumlah"],
        "Subtotal": item["Subtotal"],
        "Stok": item["Stok"]
      });

      // Update stok produk
      await Supabase.instance.client.from('produk').update({
        'Stok': item["Stok"] - item["Jumlah"]
      }).eq('ProdukID', item["ProdukID"]);
    }

    setState(() {
      cart.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Penjualan Berhasil Ditambahkan')),
    );
    Navigator.pop(context, true);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal Menambahkan Penjualan')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropDownTextField(
              dropDownList: user.map((u) => DropDownValueModel(name: u['NamaPelanggan'], value: u)).toList(),
              controller: nameController,
              textFieldDecoration: InputDecoration(labelText: "Select User"),
              onChanged: (value) {setState(() {});},
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
                itemCount: cart.length,
                itemBuilder: (context, index) {
                  final item = cart[index];
                  return ListTile(
                    title: Text(item["NamaProduk"]),
                    subtitle: Text("Jumlah: ${item["Jumlah"]}, Subtotal: ${item["Subtotal"]}"),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: executeSales,
              child: const Text('Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}