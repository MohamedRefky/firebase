import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // ============================================
  // Firestore - Update Data
  // ============================================
  Future<void> updateData() async {
    try {
      final db = FirebaseFirestore.instance;
      final data = db.collection("cities").doc("CA");

      // update: updates fields only, document must exist
      // if document does not exist, it will throw an error
      await data.update({
        "name": "Hong Kong",
        "state": "France",
        "country": "Belgium",
        "capital": true,
        "population": 200000,
      });
    } catch (e) {
      print("Error updating data: $e");
    }
  }

  Future<void> setDataWithMerge() async {
    try {
      final db = FirebaseFirestore.instance;

      // set with merge: adds document if not exists, updates fields if exists
      await db.collection("cities").doc("BJ").set({
        "name": "Hong Kong",
        "state": "France",
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error setting data: $e");
    }
  }

  Future<void> readData() async {
    try {
      final db = FirebaseFirestore.instance;
      final doc = await db.collection("cities").doc("CA").get();

      // check if document exists
      if (doc.exists) {
        var data = doc.data();
        // print all data
        print(data);
        // print specific data
        print(data!["name"]);
      } else {}
    } catch (e) {
      print("Error reading data: $e");
    }
  }

  Future<void> deleteData() async {
    try {
      final db = FirebaseFirestore.instance;

      // delete: removes  document from collection
      // if document does not exist, no error will occur
      await db.collection("cities").doc("CA").delete();

      // delete field: removes field from document
      // await db.collection("cities").doc("Eg").update({
      //   "country": FieldValue.delete(),
      // });
    } catch (e) {
      print("Error deleting data: $e");
    }
  }

  Future<void> transaction() async {
    final db = FirebaseFirestore.instance;
    final docRef = db.collection("cities").doc("Eg");

    try {
      await db.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          // لو الـ document مش موجود
          throw Exception("Document does not exist!");
        }

        // لو field مش موجود نخلي default 0
        int currentPopulation = 0;
        if (snapshot.data()!.containsKey("population")) {
          currentPopulation = snapshot.get("population");
        }

        transaction.update(docRef, {"population": currentPopulation + 1});
        transaction.update(docRef, {"DateTime": DateTime.now()});
      });
    } catch (e) {
      print("Error updating data: $e");
    }
  }

  Future<void> realtimeUpdate() async {
    final db = FirebaseFirestore.instance;
    final docRef = db.collection("cities").doc("Eg");

    // Listen to realtime updates
    docRef.snapshots().listen((snapshot) {
      if (snapshot.exists) {
      } else {}
    });
  }
}
