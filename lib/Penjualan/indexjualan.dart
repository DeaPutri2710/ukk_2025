import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk/Penjualan/checkout.dart';

class indexpenjualan extends StatefulWidget {
  const indexpenjualan({super.key});

  @override
  State<indexpenjualan> createState() => _indexpenjualanState();
}

class _indexpenjualanState extends State<indexpenjualan> {
  List<Map<String, dynamic>> penjualan = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPenjualan();
  }

  Future<void> fetchPenjualan() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await Supabase.instance.client
          .from('penjualan')
          .select('*, pelanggan(*)')
          .order('TanggalPenjualan', ascending: false);
      print(response);
      setState(() {
        penjualan = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching penjualan: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deletePenjualan(int id) async {
    try {
      await Supabase.instance.client
          .from('penjualan')
          .delete()
          .eq('PenjualanID', id);
      fetchPenjualan();
    } catch (e) {
      print('Error deleting penjualan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print(penjualan);
    // bool isLoading = true;
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => fetchPenjualan(),
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: penjualan.length,
                itemBuilder: (context, index) {
                  final item = penjualan[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(item['pelanggan']['NamaPelanggan']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total harga: ${item['TotalHarga']}'),
                          Text('Tanggal Penjualan: ${item['TanggalPenjualan']}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.black),
                        onPressed: () => _showDeleteDialog(context, item, index),
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var sales = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => COpage()),
          );
          if (sales == true) fetchPenjualan();
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Map<String, dynamic> item, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Pelanggan'),
          content: const Text('Apakah anda yakin ingin menghapus produk ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                deletePenjualan(item['PenjualanID']);
                Navigator.pop(context);
                setState(() => penjualan.removeAt(index));
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }
}