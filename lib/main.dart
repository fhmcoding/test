import 'dart:convert';
import 'package:backofficeapp/pages/homelayout.dart';
import 'package:backofficeapp/pages/login.dart';
import 'package:backofficeapp/pages/summry.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'shared/cached_helper.dart';

Future<void> backgroundMessageHandler(RemoteMessage message){
  Fluttertoast.showToast(
      msg: "main",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      webShowClose:false,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0
  );
}


FirebaseMessaging messaging = FirebaseMessaging.instance;


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureFirebaseMessaging();
  Cachehelper.init();
  await Firebase.initializeApp();
  messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  String token = Cachehelper.getData(key: "token");
  Widget widget;

    if(token!= null) widget = HomeLayout();
    else widget = Login();

  runApp(MyApp(startWidget:widget,));
}

void configureFirebaseMessaging() {
  FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);
}

class MyApp extends StatefulWidget{
  final Widget startWidget;
  const MyApp({Key key,this.startWidget}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    FirebaseMessaging.instance.getInitialMessage();

    FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);
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

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      Fluttertoast.showToast(
          msg: "open app",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          webShowClose:false,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
       // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Home()), (route) => route.isFirst);

      // if (message.notification!=null){
      //   Map<String, dynamic> jsonMap = jsonDecode(message.data['payload']);
      //   final order_ref = jsonMap['id'];
      //   showModalBottomSheet(
      //       backgroundColor: Color(0xFFfb133a),
      //       enableDrag: false,
      //       isDismissible: false,
      //       isScrollControlled: true,
      //       context: context, builder: (context){
      //     return Summry(order_ref: order_ref,);
      //   });
      // }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Canari Merchants',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home:widget.startWidget,
    );
  }
}

