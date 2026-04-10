// ignore_for_file: avoid_print

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class RealTimeDatabaseService {
  final FirebaseDatabase database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://firetest-mo-default-rtdb.europe-west1.firebasedatabase.app/',
  );

  Future<void> addData() async {
    try {
      DatabaseReference ref = database.ref("users/2");
      await ref.set({
        "name": "Ahmed",
        "age": 30,
        "address": {"line1": "benha", "line2": "cairo"},
      });
      print("Data added successfully.");
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
      DatabaseReference ref = database.ref("users");

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

  Future<bool> deleteData() async {
    try {
      DatabaseReference ref = database.ref("users/1233");
      await ref.remove();
      print("Data deleted successfully.");
      return true;
    } catch (e) {
      print("Error deleting data: $e");
      return false;
    }
  }
}
