import 'package:flutter/material.dart';
import 'package:ukk/Registrasi/index.dart';
import 'package:ukk/main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pink.shade100,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.inventory, color: Colors.black), text: 'Produk'),
              Tab(icon: Icon(Icons.people, color: Colors.black), text: 'Pelanggan'),
              Tab(icon: Icon(Icons.shopping_cart, color: Colors.black), text: 'Penjualan'),
              Tab(icon: Icon(Icons.account_balance_wallet, color: Colors.black), text: 'Detail Penjualan'),
            ],
          ),
        ),
        drawer: _buildDrawer(context),
        // body: TabBarView(
        //   children: [
        //     PelangganTab(),
        //     ProdukTab(),
        //     indexpenjualan(),
        //     DetailPenjualan()
        //   ],
        // ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
      return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.pink.shade100),
              child: const SizedBox(),
            ),
            ListTile(
              leading: const Icon(Icons.app_registration),
              title: const Text('Registrasi'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserRegister()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
              },
            ),
          ],
        ),
      );
    }

  Widget _buildProdukTab(BuildContext context) {
    return const Center(
      child: Text(
        'Halaman Produk',
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
