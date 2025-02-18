import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk/Registrasi/index.dart';

class UpdateUser extends StatefulWidget {
  final int id;
  const UpdateUser({super.key, required this.id});

  @override
  State<UpdateUser> createState() => _UpdateUserState();
}

class _UpdateUserState extends State<UpdateUser> {
  final _user = TextEditingController();
  final _password = TextEditingController();
  // final _role = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _isLoadingDataUser();
  }

  Future<void> _isLoadingDataUser() async {
    try {
      final data = await Supabase.instance.client
        .from('user')
        .select()
        .eq('id', widget.id)
        .single();

      setState(() {
        _user.text = data ['username'] ?? '';
        _password.text = data ['password'] ?? '';
        // _role.text = data ['role'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data user.')),
      );
    }
  }
  // Update user data di database
  Future<void> updateUserData() async {
    if (_formKey.currentState!.validate()) {
      try {
        await Supabase.instance.client.from('user').update({
          'username': _user.text,
          'password': _password.text,
          // 'role': _role.text
        }).eq('id', widget.id);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data User berhasil diperbarui.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserRegister()),
        );
      } catch (e) {
        print('Error updating user: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui data user.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update User'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _user,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _password,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }
                  return null;
                },
              ),
              // SizedBox(height: 16),
              // TextFormField(
              //   controller: _role,
              //   decoration: InputDecoration(
              //     labelText: 'Role',
              //     border: OutlineInputBorder(),
              //   ),
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Role tidak boleh kosong';
              //     }
              //     return null;
              //   },
              // ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: updateUserData,
                child: Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}