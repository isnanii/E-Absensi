import 'dart:ffi';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:async';

import 'main.dart';


class SplashScreenView extends StatefulWidget{
  @override
  _SplashScreenPageState createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenView>{
  @override
  void initState(){
    super.initState();
    startSplashScreen();
  }
  startSplashScreen() async{
    var duration = const Duration(seconds: 5);
    return Timer(duration, (){
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_){

        return MyApp(); //pergi ke halaman dashboard

      }),

      );

    });

  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.blue.shade300,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Icon(
            //    Icons.app_registration,
            //   size: 100.0,
            //   color: Colors.white,
            // ),
            Padding(padding: EdgeInsets.only(top: 50.0),
            ),
            Image.asset("assets/images/pemkab.png",
              width: 200.0,
              height: 200.0,),
            Padding(padding: EdgeInsets.only(top: 80.0),
            ),
            Text("ABSENSI PEGAWAI",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 40.0,
            ),),

            Text("Kabupaten Padang Pariaman",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
              ),),
            Padding(padding: EdgeInsets.only(top: 280.0),
            ),
            Text("v 0.1",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.0,
              ),)

          ],
        ),
      ),
        // backgroundColor: Color(0xff329cef),
        // body: Center(
        //   child: Image.asset("images/bag.jpg",
        //   width: 200.0,
        //   height: 100.0,),
        // ),
    );
  }
}