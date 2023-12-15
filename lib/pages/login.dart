import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../shared/cached_helper.dart';
import 'homelayout.dart';

bool isShow = true;
class Login extends StatefulWidget {
  const Login({Key key}) : super(key: key);
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login>{

  final GlobalKey<FormState> fromkey = GlobalKey<FormState>();
  var PhoneController = TextEditingController();
  var PasswordController = TextEditingController();
  var fbm = FirebaseMessaging.instance;
  String fcmtoken='';



  Future login({payload})async{
    isloading = false;
    final response = await http.post(
      Uri.parse('https://api.canariapp.com/v1/partner/merchant/login'),
      body:jsonEncode(payload),
      headers:{'Content-Type':'application/json','Accept':'application/json',},
    ).then((value){
      var data = json.decode(value.body);
      print('---------------------------------------');
      print(data);
      print('---------------------------------------');
     setState(() {
       isloading = true;

      if(data['message']=='Sign In Successful'){
        Cachehelper.sharedPreferences.setInt("id",data['partner']['stores'][0]['id']).then((value){
          print('id fcm is saved');
        });

        Cachehelper.sharedPreferences.setString("token",data['token']);

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeLayout()));
      }
     });
    }).onError((error, stackTrace){
      print(error);
      setState(() {
        Fluttertoast.showToast(
            msg: error.toString(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            webShowClose:false,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      });
    });
  }

  bool isloading = true;

  @override
  Widget build(BuildContext context){
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: Form(
            key: fromkey,
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('تسجيل الدخول',style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold
                      ),),
                      SizedBox(height: 20,),
                      DefaultTextfiled(
                          controller: PhoneController,
                          keyboardType: TextInputType.emailAddress,
                          obscureText: false,
                          hintText: 'البريد الإلكتروني أو رقم الهاتف',
                          label:'البريد الإلكتروني أو رقم الهاتف',
                          prefixIcon: Icons.person
                      ),
                      SizedBox(height: 20,),
                      DefaultTextfiled(
                        controller: PasswordController,
                          onTap: (){
                            setState(() {
                              isShow =! isShow;
                            });
                          },
                          obscureText: isShow,
                          hintText: 'كلمة المرور',
                          label:'كلمة المرور',
                          prefixIcon: Icons.lock_outline_rounded,
                          suffixIcon:isShow? Icons.visibility_off_outlined:Icons.visibility
                      ),
                      //  SizedBox(height: 20,),
                     SizedBox(height: 15,),
                       GestureDetector(
                        onTap:()async{
                          setState(() {
                            isloading = false;
                            });
                          try {
                            final authcredential = await FirebaseAuth.instance.signInAnonymously();

                            if (authcredential.user != null) {
                              fbm.getToken().then((token){
                                print(token);
                                fcmtoken = token;
                                login(payload:{
                                  "email": "${PhoneController.text}",
                                  "password": "${PasswordController.text}",
                                  "device": {
                                    "token_firebase": "${token}",
                                    "device_id": "z0f33s43p4",
                                    "device_name": "iphone",
                                    "ip_address": "192.168.1.1",
                                    "mac_address": "192.168.1.1"
                                  }
                                });
                              });
                            }

                          } on FirebaseAuthException catch (e) {
                            setState(() {
                              isloading = false;
                            });
                            print("error is ${e.message}");
                          }


                        },
                        child:
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Color(0xFFfb133a)
                          ),
                          child: Center(
                            child:isloading?Text('تسجيل الدخول',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ):CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                          height: 55,
                          width: double.infinity,
                        ),
                      ),
                      SizedBox(height: 5,),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
    );
  }
  Widget DefaultTextfiled({bool obscureText,String hintText,String label,IconData prefixIcon,IconData suffixIcon,TextEditingController controller ,Function onTap,TextInputType keyboardType}){
    return TextFormField(
      keyboardType:keyboardType,
      obscureText: obscureText,
      controller:controller,
      style: TextStyle(color: Colors.black),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '${hintText} is not to be empty';
        }
        return null;
      },
      decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(
                width: 1,
                color: Colors.black,
              )),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(
                width: 1,
                color: Colors.black,
              )),
          hintText: hintText,

          label: Text(label),
          prefixIcon:prefixIcon!=null? Icon(prefixIcon):null,
          suffixIcon: suffixIcon!=null? GestureDetector(
              onTap:onTap,
              child: Icon(suffixIcon)):null,
          hintStyle: TextStyle(
            color: Color(0xFF7B919D),
          )),
    );
  }
}
