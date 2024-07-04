import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/class_tile.dart';

class ClassCollectionPage extends StatefulWidget {
  const ClassCollectionPage({super.key});

  @override
  State<ClassCollectionPage> createState() => _ClassCollectionPageState();
}

class _ClassCollectionPageState extends State<ClassCollectionPage> {
  TextEditingController _classCodeController = new TextEditingController();
  TextEditingController _classNameController = new TextEditingController();

  FirebaseFirestore db = FirebaseFirestore.instance;
  String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

  // Method to Create New class
  void createNewClass() {
    checkExistingClass();
  }

  Future checkExistingClass() async {
    var a = await db
        .collection('coordinator')
        .doc(_classCodeController.text.toString())
        .get();

    if (a.exists) {
      print('Exists');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            "Course Already exist with given Code.\nUse a different Code."),
      ));
      return a;
    }

    if (!a.exists) {
      print('Not exists');

      String classCode = _classCodeController.text.toString().trim();
      String className = _classNameController.text.toString().trim();

      if (_classCodeController.text.isNotEmpty &&
          _classNameController.text.isNotEmpty) {
        db
            .collection("coordinator")
            .doc(currentUserId)
            .collection("classes")
            .doc(classCode)
            .set({"classCode": classCode, "className": className});

        db
            .collection("classes")
            .doc(classCode)
            .set({"courseCode": classCode, "courseName": className});




        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Class Created Succesfully"),
        ));

        _classNameController.clear();
        _classCodeController.clear();


      }
      return null;
    }
  }

  void _showCreateClassDialogBox(BuildContext context) {
    // Form key for validation
    final _formKey = GlobalKey<FormState>();
    // Controllers for text fields

    // Show dialog with the form
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Class'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min, // To make the dialog box smaller
              children: <Widget>[
                TextFormField(
                  controller: _classCodeController,
                  decoration: InputDecoration(labelText: 'Enter Class Code'),
                ),
                TextFormField(
                  controller: _classNameController,
                  decoration: InputDecoration(labelText: 'Enter Class Name'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Submit'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, proceed to handle the data
                  createNewClass();

                  Navigator.of(context).pop(); // Close the dialog
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 40,
          ),
          ElevatedButton(
              onPressed: () => _showCreateClassDialogBox(context),
              child: Text("Create Class")
          ),
          const SizedBox(
            height: 25.0,
          ),
          SizedBox(
              height: 700,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("coordinator")
                            .doc(currentUserId)
                            .collection("classes")
                            .orderBy("classCode")
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<
                                QuerySnapshot<Map<String, dynamic>>>
                            snapshot) {
                          if (snapshot.hasData) {
                            return ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  final Class =
                                  snapshot.data!.docs[index];
                                  return ClassTile(
                                    courseName: Class["className"],
                                    courseCode: Class["classCode"],
                                  );
                                });
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text('Error:${snapshot.error}'),
                            );
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                    ),
                  ]
              )
          ),
        ],
      ),
    );
  }
}
