import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:trust_location/trust_location.dart';
import 'constants.dart';
import 'dart:math' show cos, sqrt, asin;

class Jenisabsen extends StatefulWidget {
  String nippeg = "";
  String idtemplatepeg = "";
  String dapatabsen="";
  String ipadd = "";
  String lat = "";
  String long = "";
  String page = "";
  Jenisabsen({Key? key, required this.nippeg, required this.idtemplatepeg, required this.ipadd,
    required this.lat, required this.long, required this.page}):
        super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _Jenisabsen();
  }
}

class _Jenisabsen extends State<Jenisabsen> {
  late String _latitude, _longitude;
  late double lat2, long2;
  late bool _isMockLocation;
   String? _valJenisshift, _valJenisabsensi, _valJenisabsenlain, idjenisabsen, idjenisshift, idjenisabsenlain;
  bool _isVisibleshift = false;
  bool _isVisibleabsenjenislain = false;
  List<dynamic> _dataJenisabsensi= [];
  List<dynamic> _dataJenisshift= [];
  List<dynamic> _dataJenisabsenlain= [];
  @override
  void initState() {
    getJenisabsensi();
    getJenisshift();
    getJenisabsenlain();
    //checkversion();
    //distance();
    print("Page:" +widget.page);
    requestLocationPermission();
    TrustLocation.start(5);
    //getLocationn();
    getLocation();
    // print("lat: "+widget.lat);
    // print("long: "+widget.long);
    super.initState();
  }
  void getJenisshift() async {
    try {
      EasyLoading.show();
      //final response = await http.get("http://192.168.43.195/apisave/apisimpan/getpuskesmas"); //untuk melakukan request ke webservice
      final response = await http.get(Uri.parse("http://192.168.23.27/absensipegawai/apisimpan/getjenisshift")); //untuk melakukan request ke webservice
      final listData = jsonDecode(response.body); //lalu kita decode hasil datanya
      setState(() {
        _dataJenisshift = listData;
      });
      print("data : $listData");
      EasyLoading.dismiss();
    } catch (e) {
      EasyLoading.showError('Periksa koneksi anda');
      print(e);
    }
  }
  void getJenisabsensi() async {
    try {
      EasyLoading.show();
    //final response = await http.get("http://192.168.43.195/apisave/apisimpan/getpuskesmas"); //untuk melakukan request ke webservice
    final response = await http.get(Uri.parse("http://192.168.23.27/absensipegawai/apisimpan/getjenisabsen")); //untuk melakukan request ke webservice
    final listData = jsonDecode(response.body); //lalu kita decode hasil datanya
    setState(() {
      _dataJenisabsensi = listData;
    });
    print("data : $listData");
      EasyLoading.dismiss();
    } catch (e) {
      EasyLoading.showError('Periksa koneksi anda');
      print(e);
    }
  }
  void getJenisabsenlain() async {
    try {
      EasyLoading.show();
      //final response = await http.get("http://192.168.43.195/apisave/apisimpan/getpuskesmas"); //untuk melakukan request ke webservice
      final response = await http.get(Uri.parse("http://192.168.23.27/absensipegawai/apisimpan/getjenisabsenlain")); //untuk melakukan request ke webservice
      final listData = jsonDecode(response.body); //lalu kita decode hasil datanya
      setState(() {
        _dataJenisabsenlain = listData;
      });
      print("data : $listData");
      EasyLoading.dismiss();
    } catch (e) {
      EasyLoading.showError('Periksa koneksi anda');
      print(e);
    }
  }

  Future<void> getLocation() async {
      // Use location.
      try {
        TrustLocation.onChange.listen((values) =>
            setState(() {
              _latitude = values.latitude!;
              _longitude = values.longitude!;
              _isMockLocation = values.isMockLocation!;
              _isMockLocation == true
                  ? print("Anda Menggunakan Lokasi Palsu")
                  : print("Lokasi anda akurat");
              print('Mock Location: $_isMockLocation');
              print('Latitude: $_latitude, Longitude: $_longitude');
            }));
      } on PlatformException catch (e) {
        print('PlatformException $e');
      }

  }
  Location LocationPermissions = Location();

