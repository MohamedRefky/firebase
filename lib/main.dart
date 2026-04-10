import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/core/real_time_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseAuth.instance.setLanguageCode("en");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  final controller = TextEditingController();
  String phone = '+201019964880';
  bool isLoading = false;
  String realtimeData = "";

  @override
  void initState() {
    super.initState();
    // Start listening to realtime updates
    FirebaseFirestore.instance
        .collection("cities")
        .doc("Eg")
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            setState(() {
              realtimeData = snapshot.data().toString();
            });
          } else {
            setState(() {
              realtimeData = "Document does not exist";
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Phone: $phone"),
              SizedBox(height: 16),
              TextField(
                controller: controller,
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await RealTimeDatabase().updateData();
                },
                child: const Text('Send OTP'),
              ),
              SizedBox(height: 32),
              // Realtime data using StreamBuilder
              StreamBuilder<DatabaseEvent>(
                stream: FirebaseDatabase.instanceFor(
                  app: Firebase.app(),
                  databaseURL:
                      'https://firetest-mo-default-rtdb.europe-west1.firebasedatabase.app/',
                ).ref("users/123").onValue,
                builder: (context, snapshot) {
                  // Loading
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Error
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  // No data
                  if (!snapshot.hasData ||
                      snapshot.data?.snapshot.value == null) {
                    return const Center(child: Text("No data available"));
                  }

                  // Get data
                  final data =
                      snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

                  return Center(
                    child: Text(
                      "Realtime Data:\n${data["age"]}\n${data["address"]}",
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
