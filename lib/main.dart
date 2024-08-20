import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'models.dart';
import 'widgets/bills.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      initialRoute: FirebaseAuth.instance.currentUser != null ? "/home"  : "/login",
      routes: {
        '/home': (context) => MyHomePage(title: 'Hola, ${FirebaseAuth.instance.currentUser != null ? FirebaseAuth.instance.currentUser!.displayName : ""}',),
        '/login': (context) => Login(),
        '/home/create_bill': (context) => CreateBill()
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

  final List<Bills> bills = [];

  Future<List> getBills() async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('bills').get();
    if (snapshot.exists) {
        var result = snapshot.value as Map;
        var _bills = Map.from(result)..removeWhere((key, value) => FirebaseAuth.instance.currentUser!.uid != value["user_id"]);
        _bills.forEach((key, value) { 
          // var participants = value["participants"] as Map;
          // print(participants);
          var bill = Bills(
            id: key,
            userId: value["user_id"],
            title: value["title"],
            total: value["value"],
            date: DateTime.parse(value["date"]),
            participants: []
          );
          bills.add(bill);
        });
        return bills;
    } else {
        print('No bills data available.');
        return [];
    }
  }

  Future<void> processCreateBill() async{
    var response = await getBills();
    print(response);
  }
  @override
  Widget build(BuildContext context) {
    processCreateBill();
    print("rebuild");
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
            ListTile(
              title: const Text("Sign out"),
              onTap: (){
                FirebaseAuth.instance.signOut();
                Navigator.popAndPushNamed(context, "/login");
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
          Navigator.pushNamed(context, "/home/create_bill");
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

  DatabaseReference ref = FirebaseDatabase.instance.ref();

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> signAndAssing() async {
    await signInWithGoogle(); 
    print(FirebaseAuth.instance.currentUser);
    if (FirebaseAuth.instance.currentUser != null){
      bool usersExists = await searchUser(FirebaseAuth.instance.currentUser!.uid);
      print(usersExists);
      if(!usersExists){
        await createUser(FirebaseAuth.instance.currentUser!.uid, FirebaseAuth.instance.currentUser!.displayName);
      }
      loggedUser.id = FirebaseAuth.instance.currentUser!.uid;
      loggedUser.name = FirebaseAuth.instance.currentUser!.displayName;
    }
    Navigator.popAndPushNamed(context, "/home");
  }

  Future<bool> searchUser(uid) async{
    final snapshot = await ref.child('users/$uid').get();
    return (snapshot.exists);
  }

  Future<void> createUser(id, name) async{
    final postData = {
        'name': name,
    };
    final Map<String, Map> updates = {};
    updates['/users/$id'] = postData;
    return FirebaseDatabase.instance.ref().update(updates);
  }

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
                const Center(
                 child: Text("Make money not friends!"),
                ),
                ElevatedButton(
                  onPressed: (){
                      signAndAssing();
                      
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       Container(
                        width: 40,
                        height: 40,
                        child:Image.network(
                          'http://pngimg.com/uploads/google/google_PNG19635.png',
                          fit:BoxFit.cover
                        ),
                      ),
                      Text("Sign in")
                    ],
                  )
                ),
              ],
            ),
      ),
    );
  }
}