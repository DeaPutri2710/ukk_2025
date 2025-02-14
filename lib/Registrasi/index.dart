import 'dart:js_interop_unsafe';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk/Registrasi/insert.dart';
import 'package:ukk/Registrasi/update.dart';

class UserRegister extends StatefulWidget {
  const UserRegister({super.key});

  @override
  State<UserRegister> createState() => _UserRegisterState();
}

class _UserRegisterState extends State<UserRegister> {
  List<Map<String, dynamic>> user  = [];
    bool isLoading = true;

  @override
    void initState () {
      super.initState();
      fetchuser();
    }
    Future<void> deleteuser(int id) async {
      try {
        await Supabase.instance.client
          .from('user')
          .delete()
          .eq('id', id);
          fetchuser();
      } catch (e) {
        print('error: $e');
      }
    }

    Future<void> fetchuser() async {
      setState(() {
        isLoading = true;
      });
      try {
        final response = await Supabase.instance.client.from('user').select();
        setState(() {
          user = List<Map<String, dynamic>>.from(response);
          isLoading = false;
        });
      } catch (e) {
        print('error: $e');
        setState(() {
          isLoading = false;
        });
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('List User'),
        ),
        body: isLoading
        ? Center(
          child: LoadingAnimationWidget.twoRotatingArc(
            color: Colors.grey, size: 30),
        )
        : user.isEmpty
          ? Center(
            child: const Text(
              'User belum ditambahkan',
              style: TextStyle(fontSize: 18),
            ),
          )
          : Column(
            children: [
              Card(
                margin: const EdgeInsets.all(10),
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                    child: Row(
                      children: const [
                        Expanded(flex: 2, child: Text('Username', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text('Password', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(flex: 1, child: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(flex: 1, child: Text('Aksi', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: user.length,
                  itemBuilder: (context, index) {
                    final userdata = user[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(flex: 2, child: Text(userdata['username'] ?? '')),
                            Expanded(flex: 2, child: Text(userdata['password'] ?? '')),
                            Expanded(flex: 1, child: Text(userdata['role'] ?? '')),
                            Expanded(
                              flex: 1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      final id = userdata['id'] ?? 0;
                                      if (id != 0) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => UpdateUser(id: id)));
                                      }
                                    }, 
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Hapus User'),
                                            content: const Text(
                                              'Apakah anda yakin ingin menghapus user?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Batal')),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      deleteuser(userdata['id']);
                                                    }, 
                                                    child: const Text('Hapus'))
                                              ],
                                          );
                                        });
                                    },
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context, MaterialPageRoute(builder: (context) => UserInsert()));
          },
          child: const Icon(Icons.add),
        ),
      );
    }
}

class LoadingAnimationWidget {
  static twoRotatingArc({required MaterialColor color, required int size}) {}
}