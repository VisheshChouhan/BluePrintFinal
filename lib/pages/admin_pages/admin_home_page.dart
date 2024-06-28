import 'package:blue_print/models/MyButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../helper_pages/connect_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        //mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 100,),
          ElevatedButton(
            onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => ConnectPage()));},
              child: Text("Connect", )
          )
        ],
      ),
    );
  }
}
