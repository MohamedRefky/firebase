// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  // ============================================
  // Google Sign In
  // ============================================
  Future<UserCredential?> signInWithGoogle() async {
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId:
            "589498492064-rrs2gbi82p5g2jol2lp77aal425fn3h7.apps.googleusercontent.com",
      );

      final GoogleSignInAccount googleSignInAccount = await GoogleSignIn
          .instance
          .authenticate(scopeHint: ["email"]);

      final GoogleSignInAuthorizationClient authenticationClient =
          googleSignInAccount.authorizationClient;

      GoogleSignInClientAuthorization? auth = await authenticationClient
          .authorizationForScopes(["email"]);
      auth ??= await authenticationClient.authorizationForScopes(["email"]);

      GoogleSignInAuthentication newAuth = googleSignInAccount.authentication;
      print('ID Token: ${newAuth.idToken}');
      print('Access Token: ${auth!.accessToken}');

      final credential = GoogleAuthProvider.credential(
        idToken: newAuth.idToken,
        accessToken: auth.accessToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print('Google Sign In Error: $e');
      return Future.error(e);
    }
  }

  // ============================================
  // Email & Password - Create Account
  // ============================================
  Future<UserCredential?> createUserWithEmailAndPassword(
    String emailAddress,
    String password,
  ) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailAddress,
            password: password,
          );
      print('Account created successfully!');
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
      return Future.error(e);
    } catch (e) {
      print('Create Account Error: $e');
      return Future.error(e);
    }
  }

  // ============================================
  // Email & Password - Sign In
  // ============================================
  Future<UserCredential?> signInWithEmailAndPassword(
    String emailAddress,
    String password,
  ) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      print('Signed in successfully!');
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
      return Future.error(e);
    }
  }

  // ============================================
  // Phone Number Verification
  // ============================================
  Future<void> verifyPhoneNumber(String phoneNumber) async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          print('Verification completed: $credential');
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          print("Verification ID: $verificationId");
          print("Resend Token: $resendToken");
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print("Auto retrieval timeout: $verificationId");
        },
      );
    } catch (e) {
      print('Phone verification error: $e');
      return;
    }
  }

  // ============================================
  // Anonymous Sign In
  // ============================================
  Future<UserCredential?> signInAnonymously() async {
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      print("Signed in with temporary account.");
      return userCredential;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "operation-not-allowed":
          print("Anonymous auth hasn't been enabled for this project.");
          break;
        default:
          print("Unknown error: ${e.message}");
      }
      return Future.error(e);
    }
  }

  // ============================================
  // Convert Anonymous to Permanent Account
  // ============================================
  Future<UserCredential?> convertAnonymouslyToPermanentAccount(
    String emailAddress,
    String password,
  ) async {
    final credential = EmailAuthProvider.credential(
      email: emailAddress,
      password: password,
    );
    try {
      final userCredential = await FirebaseAuth.instance.currentUser
          ?.linkWithCredential(credential);
      print("Account converted to permanent successfully!");
      return userCredential;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "provider-already-linked":
          print("The provider has already been linked to the user.");
          break;
        case "invalid-credential":
          print("The provider's credential is not valid.");
          break;
        case "credential-already-in-use":
          print("The account already exists with a different credential.");
          break;
        default:
          print("Unknown error: ${e.message}");
      }
      return Future.error(e);
    }
  }

  // ============================================
  // GitHub Sign In
  // ============================================
  Future<UserCredential> signInWithGitHub() async {
    try {
      GithubAuthProvider githubProvider = GithubAuthProvider();
      return await FirebaseAuth.instance.signInWithProvider(githubProvider);
    } catch (e) {
      print('GitHub Sign In Error: $e');
      return Future.error(e);
    }
  }

  // ============================================
  // Firestore - Add Data
  // ============================================
  Future<void> addData() async {
    try {
      await FirebaseFirestore.instance.collection("cities").doc("CA").set({
        "name": "Egypt",
        "state": "Cairo",
        "country": "Egypt",
        "capital": true,
        "population": 100000,
        "DateTime": DateTime.now(),
      });
      print("Data added successfully.");
    } catch (e) {
      print("Error adding data: $e");
    }
  }

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

      print("Document updated successfully!");
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

      print("Document added/merged successfully!");
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
        print("Document data: $data");
        // print specific data
        print("Name: ${data?["name"]}");
      } else {
        print("Document does not exist");
      }
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

      print("Document deleted successfully!");
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

      print("Transaction completed successfully!");
    } catch (e) {
      print("Error in transaction: $e");
    }
  }

  Future<void> realtimeUpdate() async {
    final db = FirebaseFirestore.instance;
    final docRef = db.collection("cities").doc("Eg");

    // Listen to realtime updates
    docRef.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        print("Realtime data: ${snapshot.data()}");
      } else {
        print("Document does not exist");
      }
    });
  }
}
