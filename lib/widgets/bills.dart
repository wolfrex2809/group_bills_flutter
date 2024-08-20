import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import '../firebase_options.dart';
import '../models.dart';

class CreateBill extends StatefulWidget {
  CreateBill({super.key});

  @override
  State<CreateBill> createState() => _CreateBillState();
}

class _CreateBillState extends State<CreateBill> {

  final _formKey = GlobalKey<FormState>();
  final Bills bill = Bills();

  Future<Map> getUsers() async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('users').get();
    if (snapshot.exists) {
        var result = snapshot.value as Map;
        return result;
    } else {
        print('No data available.');
        return {};
    }
  }

  Future<void> createBill(Bills bill) async{
    final postData = {
        'title': bill.title,
        'user_id': bill.userId,
        'total': bill.total,
        'date': bill.date.toString(),
        'participants': bill.participants,
    };
    print(postData);
    final newPostKey = FirebaseDatabase.instance.ref().child('posts').push().key;
    final Map<String, Map> updates = {};
    updates['/bills/$newPostKey'] = postData;
    return FirebaseDatabase.instance.ref().update(updates);
  }

  Future<void> processCreateBill() async{
    await createBill(bill);
    Navigator.popAndPushNamed(context, "/home");
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("New Bill"),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(50.0, 1.0, 50.0, 1.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                onSaved: (newValue) => bill.title = newValue!,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  label: Text("Title")
                ),
                validator: (value){
                  if(value == null || value.isEmpty){
                    return "Please type the bill title";
                  }
                  return null;
                },
              ),
              TextFormField(
                onSaved: (newValue) => bill.total = double.parse(newValue!.isNotEmpty ? newValue : "0"),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  label: Text("Total"),
                ),
                validator: (value){
                  if(value == null || value.isEmpty){
                    return "Please type the bill total amount";
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(vertical: 15.0),
                child: FutureBuilder(
                  future: getUsers(), 
                  builder: (context, snapshot){
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return const Text('none');
                      case ConnectionState.waiting:
                        return const Center(child: CircularProgressIndicator());
                      case ConnectionState.active:
                        return const Text('');
                      case ConnectionState.done:
                        if (snapshot.hasError) {
                          return Text(
                            '${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          );
                        } else {
                          return MultiDropdown<String>(
                            validator: (selectedOptions) {
                              if(selectedOptions == null || selectedOptions.isEmpty){
                                return "Please select at least one user";
                              }
                              return null;
                            },
                            fieldDecoration: const FieldDecoration(
                              labelText: "Users",
                            ),
                            // icon: const Icon(Icons.people),
                            // elevation: 16,
                            // style: const TextStyle(color: Colors.deepPurple),
                            onSelectionChange: (selectedItems) {
                                bill.participants = selectedItems;
                            },
                            items: snapshot.data!.map((key, value) {
                              return MapEntry(
                                key,
                                DropdownItem<String>(
                                  value: key,
                                  label: value["name"],
                                )
                              );
                            }).values.toList(),
                          );
                        }
                    } 
                  }
                ), 
              ),
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(vertical: 15.0),
                child: ElevatedButton(
                  onPressed: (){
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      bill.date = DateTime.now();
                      bill.userId = FirebaseAuth.instance.currentUser!.uid;
                      processCreateBill();
                    }
                  }, 
                  child: Text("Create")
                ),
              )
            ]
          )
        )
      ),
    );
  }
}