  //request location permission at runtime.
  void requestLocationPermission() async {
    PermissionStatus permission =
    await LocationPermissions.requestPermission();
    print('permissions: $permission');
  }

  Future<void> getLocationn() async {

    try {
      TrustLocation.onChange.listen((values) => setState(() {
        double calculateDistance(lat1, lon1, lat2, lon2){
          var p = 0.017453292519943295;
          var c = cos;
          var a = 0.5 - c((lat2 - lat1) * p)/2 +
              c(lat1 * p) * c(lat2 * p) *
                  (1 - c((lon2 - lon1) * p))/2;
          return 1000 * 12742 * asin(sqrt(a));
        }
        double latt = double.parse(widget.lat);
        double longg = double.parse(widget.long);
        double lat2 = double.parse(values.latitude!);
        double long2 = double.parse(values.longitude!);
        List<dynamic> data = [
          //   -0.6208794, 100.3068847
          //   -0.6208755,  100.3068861
          //   -0.6208899,  100.3068742
          //   -0.6208839, 100.3068796
          //   -0.6208775,  100.3068864
          //   -0.6208732,  100.3068872
          //   -0.6208728,  100.3068885
          //  -0.6208735,  100.3068894
          //  -0.620872,  100.3068894
          //  -0.6208875,  100.3068788
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
        if(totalDistance<=200.0) {
          addData();
          TrustLocation.stop();
        }
        else{
          _alerttidakdisekitarkantor();
          TrustLocation.stop();

        }


      }));

    } on PlatformException catch (e) {
      print('PlatformException $e');
    }

    //_isMockLocation==true?_alertlokasipalsu():_alertlokasiakurat();
  }

  List<dynamic> _datacari = [];
  void absensicari() async {
    final DateTime now = DateTime.now();
    var a = now.day;
    var b = now.month;
    var c = now.year;
    String tanggalskrg='$c-$b-$a';
    //var url = "http://192.168.43.195/apisave/apisimpan/cariantrian";
    //var url = "http://apkhealth.000webhostapp.com/apisave/apisimpan/cariantrian";
    try{
      EasyLoading.show();
      var url = "http://192.168.23.27/absensipegawai/apisimpan/cariabsensi";
      final response = await http.post(Uri.parse(url), body:{
        "nip" : widget.nippeg
      }
      ); //untuk melakukan request ke webservice
      final listDatacari = jsonDecode(response.body);
      EasyLoading.dismiss();
      setState(() {
        _datacari = listDatacari;
      });
      _datacari.length > 0 ? idjenisabsen=='4'?addDataabsenlain():_showMyDialogcari() :
      idjenisabsen=='4'?_showMyDialogcariabsenlain():getLocationn();
    } catch (e) {
      EasyLoading.showError('Periksa koneksi anda');
      print(e);
    }
  }

  // void checkversion() async{
  //   var androidInfo = await DeviceInfoPlugin().androidInfo;
  //   var release = androidInfo.version.release;
  //   var sdkInt = androidInfo.version.sdkInt;
  //   var manufacturer = androidInfo.manufacturer;
  //   var model = androidInfo.model;
  //   print('Android $release (SDK $sdkInt), $manufacturer $model');// e.g. "Moto G (4)"
  //
  // }

  void addData() async{
    String tgl;
    final DateTime now = DateTime.now();
    var a = now.day;
    var b = now.month;
    var c = now.year;
    var d = now.hour;
    var e = now.minute;
    var f = now.second;
    var inout= "in";
    tgl='$c-$b-$a $d:$e';
    //print(widget.nippeg);
    print("jenis absen yang dipilih: $idjenisabsen");
    //print(tgl);

    if(idjenisabsen=='1'){
    try{
      EasyLoading.show();
      final Map<String, String> headerData= {
        "X-API-KEY": "@#2022"
      };
      final responsee = await http.post(Uri.parse("http://absensi.padangpariamankab.go.id/api-absen/api/checkinout"),
          headers:headerData,
          body: {
            "time_finger" : tgl.toString(),
            "nip" : widget.nippeg,
            "id_template" : widget.idtemplatepeg,
            "inout": inout

          });
      final data = jsonDecode(responsee.body);
      print('---- status code: ${responsee.statusCode}');
      String respon_code = data['respon_code'];
      print("respon code nya : " +respon_code);
      print(responsee);
      EasyLoading.dismiss();
      if(responsee.statusCode==200){
        print("success");
        _showMyDialogsuksesabsensi();
      }
      else{
        _showMyDialoggagalabsensi();
      }
    } catch (e) {
      EasyLoading.showError('Periksa koneksi anda');
      print(e);
    }
    }
    else if (idjenisabsen=='2'){
      try{
        EasyLoading.show();
        final responsee = await http.post(Uri.parse("http://192.168.23.27/absensipegawai/apisimpan/ambilabsenshift"),
            body: {
              "nip" : widget.nippeg,
              "idjenisabsen" : idjenisabsen,
              "idjenisshift" : idjenisshift,
              "masukkantor" : tgl.toString()
            });
        final data = jsonDecode(responsee.body);
        print('---- status code: ${responsee.statusCode}');
        int value = data['value'];
        String pesan = data['message'];
        print(pesan);
        print(value);
        print(responsee);
        EasyLoading.dismiss();
        if(responsee.statusCode==200){
          print("success");
          _showMyDialogsuksesabsensi();
        }
        else{
          _showMyDialoggagalabsensi();
        }
      } catch (e) {
        EasyLoading.showError('Periksa koneksi anda');
        print(e);
      }
    }

  }

  void addDataabsenlain() async{
    String tgl;
    final DateTime now = DateTime.now();
    var a = now.day;
    var b = now.month;
    var c = now.year;
    var d = now.hour;
    var e = now.minute;
    var f = now.second;
    tgl='$c-$b-$a $d:$e';
    //print(widget.nippeg);
    print("jenis absen yang dipilih: $idjenisabsen");
    //print(tgl);
    //
    // if(idjenisabsen=='1'){
    //   try{
    //     EasyLoading.show();
    //     final responsee = await http.post(Uri.parse("http://192.168.23.27/absensipegawai/apisimpan/ambilabsen"),
    //         body: {
    //           "nip" : widget.nippeg,
    //           "idjenisabsen" : idjenisabsen,
    //           "masukkantor" : tgl.toString()
    //         });
    //     final data = jsonDecode(responsee.body);
    //     print('---- status code: ${responsee.statusCode}');
    //     int value = data['value'];
    //     String pesan = data['message'];
    //     print(pesan);
    //     print(value);
    //     print(responsee);
    //     EasyLoading.dismiss();
    //     if(responsee.statusCode==200){
    //       print("success");
    //       _showMyDialogsuksesabsensi200();
    //     }
    //     else{
    //       _showMyDialoggagalabsensi200();
    //     }
    //   } catch (e) {
    //     EasyLoading.showError('Periksa koneksi anda');
    //     print(e);
    //   }
    // }
    // else if (idjenisabsen=='2'){
    //   try{
    //     EasyLoading.show();
    //     final responsee = await http.post(Uri.parse("http://192.168.23.27/absensipegawai/apisimpan/ambilabsenshift"),
    //         body: {
    //           "nip" : widget.nippeg,
    //           "idjenisabsen" : idjenisabsen,
    //           "idjenisshift" : idjenisshift,
    //           "masukkantor" : tgl.toString()
    //         });
    //     final data = jsonDecode(responsee.body);
    //     print('---- status code: ${responsee.statusCode}');
    //     int value = data['value'];
    //     String pesan = data['message'];
    //     print(pesan);
    //     print(value);
    //     print(responsee);
    //     EasyLoading.dismiss();
    //     if(responsee.statusCode==200){
    //       print("success");
    //       _showMyDialogsuksesabsensi200();
    //     }
    //     else{
    //       _showMyDialoggagalabsensi200();
    //     }
    //   } catch (e) {
    //     EasyLoading.showError('Periksa koneksi anda');
    //     print(e);
    //   }
    // }
    // else if (idjenisabsen=='4'){
      try{
        EasyLoading.show();
        final responsee = await http.post(Uri.parse("http://192.168.23.27/absensipegawai/apisimpan/absenjenislain"),
            body: {
              "nip" : widget.nippeg,
              "idjenisabsenlain" : idjenisabsenlain,
              "jammasukabsenlain" : tgl.toString()
            });
        final data = jsonDecode(responsee.body);
        print('---- status code: ${responsee.statusCode}');
        int value = data['value'];
        String pesan = data['message'];
        print(pesan);
        print(value);
        print(responsee);
        EasyLoading.dismiss();
        if(responsee.statusCode==200){
          print("success");
          _showMyDialogsuksesabsensi();
        }
        else{
          _showMyDialoggagalabsensi();
        }
      } catch (e) {
        EasyLoading.showError('Periksa koneksi anda');
        print(e);
      }


  }

  Future<void> _showMyDialogcari() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Info!!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Anda sudah melakukan absensi masuk!!'),
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

  Future<void> _showMyDialogcariabsenlain() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Info!!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Silahkan melakukan absensi masuk terlebih dahulu!!'),
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

  Future<void> _showMyDialogsuksesabsensi() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Info!!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Sukses absensi!!'),
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

  Future<void> _showMyDialoggagalabsensi() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Info!!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Gagal absensi!!'),
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

  Future<void> _alertpastikanlokasikantor() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Peringatan!!!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Lokasi anda akan diperiksa, Mohon pastikan anda berada 200 Meter dari lokasi kantor!!'),
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

  Future<void> _alertlokasiakurat() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Info!!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Lokasi anda sudah akurat..'),
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
                //distance();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showMyDialoglokasipulang() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Info!!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Pastikan anda masih di sekitar kantor!!'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                //_getippulang();
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
      body: Column(
        children: <Widget>[
          Flexible(
            flex: 2,
            child: Container(
              child:
              Align(
                alignment: Alignment.bottomCenter,
                child:
                Image.asset("assets/images/pemkab.png",
                  width: 90.0,
                  height: 150.0,),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Container(
              child:
              Align(
                alignment: Alignment.bottomCenter,
                child:
                Text(
                  'Pilih Jenis Absensi',
                  style: GoogleFonts.mcLaren(textStyle : TextStyle(fontWeight: FontWeight.bold,fontSize: 25.0,),),
                ),
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child:
            Container(
              child:
              Align(
                alignment: Alignment.bottomCenter,
                child:
                Container(
                  child: Column(
                    children: <Widget>[
                      DropdownButton(
                        hint: Text("Pilih Jenis Absensi",
                            style: GoogleFonts.mcLaren()),
                        value: _valJenisabsensi,
                        items: _dataJenisabsensi.map((item) {
                          return DropdownMenuItem(
                            child: Text(item[1].toString(), style: GoogleFonts.mcLaren()),
                            value: item[0].toString(),
                          );
                        }).toList(),
                        onChanged: (n) {
                            setState(() {
                              _valJenisabsensi = n as String?;
                              idjenisabsen = _valJenisabsensi! ;
                              int idjnsabs = int.parse(idjenisabsen!);
                              switch (idjnsabs) {
                                case 1:
                                  setState(() {
                                    _isVisibleshift = true;
                                    _isVisibleabsenjenislain = true;
                                    _isVisibleshift = !_isVisibleshift;
                                    _isVisibleabsenjenislain = !_isVisibleabsenjenislain;
                                  });
                                  _alertpastikanlokasikantor();
                                  break;
                                case 2:
                                    setState(() {
                                      _isVisibleabsenjenislain = true;
                                      _isVisibleshift = !_isVisibleshift;
                                      _isVisibleabsenjenislain = !_isVisibleabsenjenislain;
                                    });
                                    _alertpastikanlokasikantor();
                                  break;
                                case 3:
                                  setState(() {
                                    _isVisibleabsenjenislain = true;
                                    _isVisibleshift = true;
                                    _isVisibleshift = !_isVisibleshift;
                                    _isVisibleabsenjenislain = !_isVisibleabsenjenislain;
                                  });
                                  break;
                                case 4:
                                  setState(() {
                                    _isVisibleshift = true;
                                    _isVisibleshift = !_isVisibleshift;
                                    _isVisibleabsenjenislain = !_isVisibleabsenjenislain;
                                  });
                                  break;
                              }
                            });
                            print(_valJenisabsensi);
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 30.0),
                      ),
                      Visibility (
                        visible: _isVisibleshift,
                        child:
                        Column(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.bottomCenter,
                              child:
                              Text(
                                'Pilih Jenis Shift',
                                style: GoogleFonts.mcLaren(textStyle : TextStyle(fontWeight: FontWeight.bold,fontSize: 25.0,),),
                              ),
                            ),
                            DropdownButton(
                              hint: Text("Pilih Jenis Shift",
                                  style: GoogleFonts.mcLaren()),
                              value: _valJenisshift,
                              items: _dataJenisshift.map((item) {
                                return DropdownMenuItem(
                                  child: Text(item[1].toString(), style: GoogleFonts.mcLaren()),
                                  value: item[0].toString(),
                                );
                              }).toList(),
                              onChanged: (n) {
                                setState(() {
                                  _valJenisshift = n as String?;
                                  idjenisshift=_valJenisshift!;
                                  print(_valJenisshift);
                                });
                              },
                            ),
                          ],
                            ),
                      ),
                      Visibility (
                        visible: _isVisibleabsenjenislain,
                        child:
                        Column(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.bottomCenter,
                              child:
                              Text(
                                'Pilih Jenis Absen Lain',
                                style: GoogleFonts.mcLaren(textStyle : TextStyle(fontWeight: FontWeight.bold,fontSize: 25.0,),),
                              ),
                            ),
                            DropdownButton(
                              hint: Text("Pilih Jenis Absen Lain",
                                  style: GoogleFonts.mcLaren()),
                              value: _valJenisabsenlain,
                              items: _dataJenisabsenlain.map((item) {
                                return DropdownMenuItem(
                                  child: Text(item[1].toString(), style: GoogleFonts.mcLaren()),
                                  value: item[0].toString(),
                                );
                              }).toList(),
                              onChanged: (n) {
                                setState(() {
                                  _valJenisabsenlain = n as String?;
                                  idjenisabsenlain=_valJenisabsenlain!;
                                  print(_valJenisabsenlain);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      new Container(
                        //padding: EdgeInsets.only(top: 15.0),
                        child: InkWell(
                          onTap: (){
                            print("Container clicked");
                            // widget.page=="masuk"?
                            // absensicari():_showMyDialogpastikanipaddpulang();
                            int idjnsabs = int.parse(idjenisabsen!);
                            if(idjnsabs==1||idjnsabs==2||idjnsabs==4){
                              widget.page=="masuk"?
                              getLocationn():_showMyDialoglokasipulang();
                            }
                            else if(idjnsabs==3){
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(builder: (context) => Uploadspt(nip: widget.nippeg))
                              // );
                            }
                            // switch (idjnsabs) {
                            //   case 1:
                            //     widget.page=="masuk"?
                            //     absensicari():_showMyDialogpastikanipaddpulang();
                            //     break;
                            //   case 2:
                            //     widget.page=="masuk"?
                            //     absensicari():_showMyDialogpastikanipaddpulang();
                            //     break;
                            // }
                          },
                          child:
                          Container(
                            margin: EdgeInsets.all(10),
                            height: 50,
                            width: 130,
                            child:
                            Container(
                              alignment: Alignment.center,
                              child: Text(
                                'Pilih',
                                style: GoogleFonts.mcLaren(textStyle : TextStyle(color: Colors.white,fontSize: 25.0,),),
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              boxShadow: [kDefaultShadow],
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                        ),
                      ),
                    ],),
                ),
              ),
            ),
          ),
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
        ],
      ),
    );
  }
}


