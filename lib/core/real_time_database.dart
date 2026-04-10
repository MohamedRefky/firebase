// ignore_for_file: avoid_print

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class RealTimeDatabase {
  final FirebaseDatabase database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://firetest-mo-default-rtdb.europe-west1.firebasedatabase.app/',
  );

  Future<void> setData() async {
    try {
      DatabaseReference ref = database.ref("users/1233");
      await ref.set({
        "name": "John",
        "age": 18,
        "address": {"line1": "100 Mountain View"},
      });
    } catch (e) {
      print('Error setting data: $e');
    }
  }

  Future<void> updateData() async {
    try {
      DatabaseReference ref = database.ref("users/1233");
      await ref.update({
        "age": 20,
        "address": {"line1": "benha", "line2": "cairo"},
      });
    } catch (e) {
      print('Error setting data: $e');
    }
  }

  Future<Map<String, dynamic>?> getData() async {
    try {
      DatabaseReference ref = database.ref("users/1233");

      DataSnapshot snapshot = await ref.get();

      if (snapshot.exists) {
        return snapshot.value as Map<String, dynamic>?;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
