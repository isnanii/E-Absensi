import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:trust_location/trust_location.dart';
import 'constants.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:intl/intl.dart';
import 'package:slide_digital_clock/slide_digital_clock.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trust_location/trust_location.dart';

import 'home.dart';

//int values;

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}
enum LoginStatus { notSignIn, signIn }
class _LoginState extends State<Login> {
  TextEditingController controllernip = new TextEditingController();
  TextEditingController controllerpass = new TextEditingController();
  LoginStatus _loginStatus = LoginStatus.notSignIn;
  late String username, password;
  final _key = new GlobalKey<FormState>();
  bool _secureText = true;
  showHide() {
    if (this.mounted) {
      setState(() {
        _secureText = !_secureText;
      });
    }
  }

  check() {
    final form = _key.currentState;
    if (form!.validate()) {
      form.save();
      login();
    }
  }
  late String resultnip, resultnama, resultkantor, resultidtemplate, resultlatitude,
      resultlongitude;
  late bool resultloggedin;
  login() async {
    try {
      //EasyLoading.show();
      EasyLoading.show(status: 'Mohon tunggu...');
      //dev
      // final response = await http.post(Uri.parse("http://192.168.23.27/absensipegawai/apisimpan/loginpegawai"),
      //     body: {"nip": nip, "pass": pass});
      final Map<String, String> headerData= {
        "X-API-KEY": "@#2022"
      };
      final response = await http.post(Uri.parse("http://absensi.padangpariamankab.go.id/api-absen/api/auth", ),
          headers:headerData, body: {"username": username, "password": password});
      final data = jsonDecode(response.body);
      //int value = data['value'];
      String respon_code = data['respon_code'];

      EasyLoading.dismiss();

      if (respon_code=="Login Berhasil") {
        EasyLoading.showSuccess('Sukses Login!');
        setState(() {
           resultnip = data['result']['nip'];
           resultnama = data['result']['nama'];
           resultkantor = data['result']['kantor'];
           resultidtemplate = data['result']['id_template'];
           resultlatitude = data['result']['latitude'];
           resultlongitude = data['result']['longitude'];
           resultloggedin = data['result']['logged_in'];
          _loginStatus = LoginStatus.signIn;
          savePref(respon_code, resultnip, resultnama, resultkantor, resultidtemplate, resultlatitude,
          resultlongitude, resultloggedin);

        });
        //print(value);
        print("Respon Code: " +respon_code);
        print("Result Nip :" +resultnip);
        print("Result Nama :" +resultnama);
        print("Result Kantor :" +resultkantor);
        print("Result ID Template :" +resultidtemplate);
        print("Result Latitude :" +resultlatitude);
        print("Result Longitude :" +resultlongitude);
        print("Result logged in : $resultloggedin");
      }
      else if (respon_code=="Username Salah") {
        _showMyDialogusernamesalah();
        print("respon_code: " +respon_code);
      }
      else if (respon_code=="Password Salah") {
        _showMyDialogpasswordsalah();
        print("respon_code: " +respon_code);
      }
    } catch (e) {
      EasyLoading.showError('Periksa koneksi anda');
      print(e);
    }
  }

