import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Indexdetail extends StatefulWidget {
  const Indexdetail({super.key});

  @override
  State<Indexdetail> createState() => _IndexdetailState();
}

class _IndexdetailState extends State<Indexdetail> {
  List<Map<String, dynamic>> detailpenjualan = [];

  @override
  void initState() {
    super.initState();
    fetchdetail();
  }

  Future<void> fetchdetail() async {
    try {
      final data = await Supabase.instance.client
          .from('detailpenjualan')
          .select('*, penjualan(*, pelanggan(*)), produk(*)');
      setState(() {
        detailpenjualan = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('error $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
          itemCount: detailpenjualan.length,
          itemBuilder: (context, index) {
            final detail = detailpenjualan[index];
            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(color: Colors.brown.withOpacity(0.2)),
                  ],
                ),
                child: Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          detail['penjualan']['pelanggan']['NamaPelanggan']
                                  ?.toString() ??
                              'Pelanggan tidak tersedia',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          detail['produk']['NamaProduk'] ??
                              'Produk tidak tersedia',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          detail['JumlahProduk']?.toString() ??
                              'Tidak tersedia',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        SizedBox(height: 8),
                        Text(
                          detail['Subtotal']?.toString() ?? 'Tidak teredia',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green,
                          ),
                          textAlign: TextAlign.justify,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}
