import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Insertpenjualan extends StatefulWidget {
  const Insertpenjualan({super.key});

  @override
  State<Insertpenjualan> createState() => _InsertpenjualanState();
}

class _InsertpenjualanState extends State<Insertpenjualan> {
    final SingleValueDropDownController nameController =
        SingleValueDropDownController();
    final SingleValueDropDownController produkController =
        SingleValueDropDownController();
    final SingleValueDropDownController quantityController = TextEditingController() as SingleValueDropDownController;
    List myproduct = [];
    List user = [];
    List<Map<String, dynamic>> penjualan = [];
    
      List? get produk => null;

    takeProduct() async {
      var product = await Supabase.instance.client.from('produk').select();
      setState(() {
        myproduct = produk!;
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

  void initState() {
    super.initState();
    takeProduct();
    takePelanggan();
  }

  void addPelanggan() {
    final String name = nameController.dropDownValue!.value;
    final int quantity = int.parse(quantityController.text);
    print('Pelanggan Name: $name, Quantity: $quantity');
    // Kembali ke layar sebelumnya setelah menambahkan produk
    Navigator.of(context).pop();
  }

  void addProduct() {
    // Implementasikan logika umtuk menambah produk, misalnya, kirim data ke supabase
    final String name = nameController.dropDownValue!.value;
    final int quantity = int.parse(quantityController.text);
    print('Product Name: $name, Quantity; $quantity');
    // Kembali ke layar sebelumnya setelah menambahkan produk
    Navigator.of(context).pop();
  }

  excuteSales() async {
    var quantityController;
    var penjualan = await Supabase.instance.client 
      .from('penjualan')
      .insert([
        {
          "PelangganID": nameController.dropDownValue!.value["PelangganID"],
          "TotalHarga": ((produkController.dropDownValue!.value["Harga"] *
          int.parse(quantityController.text)) as int)
        }
      ])
      .select()
      .single();
    if (penjualan.isNotEmpty) {
      var quantityController;
      var produkController;
      var detailpenjualan =
        await Supabase.instance.client.from('detailpenjualan').insert([
          {
            "PenjualanID": penjualan["PenjualanID"],
            "ProdukID": produkController.dropDownValue!.value["ProdukID"],
            'JumlahProduk': int.parse(quantityController.text),
            'Subtotal': ((produkController.dropDownValue!.value["Harga"] *
            int .parse(quantityController.text)) as int )
          }
        ]);
      if (detailpenjualan == null) {
        var produkController;
        var quantityController;
        var product = await Supabase.instance.client.from('produk').update({
          'Stok': produkController.dropDownValue!.value["Stok"] -
            int.parse(quantityController.text)   
        }).eq('ProdukID', produkController.dropDownValue!.value["ProdukID"]);
        if(product == null) {
          Navigator.pop(context, true);
        }
      }
    }
  }
  @override 
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [ 
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: ''
                        border: OutlineInputBorder(),
                      ),                  
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
    );
  }
}

class SingleValueDropDownController {
  get dropDownValue => null;
  
  String? get text => null;

  void dispose() {}
}