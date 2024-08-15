import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'models.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Friends Bills',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      initialRoute: loggedUser.id != "" ? "/"  : "/login",
      routes: {
        '/': (context) => MyHomePage(title: 'Hola, ${loggedUser.name}',),
        '/login': (context) => Login(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text("Friends Bills")),
            ListTile(
              title: const Text("Cuentas"),
              onTap: (){

              },
            ),
            ListTile(
              title: const Text("Deudas"),
              onTap: (){
                
              },
            ),
          ],
        )
      ),
      body: ListView(
        children: const [
          ListTile(
            title: Text("Sushi Omakase"),
            subtitle: Text("From: Lauren Sanabria"),
            trailing: Text("40 USD", style: TextStyle(color: Colors.red)),
          ),
          ListTile(
            title: Text("Pastelitos Maracuchos"),
            subtitle: Text("To: Soto, Milkar, Lauren"),
            trailing: Text("40 USD", style: TextStyle(color: Colors.green)),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){

        },
        tooltip: 'New',
        child: const Icon(Icons.add),
      )
    );
  }
}


class Login extends StatefulWidget {
  Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController(); 
  final _passController = TextEditingController(); 
  bool passwordVisible=true;
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Login"),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(50.0, 1.0, 50.0, 1.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text("Make money not Friends"),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          label: Text("Name")
                        ),
                        validator: (value){
                          if(value == null || value.isEmpty){
                            return "Please type your name";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _passController,
                        obscureText: passwordVisible,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          label: const Text("Password"),
                          suffixIcon: IconButton(
                            icon: Icon((passwordVisible ? Icons.visibility : Icons.visibility_off)),
                            onPressed: () {
                              setState(
                                () {
                                  passwordVisible = !passwordVisible;
                                },
                              );
                            },
                          ),
                        ),
                        validator: (value){
                          if(value == null || value.isEmpty){
                            return "Please type your password";
                          }
                          return null;
                        },
                      ),
                      Padding(
                        padding:EdgeInsetsDirectional.symmetric(vertical: 15.0),
                        child: ElevatedButton(
                          onPressed: (){
                            if (_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Processing Data')),
                              );
                              loggedUser = AppUser(id: _passController.text, name: _nameController.text);
                              Navigator.popAndPushNamed(context, "/");
                            }
                          }, 
                          child: Text("Log in")
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
      ),
    );
  }
}