import 'package:flutter/material.dart';
import '../shared/cached_helper.dart';

class Orders extends StatefulWidget {
  const Orders({Key key}) : super(key: key);

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  @override
  Widget build(BuildContext context) {
    String token = Cachehelper.getData(key: "token");
    return Scaffold(
      backgroundColor: Color(0xfff3f4f6),
      appBar: AppBar(
        backgroundColor: Color(0xfff3f4f6),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('الطلبات اليوم',style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20
        ),),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body:SafeArea(
        child: Column(
          children: [

          ],
        )
      ),
    );
  }
}
