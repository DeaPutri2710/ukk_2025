import 'dart:js_interop_unsafe';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:ukk/Pelanggan/updatepelanggan.dart';
import 'package:ukk/Pelanggan/insertpelanggan.dart';
import 'package:ukk/Registrasi/index.dart';

class PelangganTab extends StatefulWidget {
  @override
   _PelangganTabState createState() => _PelangganTabState();
}

class _PelangganTabState extends State<PelangganTab> {
 List<Map<String, dynamic>> pelanggan = [];
 bool isLoading = true;

 @override  
 void initState() {
  super.initState();
  fetchPelanggan();
 }

  Future<void> fetchPelanggan() async {
      setState(() {
        isLoading = true;
      });
      try {
        final response =
        await Supabase.instance.client.from('pelanggan').select();
        setState(() {
          pelanggan = List<Map<String, dynamic>>.from(response);
          isLoading = false;
        });
      } catch (e) {
        print('Error fetching pelanggan: $e');
        setState(() {
          isLoading = false;
        });
      }
    } 

    Future<void> deletePelangan(int id) async {
      try {
        await Supabase.instance.client
        .from('pelanggan')
        .delete()
        .eq('PelangganID', id);
        fetchPelanggan();
      }  catch (e) {
        print('Error deleting pelanggan: $e');
      }
    }

    @override 
    Widget build(BuildContext context) {
      return Scaffold(
        body: isLoading
        ? Center(
          child: LoadingAnimationWidget.twoRotatingArc(
            color: Colors.grey, size: 30,),
        )
        : pelanggan.isEmpty
        ? Center(
          child: Text(
            'Tidak ada pelanggan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        )
        : GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
          ),
          padding: EdgeInsets.all(8),
          itemCount: pelanggan.length,
          itemBuilder: (context, index) {
            final langgan = pelanggan[index];
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
                        langgan['NamaPelanggan'] ?? 
                        'Pelanggan tidak tersedia',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        langgan['Alamat'] ?? 'Alamat tidak tersedia',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        langgan['NomorTelepon'] ??
                        'Nomor Telepon tidak tersedia',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit,
                            color: Colors.black),
                            onPressed: () {
                              final PelangganID = langgan[
                                'PelangganID'] ?? 0;
                                if (PelangganID != 0) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => Updatepelanggan(PelangganID: PelangganID))
                                  );
                                } else {
                                  print('ID pelanggan tidak valid');
                                }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                            color: Colors.black),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext contect) {
                                  return AlertDialog(
                                    title: const Text('Hapus pelanggan'),
                                    content: const Text(
                                      'Apakah anda yakin ingin menghapus pelanggan ini?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Batal'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            deletePelangan(
                                              langgan['PelangganID']);
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
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => insertPage()),
                );
              },
              child: Icon(Icons.add),
            ),

          );
        }

}
