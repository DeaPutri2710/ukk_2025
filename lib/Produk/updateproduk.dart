import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdateProduk extends StatefulWidget { 
  final int ProdukID;

  const UpdateProduk({super.key, required this.ProdukID});

  @override
  State<UpdateProduk> createState() => _UpdateProdukState();
}

class _UpdateProdukState extends State<UpdateProduk> {
  final _namaProdukController = TextEditingController();
  final _hargaProdukController = TextEditingController();
  final _stokProdukController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDataproduk();
  }

  Future<void> _loadDataproduk() async {
    try {
      final data = await Supabase.instance.client
          .from('produk')
          .select()
          .eq('ProdukID', widget.ProdukID)
          .single();

      setState(() {
        _namaProdukController.text = data['NamaProduk'] ?? '';
        _hargaProdukController.text = data['Harga'].toString(); // Pastikan harga tampil sebagai string
        _stokProdukController.text = data['Stok'].toString(); // Pastikan stok tampil sebagai string
        _isLoading = false;
      });
    } catch (e) {
      print('Error produk data: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat data produk.')),
      );
    }
  }

  Future<void> updateProduk() async {
    if (_formKey.currentState!.validate()) {
      try {
        await Supabase.instance.client.from('produk').update({
          'NamaProduk': _namaProdukController.text,
          'Harga': int.parse(_hargaProdukController.text),
          'Stok': int.parse(_stokProdukController.text),
        }).eq('ProdukID', widget.ProdukID);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data produk berhasil diperbarui.')),
        );

        Navigator.of(context).pop(true);
      } catch (e) {
        print('Error updating produk: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memperbarui data produk.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Produk'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _namaProdukController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Produk',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama produk tidak boleh kosong.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _hargaProdukController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Harga',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harga tidak boleh kosong.';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Harga harus berupa angka.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _stokProdukController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Stok',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Stok tidak boleh kosong.';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Stok harus berupa angka.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: updateProduk,
                      child: const Text('Update'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
