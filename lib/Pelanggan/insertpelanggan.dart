import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk/beranda.dart';

class insertPage extends StatefulWidget {
  const insertPage({super.key});

  @override
  State<insertPage> createState() => _insertPageState();
}

class _insertPageState extends State<insertPage> {
  final _nmplg = TextEditingController();
  final _alamat = TextEditingController();
  final _notlp = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> langgan() async {
    if (_formKey.currentState!.validate()) {
      final String NamaPelanggan = _nmplg.text;
      final String Alamat = _alamat.text; 
      final String NomorTelepon = _notlp.text;
      try {
        final response =
        await Supabase.instance.client.from('pelanggan').insert({
          'NamaPelanggan': NamaPelanggan,
          'Alamat': Alamat,
          'NomorTelepon': NomorTelepon,
        });
        if (response == null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      } catch (error) {
        if (error is PostgrestException && error.code == '23505') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nama pelanggan ini sudah terdaftar')
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah pelanggan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nmplg,
                decoration: const InputDecoration(
                  labelText: 'Nama Pelanggan',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama Pelanggan tidak boleh kosong.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notlp,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor Telepon tidak boleh kosong.';
                  }
                  if (!RegExp(r'^\d+$').hasMatch(value)) {
                    return 'Nomor Telepon harus berupa angka.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _alamat,
                decoration: const InputDecoration(
                  labelText: 'Alamat',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alamat tidak boleh kosong.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: langgan,
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}