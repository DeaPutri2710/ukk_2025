import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class DetailPenjualanPage extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final num totalHarga;
  final Map<String, dynamic> user;

  DetailPenjualanPage({
    required this.cart,
    required this.totalHarga,
    required this.user,
  });

  @override
  _DetailPenjualanPageState createState() => _DetailPenjualanPageState();
}

class _DetailPenjualanPageState extends State<DetailPenjualanPage> {
  bool isReceiptPrinted = false; // Flag untuk menandakan apakah struk telah dicetak

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Struk Penjualan")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nama Pelanggan: ${widget.user['NamaPelanggan']}", style: TextStyle(fontSize: 16)),
            Text("Alamat: ${widget.user['Alamat']}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: widget.cart.length,
                itemBuilder: (context, index) {
                  final item = widget.cart[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(item["NamaProduk"]),
                      subtitle: Text("Jumlah: ${item['Jumlah']}, Subtotal: ${item['Subtotal']}"),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),

            Text("Total Harga: ${widget.totalHarga}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                printReceipt(context); // Fungsi untuk mencetak PDF dan update UI
              },
              child: Text("Cetak Struk PDF"),
            ),
            
            // Tampilkan pesan bahwa struk telah dicetak
            if (isReceiptPrinted) 
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text("Struk Telah Dicetak!", style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk mencetak struk PDF dan memberikan umpan balik ke detail penjualan
  void printReceipt(BuildContext context) async {
    final pdf = pw.Document();

    // Menambahkan halaman ke PDF
    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          children: [
            pw.Text("Struk Penjualan", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text("Nama Pelanggan: ${widget.user['NamaPelanggan']}", style: pw.TextStyle(fontSize: 18)),
            pw.Text("Alamat: ${widget.user['Alamat']}", style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 20),

            // Daftar produk yang dibeli
            ...widget.cart.map((item) {
              return pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(item["NamaProduk"], style: pw.TextStyle(fontSize: 14)),
                  pw.Text("Jumlah: ${item['Jumlah']}", style: pw.TextStyle(fontSize: 14)),
                  pw.Text("Subtotal: ${item['Subtotal']}", style: pw.TextStyle(fontSize: 14)),
                ],
              );
            }).toList(),

            pw.SizedBox(height: 20),
            pw.Text("Total Harga: ${widget.totalHarga}", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          ],
        );
      },
    ));

    // Cetak PDF menggunakan Printing
    Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
      return pdf.save();  // Mengembalikan hasil PDF dalam bentuk bytes untuk pencetakan
    });

    // Menyimpan PDF di perangkat (opsional)
    final directory = await getTemporaryDirectory();
    final file = File("${directory.path}/struk_penjualan.pdf");
    await file.writeAsBytes(await pdf.save());
    print("PDF Disimpan di: ${file.path}");

    // Menampilkan dialog atau Snackbar setelah pencetakan selesai
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Struk Penjualan telah berhasil dicetak dan disimpan!"))
    );

    // Update UI untuk menunjukkan bahwa struk telah dicetak
    setState(() {
      isReceiptPrinted = true; // Menandakan bahwa struk telah dicetak
    });

    // Kembali ke halaman sebelumnya (Detail Penjualan) setelah mencetak
    Navigator.pop(context);
  }
}
