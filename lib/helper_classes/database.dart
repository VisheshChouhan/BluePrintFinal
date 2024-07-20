
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DatabaseServices{
  final String uid;
  DatabaseServices({required this.uid});

  FirebaseFirestore db = FirebaseFirestore.instance;


   Future updateUserDetails(String name, String email,String uniqueId, String phone, String department, String securityKey) async{

     debugPrint(" before Inside updateUserDetails");
     print(" before Inside updateUserDetails");

     final docRef = db.collection("security_keys").doc("security_keys");
     await docRef.get().then(
           (DocumentSnapshot doc) async {
             final data = doc.data() as Map<String, dynamic>;
             print("Data");
             print(data);

         // Registering Each one in their respective Collection in database

             if(securityKey == data["admin"].toString())
             {
               return await db.collection('users').doc(uid).set({
                 'name': name,
                 'email': email,
                 'department': department,
                 'phone': phone,
                 'uniqueId': uniqueId,
                 'role': "admin"

               });
             }
             else if(securityKey == data["coordinator"].toString())
             {
               await db.collection('coordinator').doc(uid).set({
                 'name': name,
                 'email': email,
                 'department': department,
                 'phone': phone,
                 'uniqueId': uniqueId,
                 'role' : 'coordinator'

               });

               return await db.collection('users').doc(uid).set({
                 'name': name,
                 'email': email,
                 'department': department,
                 'phone': phone,
                 'uniqueId': uniqueId,
                 'role' : 'coordinator'

               });
             }
             else if(securityKey == data["teacher"].toString())
             {

               await db.collection('teacher').doc(uniqueId).set({
                 'name': name,
                 'email': email,
                 'department': department,
                 'phone': phone,
                 'uniqueId': uniqueId,
                 'role': "teacher"

               });
               return await db.collection('users').doc(uid).set({
                 'name': name,
                 'email': email,
                 'department': department,
                 'phone': phone,
                 'uniqueId': uniqueId,
                 'role': "teacher"

               });
             }
             else
             {
               await db.collection('students').doc(uniqueId).set({
                 'studentName': name,
                 'email': email,
                 'department': department,
                 'phone': phone,
                 'studentCode': uniqueId,
                 'role': 'student'

               }, SetOptions(merge: true));
               return await db.collection('users').doc(uid).set({
                 'studentName': name,
                 'email': email,
                 'department': department,
                 'phone': phone,
                 'studentCode': uniqueId,
                 'role': 'student'

               } );
             }



       },
       onError: (e) => print("Error getting document: $e"),
     );


    // return await FirebaseFirestore.instance.collection('teachers').doc(uid).set({
    // 'name': name,
    // 'department': department,
    // 'Phone Numbers': phone,
    // });

  }


}