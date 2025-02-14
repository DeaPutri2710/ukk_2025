import 'package:flutter/material.dart';
import 'package:ukk/Registrasi/index.dart';

class ProdukTab extends StatefulWidget {
  @override
  _ProdukTabState createState() => _ProdukTabState();
}

class _ProdukTabState extends State<ProdukTab> {
  List<Map<String, dynamic>> produk = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProduk();
  }

  Future<void> fetchProduk() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await Supabase.instance.client.from('produk').select();
      setState(() {
        produk = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    }
  }

  Future<void> deleteProduk(int id) async {
    try {
      await Supabase.instance.client.from('produk').delete().eq('ProdukID', id);
      fetchProduk();
    } catch (e) {
      print('Error deleting produk: $e');
    }
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
      ? Center(
        child: LoadingAnimationWidget.twoRotatingArc(
          color: Colors.grey, size: 30),
      )
      : produk.isEmpty
        ? Center(
          child: Text(
            'Tidak ada produk',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        )
      : GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
        ),
        padding: EdgeInsets.all(8),
        itemCount: produk.length,
        itemBuilder: (context, index) {
          final oduk = produk[index];
          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      oduk['Nama Produk'] ?? 'Produk tidak tersedia',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Harga: Rp${oduk['Harga']}',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${oduk['stok']} pcs',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Divider

                  ],
                ),),)
        },
      )

    )
  }
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}