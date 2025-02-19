import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk/Penjualan/checkout.dart';
import 'package:ukk/Produk/updateproduk.dart';
import 'package:ukk/Produk/insertproduk.dart';

class ProdukTab extends StatefulWidget {
  @override
  _ProdukTabState createState() => _ProdukTabState();
}

class _ProdukTabState extends State<ProdukTab> {
  List<Map<String, dynamic>> produk = [];
  List<Map<String, dynamic>> filteredProduk = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() { 
    super.initState();
    fetchProduk();
  }

  // Fetch data produk dari Supabase
  Future<void> fetchProduk() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await Supabase.instance.client.from('produk').select();
      setState(() {
        produk = List<Map<String, dynamic>>.from(response);
        filteredProduk = produk;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching produk: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Menghapus produk
  Future<void> deleteProduk(int id) async {
    try {
      await Supabase.instance.client.from('produk').delete().eq('ProdukID', id);
      fetchProduk();
    } catch (e) {
      print('Error deleting produk: $e');
    }
  }

  // Filter produk berdasarkan nama
  void filterProduk(String query) {
    final hasilFilter = produk.where((prod) {
      final namaProdukLower = prod['NamaProduk'].toLowerCase();
      final searchLower = query.toLowerCase();
      return namaProdukLower.contains(searchLower);
    }).toList();

    setState(() {
      filteredProduk = hasilFilter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Cari Produk...',
            border: InputBorder.none,
          ),
          onChanged: filterProduk,
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Menunggu loading
          : filteredProduk.isEmpty
              ? Center(
                  child: Text(
                    'Tidak ada produk',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: filteredProduk.length,
                  itemBuilder: (context, index) {
                    final produkItem = filteredProduk[index]; // Ganti 'oduk' jadi 'produkItem'
                    return GestureDetector(
                        onTap: () {
                          // Navigasi ke COpage
                          num totalHarga = produkItem['Harga'] * produkItem['Stok'];
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return COpage(
                                  cart: [produkItem],
                                  totalHarga: totalHarga.toDouble(),
                                );
                              },
                            ),
                          );
                        },
                        child: Card(
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
                                  produkItem['NamaProduk'] ?? 'Produk tidak tersedia',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Harga: Rp${produkItem['Harga']}',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${produkItem['Stok']} pcs',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Tombol Edit
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.black),
                                      onPressed: () async {
                                        final Produkid = produkItem['ProdukID'] ?? 0;
                                        if (Produkid != 0) {
                                          var hasil = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  UpdateProduk(ProdukID: Produkid),
                                            ),
                                          );
                                          if (hasil == true) {
                                            fetchProduk();
                                          }
                                        } else {
                                          print('ID produk tidak valid');
                                        }
                                      },
                                    ),
                                    // Tombol Hapus
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.black),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Hapus Produk'),
                                              content: const Text(
                                                  'Apakah Anda yakin ingin menghapus produk ini?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text('Batal'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    await deleteProduk(produkItem['ProdukID']);
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Hapus'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ));
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var hasil = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => insertPage()),
          );
          if (hasil == true) {
            fetchProduk();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

