import 'dart:io';
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


class HomeScreen extends StatefulWidget {
  final VoidCallback signOut;
  HomeScreen(this.signOut);
  @override
  _HomeScreen createState() => _HomeScreen();
}
class _HomeScreen extends State <HomeScreen>{
  bool _disposed = false;
  bool? _isMockLocation;
  String? _latitude;
  String? _longitude;
  double? lat2, long2;
  var pagemasuk = "masuk";
  var pagepulang = "pulang";
  var tombol;
  bool? bisaabsen;

  signOut() {
    if (this.mounted) {
      setState(() {
        widget.signOut();
      });
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void initState() {
    getPref();
    getbulan();
    getevent();
    requestLocationPermission();
    getLocation();
    print("getresultnipnya:$getresultnips");
    super.initState();
  }

  Location LocationPermissions = Location();
  void requestLocationPermission() async {
    PermissionStatus permission =
    await LocationPermissions.requestPermission();
    print('permissions: $permission');
  }


  var getrespon_codes, getresultnips, getresultnamas, getresultkantors, getresultidtemplates, getresultlatitudes,
      getresultlongitudes;
  late bool getresultloggedins;
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      //values = preferences.getInt("value");
      getrespon_codes = preferences.getString("respon_code");
      getresultnips = preferences.getString("nip");
      getresultnamas = preferences.getString("nama");
      getresultkantors = preferences.getString("kantor");
      getresultidtemplates = preferences.getString("id_template");
      getresultlatitudes = preferences.getString("latitude");
      getresultlongitudes = preferences.getString("longitude");
      getresultloggedins = preferences.getBool("logged_in")!;
      //print(values);
      print("respon_codes : "+getrespon_codes);
      print("nips : " +getresultnips);
      print("namas : "+getresultnamas);
      print("kantors : "+getresultkantors);
      print("id_templates : "+getresultidtemplates);
      print("latitudes : "+getresultlatitudes);
      print("longitudes : "+getresultlongitudes);
      print("logged ins : $getresultloggedins");
    });
  }

  Future<void> getLocation() async {

    try {
      TrustLocation.start(1);
      TrustLocation.onChange.listen((values) => setState(() {
        double calculateDistance(lat1, lon1, lat2, lon2){
          var p = 0.017453292519943295;
          var c = cos;
          var a = 0.5 - c((lat2 - lat1) * p)/2 +
              c(lat1 * p) * c(lat2 * p) *
                  (1 - c((lon2 - lon1) * p))/2;
          return 1000 * 12742 * asin(sqrt(a));
        }
        double latt = double.parse(getresultlatitudes);
        double longg = double.parse(getresultlongitudes);
        double lat2 = double.parse(values.latitude!);
        double long2 = double.parse(values.longitude!);
        List<dynamic> data = [
          {
            "lat":latt,
            "lng":longg
          },
          {
            "lat":lat2,
            "lng":long2
          }
        ];
        double totalDistance = 0;
        for(var i = 0; i < data.length-1; i++){
          totalDistance += calculateDistance(data[i]["lat"], data[i]["lng"], data[i+1]["lat"], data[i+1]["lng"]);
        }
        print("total :  $totalDistance");
        print("latt :  $latt");
        print("longg :  $longg");
        print("lat2 :  "+values.latitude!);
        print("long2 : "+values.longitude!);

        _isMockLocation = values.isMockLocation!;
        if(_isMockLocation== true)
        {
          _alertlokasipalsu();
          TrustLocation.stop();
        }
        if(totalDistance<=100.0) {
          setState(() {
            bisaabsen=true;
            TrustLocation.stop();
          });
          //addDatamasuk();

        }


      }));

    } on PlatformException catch (e) {
      print('PlatformException $e');
    }

    //_isMockLocation==true?_alertlokasipalsu():_alertlokasiakurat();
  }

  void addData() async{
    String tgl;
    var inout;
    final DateTime now = DateTime.now();
    var a = now.day;
    var b = now.month;
    var c = now.year;
    var d = now.hour;
    var e = now.minute;
    var f = now.second;
    if(tombol=="tombolmasuk"){
     inout= "in";
    }
    else if(tombol=="tombolpulang"){
      inout= "out";
    }
    tgl='$c-$b-$a $d:$e:$f';
    print("getresultnipdiadd:$getresultnips");
    try{
      EasyLoading.show(status: 'Mohon tunggu...');
      final Map<String, String> headerData= {
        "X-API-KEY": "@#2022"
      };
      final responsee = await http.post(Uri.parse("http://absensi.padangpariamankab.go.id/api-absen/api/checkinout"),
          headers:headerData,
          body: {
            "nip" : getresultnips,
            "id_template" : getresultidtemplates,
            "inout": inout

          });
      final data = jsonDecode(responsee.body);
      print('---- status code: ${responsee.statusCode}');
      String respon_code = data['respon_code'];
      print("respon code nya : " +respon_code);
      print(responsee);
      EasyLoading.dismiss();
      if(responsee.statusCode==200){
        print("Finger Berhasil");
        _showMyDialogsuksesabsensi(respon_code);
      }
      else{
        _showMyDialoggagalabsensi(respon_code);
      }
    } catch (e) {
      EasyLoading.showError('Periksa koneksi anda');
      print(e);
    }
  }

  List<dynamic> _datagetevent = [];
  void getevent() async {
    String tgl;
    print("getresultnipe:$getresultnips");
    final DateTime now = DateTime.now();
    var a = now.day;
    var b = now.month;
    var c = now.year;
    var d = now.hour;
    var e = now.minute;
    var f = now.second;
    tgl='$c-$b-$a';
    try{
      EasyLoading.show(status: 'Mohon tunggu...');
      var uri = Uri.parse('http://absensi.padangpariamankab.go.id/api-absen/api/checkkordinat');
      uri = uri.replace(query: 'nip=$getresultnips&tanggal=$tgl&X-API-KEY=@#2022');
      var response = await http.get(uri, headers: {
        HttpHeaders.contentTypeHeader: "application/json",
      }
      );
      print(uri);
      print(response);
      final listDatacari = jsonDecode(response.body);
      String respon_code_event = listDatacari['respon_code'];
      EasyLoading.dismiss();
      respon_code_event == "Gunakan Kordinat lainya" ? showdialogevent():Fluttertoast.showToast(
          msg: "Tidak ada event hari ini",  // message
          toastLength: Toast.LENGTH_SHORT, // length
          gravity: ToastGravity.CENTER,    // location
          timeInSecForIosWeb: 1               // duration
      );
    } catch (e) {
      EasyLoading.showError('Periksa koneksi anda');
      print(e);
    }
  }

  static final DateTime now = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
  var a = now.day;
  var b = now.month;
  var c = now.year;

  var cc;
  getbulan(){
    List months =
    ['Januari', 'February', 'Maret', 'April', 'May','Juni','Juli','Agustus','September','Oktober','November','Desember'];
    var now = new DateTime.now();
    var current_mon = now.month;
    cc = months[current_mon-1];
    print(cc);
  }

  Future<void> _alertlokasipalsu() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Peringatan!!!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Anda telah mengaktifkan lokasi palsu, matikan lokasi palsu anda!!!'),
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

  Future<void> _alerttidakdisekitarkantor() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Peringatan!!!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Anda tidak bisa absensi karena tidak berada disekitar kantor!!!'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                TrustLocation.stop();
                //distance();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showMyDialogsuksesabsensi(String respon_code) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Info!!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('$respon_code'),
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

  Future<void> _showMyDialoggagalabsensi(String respon_code) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Info!!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('$respon_code'),
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

  Future<AlertDialog?> myDialogkeluar(BuildContext context) {
    return showDialog<AlertDialog>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            margin: EdgeInsets.all(8.0),
            child: Form(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text("Yakin Ingin Keluar?"),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Tidak")),
            FlatButton(
                onPressed: () {
                  signOut();
                  Navigator.of(context).pop();
                },
                child: Text("Ya"))
          ],
        );
      },
    );
  }

  Future<void> showdialogevent() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Info!!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Hari ini adalah jadwal event bla bla bla silahkan lakukan absen di lokasi event!!'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(),
        body :
        Container(
            child: Column(
                children: <Widget>[
                  Flexible(
                      flex: 1,
                      child: Container(
                          color: Colors.blue.shade300,
                          child:
                          Align(
                              alignment: Alignment.center,
                              child:
                              Container(
                                // where to position the child
                                  child: new Column(
                                      children: [
                                        //Digit(),
                                        DigitalClock(
                                          areaAligment: AlignmentDirectional.center,
                                          hourMinuteDigitTextStyle: TextStyle(
                                            color: Colors.white,
                                            fontSize: 50,
                                          ),
                                          secondDigitTextStyle: TextStyle(
                                            color: Colors.white,
                                            fontSize: 50,
                                          ),
                                          areaHeight: 90.0,
                                          areaWidth: 270.0,
                                          areaDecoration: BoxDecoration(
                                            color: Colors.blue.shade300,
                                            borderRadius: BorderRadius.circular(12),),
                                        ),
                                        Container(
                                          margin: EdgeInsets.all(10),
                                          //margin: EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
                                          height: 40,
                                          width: 270,
                                          child: Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
                                            child: Text(
                                              '$a  $cc $c',
                                              style: TextStyle(color: Colors.white,fontSize: 25.0,),
                                            ),
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.4),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        Padding(padding: EdgeInsets.only(top: 20),),
                                      ]))))),
                  Flexible(
                      flex: 1,
                      child: Container(
                          color: Colors.blue.shade300,
                          child:
                          Align(
                            alignment: Alignment.center,
                            child:
                            Container(
                              // where to position the child
                              child: new Column(
                                children: [
                                  Expanded(
                                    child:
                                    Stack(
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(
                                            left: 20.0, right : 15.0,
                                          ),
                                          // color: Colors.blueAccent,
                                          height: 160,
                                          child: InkWell(
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: <Widget>[
                                                // Those are our background
                                                Container(
                                                  child: Container(
                                                    //margin: EdgeInsets.only(right: 10),
                                                    decoration: BoxDecoration(
                                                      boxShadow: [kDefaultShadow],
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(22),
                                                    ),
                                                  ),
                                                ),
                                                // our product image
                                                // Product title and price
                                                Positioned(
                                                  child: SizedBox(
                                                    height: 120,
                                                    // our image take 200 width, thats why we set out total width - 200
                                                    //width: size.width - 200,
                                                    child: Column(
                                                      children: <Widget>[
                                                        Text(
                                                          'Selamat Datang,',
                                                          style:
                                                          TextStyle(
                                                              fontSize: 25, fontFamily: "Serif", height: 1.5),
                                                        ),
                                                        Text(
                                                          '$getresultnamas',
                                                          style:
                                                          TextStyle(
                                                              fontSize: 20, fontFamily: "Serif", height: 1.5),
                                                        ),
                                                        Text(
                                                          'NIP : $getresultnips',
                                                          style:
                                                          TextStyle(
                                                              fontSize: 20, fontFamily: "Serif", height: 1.5),
                                                        ),
                                                        // it use the available space
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          //margin: EdgeInsets.only(top: 40),

                                        ),

                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [kDefaultShadoww],
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(100),
                                  topRight: Radius.circular(100),
                                ),
                              ),
                            ),
                          ))),
                  Flexible(
                      flex: 1,
                      child:
                      Align(
                          alignment: Alignment.center,
                          child:
                          Container(
                              color: Colors.white,
                              child:
                              Center(
                                  child:
                                  Column(
                                      children: <Widget>[
                                        Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Flexible(
                                                  flex: 1,
                                                  child:
                                                  Align(
                                                    alignment: Alignment.topCenter,
                                                    child:
                                                    new Container(
                                                      child: InkWell(
                                                        onTap: (){
                                                          print("Container clicked");
                                                          setState(() {
                                                            tombol = "tombolmasuk";
                                                          });
                                                          //getLocationmasuk();
                                                          if(bisaabsen==true){
                                                            addData();
                                                          }
                                                          else{
                                                            _alerttidakdisekitarkantor();
                                                          }
                                                          // Navigator.push(
                                                          //     context,
                                                          //     MaterialPageRoute(builder: (context) => Jenisabsen(nippeg: getresultnips, idtemplatepeg : getresultidtemplates, lat : getresultlatitudes, long : getresultlongitudes, page: pagemasuk))
                                                          // );
                                                        },
                                                        child:
                                                        Container(
                                                          //margin: EdgeInsets.all(10),
                                                          height: 80,
                                                          width: 150,
                                                          child:
                                                          Container(
                                                            alignment: Alignment.center,
                                                            child:
                                                            Text(
                                                              'Absen Masuk',
                                                              style: GoogleFonts.mcLaren(textStyle : TextStyle(color: Colors.white,fontSize: 20.0,),
                                                              ),
                                                            ),
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color: Colors.blue.shade300,
                                                            boxShadow: [kDefaultShadowww],
                                                            borderRadius: BorderRadius.circular(22),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )),
                                              Flexible(
                                                  flex: 1,
                                                  child:
                                                  Align(
                                                    alignment: Alignment.topCenter,
                                                    child:
                                                    new Container(
                                                      child: InkWell(
                                                        onTap: (){
                                                          print("Container clicked");
                                                          setState(() {
                                                            tombol = "tombolpulang";
                                                          });
                                                          if(bisaabsen==true){
                                                            addData();
                                                          }
                                                          else{
                                                            _alerttidakdisekitarkantor();
                                                          }
                                                          //getLocationmasuk();
                                                          // Navigator.push(
                                                          //     context,
                                                          //     MaterialPageRoute(builder: (context) => Jenisabsen(nippeg: getresultnips, lat : getresultlatitudes, long : getresultlongitudes, page: pagemasuk))
                                                          // );
                                                        },
                                                        child:
                                                        Container(
                                                          //margin: EdgeInsets.all(10),
                                                          height: 80,
                                                          width: 150,
                                                          child:
                                                          Container(
                                                            alignment: Alignment.center,
                                                            child:
                                                            Text(
                                                              'Absen Pulang',
                                                              style: GoogleFonts.mcLaren(textStyle : TextStyle(color: Colors.white,fontSize: 20.0,),
                                                              ),
                                                            ),
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color: Colors.blue.shade300,
                                                            boxShadow: [kDefaultShadowww],
                                                            borderRadius: BorderRadius.circular(22),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )),
                                            ]),
                                        Container(height:10.0),
                                        Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Flexible(
                                                  flex: 1,
                                                  child:
                                                  Align(
                                                    alignment: Alignment.bottomCenter,
                                                    child:
                                                    new Container(
                                                      child: InkWell(
                                                        onTap: (){
                                                          print("Container clicked");
                                                          //getlocationnyaabsenmasuk();
                                                          // Navigator.push(
                                                          //     context,
                                                          //     MaterialPageRoute(builder: (context) => Pilihabsensi(nippeg: getresultnips, page: pagepulang))
                                                          // );
                                                        },
                                                        child:
                                                        Container(
                                                          //margin: EdgeInsets.all(10),
                                                          height: 80,
                                                          width: 150,
                                                          child:
                                                          Container(
                                                            alignment: Alignment.center,
                                                            child:
                                                            Text(
                                                              'Ajukan Cuti',
                                                              style: GoogleFonts.mcLaren(textStyle : TextStyle(color: Colors.white,fontSize: 20.0,),
                                                              ),
                                                            ),
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color: Colors.blue.shade300,
                                                            boxShadow: [kDefaultShadowww],
                                                            borderRadius: BorderRadius.circular(22),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )),
                                              Flexible(
                                                  flex: 1,
                                                  child:
                                                  Align(
                                                    alignment: Alignment.bottomCenter,
                                                    child:
                                                    new Container(
                                                      child: InkWell(
                                                        onTap: (){
                                                          print("Container clicked");
                                                          //getlocationnyaabsenmasuk();
                                                          // Navigator.push(
                                                          //     context,
                                                          //     MaterialPageRoute(builder: (context) => Pilihabsensi(nippeg: getresultnips, page: pagepulang))
                                                          // );
                                                        },
                                                        child:
                                                        Container(
                                                          //margin: EdgeInsets.all(10),
                                                          height: 80,
                                                          width: 150,
                                                          child:
                                                          Container(
                                                            alignment: Alignment.center,
                                                            child:
                                                            Text(
                                                              'E-Kinerja',
                                                              style: GoogleFonts.mcLaren(textStyle : TextStyle(color: Colors.white,fontSize: 20.0,),
                                                              ),
                                                            ),
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color: Colors.blue.shade300,
                                                            boxShadow: [kDefaultShadowww],
                                                            borderRadius: BorderRadius.circular(22),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )),
                                            ]
                                        ),
                                        Container(height:30.0),
                                        Flexible(
                                          flex: 1,
                                          child:
                                          Align(
                                            alignment: Alignment.bottomCenter,
                                            child:
                                            Text(
                                              'Copyright Diskominfo Padang Pariaman',
                                              style: GoogleFonts.mcLaren(textStyle : TextStyle(fontSize: 10.0,),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]))))),
                ])));
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.blue.shade300,
      elevation: 0,
      centerTitle: false,
      title: Text('Absensi', style: TextStyle(color: Colors.white, fontFamily: 'RobotoMono'),),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.lock_open),
          color: Colors.white,
          onPressed: () {
            myDialogkeluar(context);
            //showAlertDialog(context);
            //signOut();
          },
        ),
      ],
    );
  }

}