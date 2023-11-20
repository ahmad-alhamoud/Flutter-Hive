import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    _refreshItems() ;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hive"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final currentItem = _items[index] ;
          return Card(
            color: Colors.orange.shade100,
            margin: const EdgeInsets.all(20),
            elevation: 3,
            child: ListTile(
              title: Text(
                currentItem['name'] ,
              ),
              subtitle: Text(
                currentItem['quantity'].toString() ,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MaterialButton(
                      onPressed: () =>_showForm(context, currentItem['key']),
                      child: const Icon(Icons.edit)
                  ),
                  MaterialButton(
                      onPressed: () => _deleteItem(currentItem['key']) ,
                      child: const Icon(Icons.delete)
                  ) ,
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, null ),
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Map<String, dynamic>> _items = [];

  final _shoppingBox = Hive.box('shopping_box');

  // Create new item
  Future<void> _createItem(Map<String, dynamic> newItem) async {
    await _shoppingBox.add(newItem);
    print("amount data is ${_shoppingBox.length}");
    _refreshItems();
  }
  Future<void> _deleteItem(int itemKey) async {
      await _shoppingBox.delete(itemKey) ;
    _refreshItems() ;
  }
  Future<void> _updateItem( int itemKey, Map<String , dynamic> newItem) async {
    await _shoppingBox.put( itemKey, newItem) ;
    _refreshItems() ;
  }
  // show the form
  void _showForm(BuildContext ctx, int? itemKey) {
    if(itemKey !=null ) {
      final existingItem = _items.firstWhere((element) => element['key'] == itemKey);
      _nameController.text = existingItem['name'] ;
      _quantityController.text = existingItem['quantity'] ;
    }
    showModalBottomSheet(
      context: ctx,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        height: MediaQuery.of(ctx).size.height * 0.4,
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            top: 15,
            right: 15,
            left: 15
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: 'Name')),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Quantity',
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if(_nameController.text.isNotEmpty && _quantityController.text.isNotEmpty){
                   if(itemKey !=null) {
                     _updateItem(itemKey, {
                       "name" : _nameController.text ,
                       "quantity" : _quantityController.text ,
                     }) ;
                   }
                   else {
                     _createItem({
                       "name": _nameController.text,
                       "quantity": _quantityController.text,
                     });
                   }
                  }
                  _nameController.text = '';
                  _quantityController.text = '';
                  Navigator.of(context).pop();
                },
                child: itemKey == null ? const  Text('Create New') :  const Text('Update'),
              ),
              const SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _refreshItems() {
    final data = _shoppingBox.keys.map((key) {
      final item = _shoppingBox.get(key);
      return {"key": key, "name": item["name"], "quantity": item["quantity"]};
    }).toList();
    setState(() {
      _items = data.reversed.toList();
    });
    print("Items length ${_items.length}");
  }
}