  Future<void> _showMyDialogusernamesalah() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Peringatan!!!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Username yang anda masukkan salah.'),
                Text('Silahkan coba kembali'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showMyDialogpasswordsalah() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Peringatan!!!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Password yang anda masukkan salah.'),
                Text('Silahkan coba kembali'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  savePref(String respon_code, String resultnip, String resultnama, String resultkantor, String resultidtemplate,
      String resultlatitude, String resultlongitude, bool resultloggedin) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      //preferences.setInt("value", value);
      preferences.setString("respon_code", respon_code);
      preferences.setString("nip", resultnip);
      preferences.setString("nama", resultnama);
      preferences.setString("kantor", resultkantor);
      preferences.setString("id_template", resultidtemplate);
      preferences.setString("latitude", resultlatitude);
      preferences.setString("longitude", resultlongitude);
      preferences.setBool("logged_in", resultloggedin);
      preferences.commit();
    });
  }

  var getrespon_code, getresultnip, getresultnama, getresultkantor, getresultidtemplate, getresultlatitude,
      getresultlongitude;
  bool? getresultloggedin;
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      //value = preferences.getInt("value");
      getrespon_code = preferences.getString("respon_code");
      getresultnip = preferences.getString("nip");
      getresultnama = preferences.getString("nama");
      getresultkantor = preferences.getString("kantor");
      getresultidtemplate = preferences.getString("id_template");
      getresultlatitude = preferences.getString("latitude");
      getresultlongitude = preferences.getString("longitude");
      getresultloggedin = preferences.getBool("logged_in");

      _loginStatus = getrespon_code == "Login Berhasil" ? LoginStatus.signIn : LoginStatus.notSignIn;
    });
  }

  signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.remove("respon_code");
      preferences.commit();
      _loginStatus = LoginStatus.notSignIn;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //print("nipoper:"+data['result']['nip']);
    getPref();
  }

  showAlertDialogg(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Tidak"),
      onPressed:  () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Ya"),
      onPressed:  () {
        Navigator.of(context).pop();
        check();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(

      title: Text("Peringatan!!"),
      content: Text("Yakin NIP Anda?"),
      actions: [
        new Text("NIP Anda : ${controllernip.text}"),
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_loginStatus) {
      case LoginStatus.notSignIn:
        return Scaffold(
          body: Form(
            key: _key,
            child: ListView(
              padding: EdgeInsets.all(20.0),
              children: <Widget>[
                Center(
                  child: Column(
                    children: <Widget>[
                      Padding(padding: EdgeInsets.only(top: 60.0),
                      ),
                      Image.asset("assets/images/icon_login.png",
                        width: 300.0,
                        height: 300.0,),
                      //_titleDescription(),
                      Padding(padding: EdgeInsets.only(top: 20.0),
                      ),
                      TextFormField(
                        controller: controllernip,
                        validator: (e) {
                          if (e!.isEmpty) {
                            return "Masukkan username";
                          }
                        },
                        onSaved: (e) => username = e!,
                        decoration: InputDecoration(
                          labelText: "Username",
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 20.0),
                      ),
                      TextFormField(
                        controller : controllerpass,
                        validator: (e) {
                          if (e!.isEmpty) {
                            return "Masukkan password";
                          }
                        },
                        obscureText: _secureText,
                        onSaved: (e) => password = e!,
                        decoration: InputDecoration(
                          labelText: "Password",
                          suffixIcon: IconButton(
                            onPressed: showHide,
                            icon: Icon(_secureText
                                ? Icons.visibility_off
                                : Icons.visibility),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 60.0),
                      ),
                      new Container(
                        padding: EdgeInsets.only(top: 15.0),
                        child: InkWell(
                          onTap: (){
                            //showAlertDialogg(context);
                            check();
                            print("Container clicked");
                            //_authenticateMe();
                          },
                          child:
                          Container(
                            margin: EdgeInsets.all(10),
                            height: 40,
                            width: 180,
                            child:
                            Container(
                              alignment: Alignment.center,
                              child: Text(
                                'Login',
                                style: TextStyle(color: Colors.white,fontSize: 20.0,),
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                        ),
                      ),
                      // RaisedButton(
                      //     color: Colors.white,
                      //     child: Text(
                      //       'Login',
                      //       style: TextStyle(color: Color(0xff5364e8)),
                      //       textAlign: TextAlign.center,
                      //     ),
                      //     onPressed: (){
                      //       check();
                      //       //check();
                      //       //Navigator.push(context,MaterialPageRoute(builder:(context)=> Homeview()));
                      //     }),
                    ],
                  ),
                ),
                // MaterialButton(
                //   onPressed: () {
                //     check();
                //   },
                //   child: Text("Login"),
                // ),
              ],
            ),
          ),
          // ),
        );
        break;
      case LoginStatus.signIn:
        return HomeScreen(signOut);
        break;
    }
  }
}

