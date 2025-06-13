import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/address.dart';

class AddressListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Alamat'),
        backgroundColor: Colors.red,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Address>('addresses').listenable(),
        builder: (context, Box<Address> box, _) {
          if (box.isEmpty) {
            return Center(
              child: Text('Belum ada alamat tersimpan'),
            );
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final address = box.getAt(index);
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  onTap: () {
                    final selectedAddressBox = Hive.box<int>('selectedAddressIndexBox');
                    selectedAddressBox.put('selected', index); // Save the index of the selected address
                    Navigator.pop(context, address); // Pass the selected address back
                  },
                  title: Text(address!.label),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(address.recipientName),
                      Text(address.fullAddress),
                      Text(address.phoneNumber),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      box.deleteAt(index);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAddressDialog(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showAddAddressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return _AddAddressFormDialog();
      },
    );
  }
}

class _AddAddressFormDialog extends StatefulWidget {
  @override
  _AddAddressFormDialogState createState() => _AddAddressFormDialogState();
}

class _AddAddressFormDialogState extends State<_AddAddressFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final labelController = TextEditingController();
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void dispose() {
    labelController.dispose();
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Tambah Alamat Baru'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: labelController,
                decoration: InputDecoration(
                  labelText: 'Label Alamat',
                  hintText: 'Rumah, Kantor, dll',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Label Alamat tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Penerima',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama Penerima tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Alamat Lengkap',
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alamat Lengkap tidak boleh kosong';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Nomor Telepon',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor Telepon tidak boleh kosong';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final newAddress = Address(
                label: labelController.text,
                recipientName: nameController.text,
                fullAddress: addressController.text,
                phoneNumber: phoneController.text,
              );
              
              final box = Hive.box<Address>('addresses');
              box.add(newAddress);
              
              Navigator.pop(context);
            }
          },
          child: Text('Simpan'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
        ),
      ],
    );
  }
}
