import 'dart:async';
import 'dart:convert';
import 'package:backofficeapp/pages/summry.dart';
import 'package:backofficeapp/pages/transactions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../shared/cached_helper.dart';
import 'package:http/http.dart' as http;
import 'menus.dart';
import 'orders.dart';


Future<void>firebaseMessagingBackgroundHandler(RemoteMessage message)async{
  if (message.notification!=null) {
    print('firebaseMessagingBackgroundHandler');
  }
}



class HomeLayout extends StatefulWidget {
  const HomeLayout({Key key}) : super(key: key);
  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}
class _HomeLayoutState extends State<HomeLayout> {
  int id = Cachehelper.getData(key: "id");
  String storeStatus ;
  bool isLoading = false;
  bool switchValue = true;
  var fbm = FirebaseMessaging.instance;
  String token = Cachehelper.getData(key: "token");
  int  SelectedIndex = 0;
  List<Widget>screens=[
    Orders(),
    Menus(),
    Transaction()
  ];

  Future getStoreData() async{
    isLoading = false;
    final response = await http.get(
      Uri.parse('https://api.canariapp.com/v1/partner/merchant/stores'),
      headers:{
        'Authorization':'Bearer ${token}',
        'Accept':'application/json',
      },

    ).then((value){
      var stores = json.decode(value.body);
      isLoading = true;
      print(stores['data'][0]['working_status']);
       storeStatus = stores['data'][0]['working_status'];
      Cachehelper.sharedPreferences.setString("storeStatus",stores['data'][0]['working_status']);
      setState(() {

      });
    }).onError((error,stackTrace){
      print(error);
    });
    return response;
  }

  Future UpdateStatus({working_status})async{
    print(working_status);
    final response = await http.put(
        Uri.parse('https://api.canariapp.com/v1/partner/merchant/stores/${id}'),
        headers:{
          'Authorization':'Bearer ${token}',
          'Accept':'application/json',
        },
        body:{
          'working_status':'${working_status}'
        }
    ).then((value){
      var data = json.decode(value.body);
      print(data);
    }).onError((error,stackTrace){
      print(error);
    });
    return response;
  }





    @override
  void initState(){
    getStoreData();

    FirebaseMessaging.instance.getInitialMessage();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((message){
      if (message.notification!=null){
         Map<String, dynamic> jsonMap = jsonDecode(message.data['payload']);
          final order_ref = jsonMap['id'];
        showModalBottomSheet(
          backgroundColor: Color(0xFFfb133a),
            enableDrag: false,
            isDismissible: false,
            isScrollControlled: true,
            context: context, builder: (context){
          return Summry(order_ref: order_ref,);
            });
      }
    },);
    fbm.getToken();
    super.initState();
  }


  @override
  Widget build(BuildContext context){
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar:AppBar(
          backgroundColor:isLoading?storeStatus=='close'?Colors.red:Colors.green:Colors.grey[300],
          elevation: 0,
          title: Padding(
            padding: const EdgeInsets.only(top: 9,right: 8),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  isLoading? Text(' (${storeStatus=='close'?"مغلق":"مفتوح"})',style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                  ),):SizedBox(height: 0),
                  Text(' حالة مطعم',style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                  ),),
                ],
              ),
            ),
          ),
          actions: [
            isLoading? Padding(
              padding: const EdgeInsets.only(left: 25),
              child: CupertinoSwitch(
                value:storeStatus=='close'?false:true,
                onChanged: (bool value) {
                  setState((){
                    switchValue = value ?? false;
                    storeStatus = switchValue?'open':'close';
                    Cachehelper.sharedPreferences.setString("storeStatus",storeStatus).then((value) {
                      print('status saved');
                    });
                    UpdateStatus(working_status:storeStatus);
                  });
                },
              ),
            ):SizedBox(height: 0),
          ],
        ),
          bottomNavigationBar: BottomNavigationBar(
              showSelectedLabels: true,
              selectedItemColor:Colors.red,
              type: BottomNavigationBarType.fixed,
              onTap: (index){
                setState(() {
                  SelectedIndex = index;
                });
              },
              currentIndex: SelectedIndex,
              items: [
                BottomNavigationBarItem(icon:Icon(Icons.sticky_note_2_outlined), label: 'الطلبات'),
                BottomNavigationBarItem(icon:Icon(Icons.delivery_dining_outlined), label: 'تسليمات'),
                BottomNavigationBarItem(icon:Icon(Icons.timer_outlined),label: 'ساعات'),
              ]),
        body:screens[SelectedIndex]
      ),
    );
  }
}
