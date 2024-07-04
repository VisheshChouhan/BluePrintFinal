import 'package:blue_print/pages/coordinator_pages/class_collection_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CoordinatorHomePage extends StatefulWidget {
  const CoordinatorHomePage({super.key});

  @override
  State<CoordinatorHomePage> createState() => _CoordinatorHomePageState();
}

class _CoordinatorHomePageState extends State<CoordinatorHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 40,),
          Text("Coordinator Name here"),
          SizedBox(height: 40,),
          ElevatedButton(onPressed: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=> ClassCollectionPage()));
          }, child: Text("All Classes"))

        ],
      ),
    );
  }
}
