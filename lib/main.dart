import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'widget.dart';
import 'locationget.dart';
import 'networking.dart';
import 'package:countdown_flutter/countdown_flutter.dart';
import 'package:intl/intl.dart';
const apikey = '17ce55ff5a97302d58bcbc946dd70239';
const SERVICE_UUID = 'e14d460c-32bc-457e-87f8-b56d1eb24318';
const CHARACTERISTIC_UUID_TX = '08b332a8-f4f6-4222-b645-60073ac6823f';
Future getlocationweather() async {
  Location loc = Location();
  await loc.getcurrentloc();
  NetworkHelper networkhelper = NetworkHelper(
      'https://api.openweathermap.org/data/2.5/weather?lat=${loc.lat}&lon=${loc.lon}&appid=$apikey&units=imperial');
  var weatherdata =  networkhelper.getData();
  return weatherdata;
}

Widget battery() {
  if(batvalue==null){
    batvalue=97;
  }
  print('batvalue=$batvalue');
  if (batvalue == 100) {
    return Container(
      child: Image(
        height: 50,
        width: 50,
        image: AssetImage('images/icons8-low-battery-50.png'),
      ),
    );
  } else if (batvalue == 99) {
    return Container(
      child: Image(
        height: 50,
        width: 50,
        image: AssetImage('images/icons8-battery-level-50.png'),
      ),
    );
  } else if (batvalue == 98) {
    return Container(
      child: Image(
        height: 50,
        width: 50,
        image: AssetImage('images/icons8-charged-battery-50.png'),
      ),
    );
  } else if (batvalue == 97) {
    return Container(
      child: Image(
        height: 50,
        width: 50,
        image: AssetImage('images/icons8-full-battery-50.png'),
      ),
    );
  }
}
var defaultminutes = "15 Minutes";

List<String> minutes = <String>[
  '10 Minutes',
  '15 Minutes',
  '20 Minutes',
  '25 Minutes',
  '30 Minutes',
  'Do Not Off'
];
String selectedtime='15 Minutes';
StreamSubscription<List<int>> streamSubscription;
BluetoothDevice device1;
List<ScanResult> dta;
int modevalue=0;
bool stdpressAttention = false;
bool bstpressAttention = false;
bool hyppressAttention = false;
bool dripressAttention = false;
List<int> ans=[];
int notifiedvalue=0;
int prev=0;
List<int> pwrstatus=[];
List<int> modecont=[];
String mfgdata;
List<int> va = [60];
int x1 = 0;
int x2=0;
Future<dynamic> weatherdata;
int _currentmode;
//List<String> weatherinfo;
int batvalue;
List<int> gross=[];
Timer _timer;
List<int> modeno=[];
bool powerstatus=false;
List<BluetoothService> services;
BluetoothCharacteristic charac;
bool pwrpressAttention = false;


String readTimestamp(int timestamp) {
  var now = DateTime.now();
  var format = DateFormat('HH:mm a');
  var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  var diff = now.difference(date);
  var time = '';
  if (diff.inSeconds <= 0 ||
      diff.inSeconds > 0 && diff.inMinutes == 0 ||
      diff.inMinutes > 0 && diff.inHours == 0 ||
      diff.inHours > 0 && diff.inDays == 0) {
    time = format.format(date);
  } else if (diff.inDays > 0 && diff.inDays < 7) {
    if (diff.inDays == 1) {
      time = diff.inDays.toString() + ' DAY AGO';
    } else {
      time = diff.inDays.toString() + ' DAYS AGO';
    }
  } else {
    if (diff.inDays == 7) {
      time = (diff.inDays / 7).floor().toString() + ' WEEK AGO';
    } else {
      time = (diff.inDays / 7).floor().toString() + ' WEEKS AGO';
    }
  }

  return time;
}
void main() {
  runApp(FlutterBlueApp());
}

class ScanResultTile extends StatelessWidget {
  const ScanResultTile({Key key, this.result, this.onTap}) : super(key: key);

  final ScanResult result;
  final VoidCallback onTap;

  Widget _buildTitle(BuildContext context) {
    if (result.device.name.length > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white)
        ),

        child: Text(
          result.device.name,
          style: TextStyle(color: Colors.white),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      );
    }
    else {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 9),

        decoration: BoxDecoration(
            border: Border.all(color: Colors.white)
        ),
        child: Text(result.device.id.toString(),style: TextStyle(color: Colors.white),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: _buildTitle(context),
      onTap: onTap,
    );
  }
}


class FlutterBlueApp extends StatefulWidget {
  @override
  _FlutterBlueAppState createState() => _FlutterBlueAppState();
}

class _FlutterBlueAppState extends State<FlutterBlueApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.lightBlue,
      home: StreamBuilder<BluetoothState>(
          stream: FlutterBlue.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              return Scanscreen();
            }
            return BluetoothOffScreen(state: state);
          }),
    );
  }
}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key key, this.state}) : super(key: key);
  final BluetoothState state;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.bluetooth_disabled,
                size: 200.0,
                color: Colors.white54,
              ),
              Text(
                'Bluetooth Adapter is ${state.toString().substring(15)}.',
                style: Theme.of(context)
                    .primaryTextTheme
                    .subhead
                    .copyWith(color: Colors.white),
              ),
              Text(
                'Please Turn on Bluetooth.',
                style: Theme.of(context)
                    .primaryTextTheme
                    .subhead
                    .copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class searchlogo extends StatefulWidget {
  @override
  _searchlogoState createState() => _searchlogoState();
}

class _searchlogoState extends State<searchlogo> with SingleTickerProviderStateMixin {
  AnimationController controller1;
  Animation animation1;
  void initState() {
    super.initState();
    controller1 = AnimationController(
        duration: Duration(seconds: 1),
        vsync: this,
        lowerBound: 0.6
    );
    animation1 = CurvedAnimation(parent: controller1, curve: Curves.easeIn);
    controller1.forward();
    animation1.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller1.reverse(from: 1.0);
      } else if (status == AnimationStatus.dismissed) {
        controller1.forward();
      }
    });
    controller1.addListener(() {
      setState(() {});
    });
  }
  @override
  void dispose() {
    controller1.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: 150,
      child: Center(
        child: Image(
          image: AssetImage('images/scan.png'),
          height: animation1.value * 100,
          width: animation1.value * 100,
        ),
      ),
    );
  }
}
class winfo extends StatefulWidget {
  @override
  _winfoState createState() => _winfoState();
}

class _winfoState extends State<winfo> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      child: Column(
        children: [
          Row(
              children: <Widget>[
                Expanded(
                    child: Divider(thickness: 5,color: Colors.yellowAccent,)
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: Text(
                    'WEATHER INFO',
                    style: TextStyle(color: Colors.orange, fontSize: 20),

                  ),
                ),
                Expanded(
                    child: Divider(thickness: 5,color: Colors.yellowAccent,)
                ),
              ]
          ),

          FutureBuilder<dynamic>(
            future: getlocationweather(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 9),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 3),
                                child: Text(
                                  'Cityname: ${snapshot.data['name']} ',
                                  style: TextStyle(fontSize: 15, color: Colors.white),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 3),
                                child: Text(
                                  'Temperature: ${snapshot.data['main']['temp']} °F',
                                  style: TextStyle(fontSize: 15, color: Colors.white),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 3),
                                child: Text(
                                  'Humidity: ${snapshot.data['main']['humidity']}%',
                                  style: TextStyle(fontSize: 15, color: Colors.white),
                                ),
                              ),

                            ],),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 9),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 3),
                                child: Text(
                                  'Sunrise: ${readTimestamp(snapshot.data['sys']['sunrise'])}',
                                  style: TextStyle(fontSize: 15, color: Colors.white),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 3),
                                child: Text(
                                  'Sunset: ${readTimestamp(snapshot.data['sys']['sunset'])}',
                                  style: TextStyle(fontSize: 15, color: Colors.white),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 3),
                                child: Text(
                                  'Wind: ${snapshot.data['wind']['speed']} Mph',
                                  style: TextStyle(fontSize: 15, color: Colors.white),
                                ),
                              ),

                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              // By default, show a loading spinner.
              return CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.yellow),
              );
            },
          ),
        ],
      ),
    );
  }
}
 class Scanscreen extends StatefulWidget {
   @override
   _ScanscreenState createState() => _ScanscreenState();
 }

 class _ScanscreenState extends State<Scanscreen> {
   @override
   Widget build(BuildContext context) {
     return Scaffold(
       body: Container(
         decoration: BoxDecoration(
           image: DecorationImage(
             image: AssetImage('images/background.jpg'),
             fit: BoxFit.cover,
           ),
         ),
         child: Column(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             FindDevicesScreen(),
             winfo()
           ],
         ),


       )







     );
   }
 }





class FindDevicesScreen extends StatefulWidget {
  @override
  _FindDevicesScreenState createState() => _FindDevicesScreenState();
}
class _FindDevicesScreenState extends State<FindDevicesScreen>
    with TickerProviderStateMixin {
  AnimationController controller;
  Animation animation;
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    animation = CurvedAnimation(parent: controller, curve: Curves.linear);
    //animation1 = CurvedAnimation(parent: controller1, curve: Curves.easeIn);
    controller.forward();
    controller.addListener(() {
      setState(() {});
    });
    
    FlutterBlue.instance.startScan(timeout: Duration(minutes: 4));
  }

  void connection(var r) async {

    await r.device.connect();
    device1=r.device;
    FlutterBlue.instance.stopScan();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return mainscreen();
    }));
  }
@override
  void dispose() {
    controller.dispose();
    //controller1.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 65),
              child: Image(

                image: AssetImage('images/sitelogo.png'),
                //height: 100,
                //width: 100,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Text('Scan For Devices',style: TextStyle(fontSize: 15,color: Colors.white),textAlign: TextAlign.center,),
            searchlogo(),
            Container(

              //color: Colors.red,
              height: 250,
              //width: 300,
              child: ListView(
                children: [
                  StreamBuilder<List<ScanResult>>(
                    stream: FlutterBlue.instance.scanResults,
                    initialData: [],
                    builder: (c, snapshot) => Column(
                      children: snapshot.data
                          .map(
                            (r) => ScanResultTile(
                          result: r,
                          onTap: () => connection(r),
                        ),
                      )
                          .toList(),
                    ),
                  ),



                ],
              ),

            ),
          ],
        ),
        // winfo(),

        /*Container(
              height: 125,
              child: Column(
                children: [
                  Row(
                      children: <Widget>[
                        Expanded(
                            child: Divider(thickness: 5,color: Colors.yellowAccent,)
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          child: Text(
                            'WEATHER INFO',
                            style: TextStyle(color: Colors.orange, fontSize: 20),

                          ),
                        ),
                        Expanded(
                            child: Divider(thickness: 5,color: Colors.yellowAccent,)
                        ),
                      ]
                  ),

              FutureBuilder<dynamic>(
                future: getlocationweather(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 9),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            Text(
                              'Cityname: ${snapshot.data['name']} ',
                              style: TextStyle(fontSize: 15, color: Colors.white),
                            ),
                            Text(
                              'Temperature: ${snapshot.data['main']['temp']} °F',
                              style: TextStyle(fontSize: 15, color: Colors.white),
                            ),
                            Text(
                              'Humidity: ${snapshot.data['main']['humidity']}%',
                              style: TextStyle(fontSize: 15, color: Colors.white),
                            ),

                          ],),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 9),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Sunrise: ${readTimestamp(snapshot.data['sys']['sunrise'])}',
                                style: TextStyle(fontSize: 15, color: Colors.white),
                              ),
                              Text(
                                'Sunset: ${readTimestamp(snapshot.data['sys']['sunset'])}',
                                style: TextStyle(fontSize: 15, color: Colors.white),
                              ),
                              Text(
                                'Wind: ${snapshot.data['wind']['speed']} Mph',
                                style: TextStyle(fontSize: 15, color: Colors.white),
                              ),

                            ],
                          ),
                        ),
                      ],
                    ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  // By default, show a loading spinner.
                  return CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.yellow),
                  );
                },
              ),
                ],
              ),
            ),*/
      ],
    );



      /*Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: put column here
      ),
    );*/
  }
}
// ignore: camel_case_types
class settingsscreen extends StatefulWidget {
  //const settingsscreen(this.device);
  //final BluetoothDevice device;
  @override
  _settingsscreenState createState() => _settingsscreenState();
}
// ignore: camel_case_types
class _settingsscreenState extends State<settingsscreen> {

  void searchinsettings() {
    Navigator.pop(context);
    Navigator.pop(context);
  }
void writetime (int x1)async{
    await charac.write([x1]);
    Navigator.of(context).pop(true);
    print('Time set to:$x1');
}
  void remotepage(){



showDialog(

    context: context,
  builder: (context){
      return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(10),
          child: Stack(
            overflow: Overflow.visible,
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.black
                ),
                padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        'Select Time',
                        style: TextStyle(color: Colors.white,fontSize: 20),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        RaisedButton(
                            child: Center(
                              child: new Text(
                                '10 Minutes',
                                style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
                              ),
                            ),
                            textColor: Colors.white,
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(25),
                                side: BorderSide(color: Colors.yellow, width: 2)),
                            color:   Colors.transparent,
                            // color:  b1? Colors.yellow : Colors.transparent,
                            onPressed: () {
                              /*setState(() {
                            b1=true;
                            b2=false;
                            b3=false;
                            b4=false;
                            b5=false;
                          });*/
                              writetime(83);


                            }

                        ),
                        RaisedButton(

                            child: Center(
                              child: new Text(
                                '15 Minutes',
                                style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
                              ),
                            ),
                            textColor: Colors.white,
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(25),
                                side: BorderSide(color: Colors.yellow, width: 2)),
                            color: Colors.transparent,
                            onPressed: () {

                              writetime(84);


                            }

                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        RaisedButton(

                            child: Center(
                              child: new Text(
                                '20 Minutes',
                                style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
                              ),
                            ),
                            textColor: Colors.white,
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(25),
                                side: BorderSide(color: Colors.yellow, width: 2)),
                            color:  Colors.transparent,
                            onPressed: () {

                              writetime(85);


                            }

                        ),
                        RaisedButton(

                            child: Center(
                              child: new Text(
                                '30 Minutes',
                                style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
                              ),
                            ),
                            textColor: Colors.white,
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(25),
                                side: BorderSide(color: Colors.yellow, width: 2)),
                            color:  Colors.transparent,
                            onPressed: () {

                              writetime(86);


                            }

                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RaisedButton(

                            child: Center(
                              child: new Text(
                                'Do Not Turn OFF',
                                style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
                              ),
                            ),
                            textColor: Colors.white,
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(25),
                                side: BorderSide(color: Colors.yellow, width: 2)),
                            color:   Colors.transparent,
                            onPressed: () {
                              writetime(87);


                            }

                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RaisedButton(

                            child: Center(
                              child: new Text(
                                'BACK',
                                style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                              ),
                            ),
                            textColor: Colors.black87,
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(25),
                                side: BorderSide(color: Colors.yellow, width: 2)),
                            color:  Colors.yellow ,
                            onPressed: () {
                              Navigator.of(context).pop(true);


                            }

                        ),
                      ],
                    ),




                  ],
                ),
              ),
              /*Positioned(
                  top: -100,
                  child: Image.network("https://i.imgur.com/2yaf2wb.png", width: 150, height: 150)
              )*/
            ],
          )
      );
  }


);


















  /*  showDialog(
        context: context,
        builder: (context) {

          return AlertDialog(
            backgroundColor: Colors.black,

            content: Container(
              height: 400,
              decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
          color: Colors.blue),
              //height: 300,
              //width: 300,
              //color: Colors.black,
              child: Column(
                children: [
                  Text(
                    'Select Time',
                    style: TextStyle(color: Colors.white,fontSize: 16),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      RaisedButton(
                        child: Center(
                          child: new Text(
                            '10 Minutes',
                            style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
                          ),
                        ),
                        textColor: Colors.white,
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(25),
                            side: BorderSide(color: Colors.yellow, width: 2)),
                        color:   Colors.transparent,
                         // color:  b1? Colors.yellow : Colors.transparent,
                          onPressed: () {
                          /*setState(() {
                            b1=true;
                            b2=false;
                            b3=false;
                            b4=false;
                            b5=false;
                          });*/
                          writetime(83);


                        }

                      ),
                      RaisedButton(

                          child: Center(
                            child: new Text(
                              '15 Minutes',
                              style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
                            ),
                          ),
                          textColor: Colors.white,
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(25),
                              side: BorderSide(color: Colors.yellow, width: 2)),
                          color: Colors.transparent,
                          onPressed: () {

                            writetime(84);


                          }

                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      RaisedButton(

                          child: Center(
                            child: new Text(
                              '20 Minutes',
                              style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
                            ),
                          ),
                          textColor: Colors.white,
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(25),
                              side: BorderSide(color: Colors.yellow, width: 2)),
                          color:  Colors.transparent,
                          onPressed: () {

                            writetime(85);


                          }

                      ),
                      RaisedButton(

                          child: Center(
                            child: new Text(
                              '30 Minutes',
                              style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
                            ),
                          ),
                          textColor: Colors.white,
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(25),
                              side: BorderSide(color: Colors.yellow, width: 2)),
                          color:  Colors.transparent,
                          onPressed: () {

                            writetime(86);


                          }

                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RaisedButton(

                          child: Center(
                            child: new Text(
                              'Do Not Turn OFF',
                              style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
                            ),
                          ),
                          textColor: Colors.white,
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(25),
                              side: BorderSide(color: Colors.yellow, width: 2)),
                          color:   Colors.transparent,
                          onPressed: () {
                            writetime(87);


                          }

                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RaisedButton(

                          child: Center(
                            child: new Text(
                              'BACK',
                              style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                            ),
                          ),
                          textColor: Colors.black87,
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(25),
                              side: BorderSide(color: Colors.yellow, width: 2)),
                          color:  Colors.yellow ,
                          onPressed: () {
                            Navigator.of(context).pop(true);


                          }

                      ),
                    ],
                  ),




                ],
              ),

            ),
          );
        }
    );*/
  }
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              children: <Widget>[
                Text(
                  'SETTINGS',
                  style: TextStyle(color: Colors.white, fontSize: 40),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 150,
                ),
                IconButton(
                  iconSize: 80,
                  icon: Image(
                    image: AssetImage(
                      'images/scan.png',
                    ),
                  ),
                  onPressed: () => searchinsettings(),
                ),
                Text(
                  'scan for devices',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
                IconButton(


                  //onPressed: ,
                  iconSize: 80,
                  icon: Image(
                    image: AssetImage(
                      'images/updates.png',
                    ),
                  ),
                ),
                Text(
                  'check for updates',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
                /*Container(
                  width: 150.0,
                  child: RaisedButton(
                    child: Text("SELECT TIME"),
                    onPressed: () => showMaterialScrollPicker(
                      context: context,
                      title: "Pick Time",
                      items: minutes,
                      selectedItem: defaultminutes,
                      onChanged: (value) {
                        selectedtime=value;

                      },
                    )
                  ),
                ),
                Text(
                  'Selected Time:$selectedtime',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white
                  ),
                ),*/
                /*SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 65,
                  width: 120,

                  child: RaisedButton(

                      child: Center(
                        child: new Text(
                          'REMOTE',
                          style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                        ),
                      ),
                      textColor: Colors.black87,
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(25),
                          side: BorderSide(color: Colors.yellow, width: 2)),
                      color: Colors.yellow ,
                      onPressed: () {
                        remotepage();

                      }

                  ),
                ),*/


              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: camel_case_types
class informationscreen extends StatefulWidget {
  informationscreen({this.device,this.mfg});
  final BluetoothDevice device;
  final String mfg;
  @override
  _informationscreenState createState() => _informationscreenState();
}
// ignore: camel_case_types
class _informationscreenState extends State<informationscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              children: <Widget>[
                Text(
                  'INFORMATION',
                  style: TextStyle(color: Colors.white, fontSize: 40),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 200,
                ),
                Text(
                  'Firmware Version:1.0',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
                Text(
                  'Manufacture Date:${widget.mfg}',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
                Text(
                  'Contact:1-979-285-2400',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class mainscreen extends StatefulWidget {
  @override
  _mainscreenState createState() => _mainscreenState();
}

class _mainscreenState extends State<mainscreen> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: <Widget>[
                  Row(
                    children: [
                      Expanded(
                        child: Container(height: 3,color: Colors.yellow,),
                      ),
                    ],
                  ),
                  /*Expanded(
                    child: Container(height: 3,color: Colors.yellow,),
                  ),*/
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      battery(),
                      Text(device1.name+'\n'+'Unit Name',style: TextStyle(color: Colors.white,height: 2),textAlign: TextAlign.right,),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(height: 3,color: Colors.yellow,),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Container(
                          height: 40,
                          //width: 100,
                          child: Image(
                            //height: 110,
                            //width: 160,
                            image: AssetImage('images/sitelogo.png'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(height: 3,color: Colors.yellow,),
                      ),
                    ],
                  ),
                 /* Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        iconSize: 50,
                        icon: Image(
                          image: AssetImage('images/settings.png'),
                        ),
                        onPressed: () => settings(),
                      ),
                      IconButton(
                        iconSize: 35,
                        icon: Image(
                          image: AssetImage('images/information.png'),
                        ),
                        onPressed: () => info(),
                      ),
                    ],
                  ),*/
                  buttons(device: device1,),
                  /*Row(
                      children: <Widget>[
                        Expanded(
                            child: Divider(thickness: 5,color: Colors.yellowAccent,)
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          child: Text(
                            'WEATHER INFO',
                            style: TextStyle(color: Colors.orange, fontSize: 20),

                          ),
                        ),
                        Expanded(
                            child: Divider(thickness: 5,color: Colors.yellowAccent,)
                        ),
                      ]
                  ),
                 Center(child: FutureBuilder<dynamic>(
                    future: getlocationweather(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 9),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Cityname: ${snapshot.data['name']} ',
                                        style: TextStyle(fontSize: 15, color: Colors.white),
                                      ),
                                      Text(
                                        'Temperature: ${snapshot.data['main']['temp']} °F',
                                        style: TextStyle(fontSize: 15, color: Colors.white),
                                      ),
                                      Text(
                                        'Humidity: ${snapshot.data['main']['humidity']}%',
                                        style: TextStyle(fontSize: 15, color: Colors.white),
                                      ),

                                    ],),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 9),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        'Sunrise: ${readTimestamp(snapshot.data['sys']['sunrise'])}',
                                        style: TextStyle(fontSize: 15, color: Colors.white),
                                      ),
                                      Text(
                                        'Sunset: ${readTimestamp(snapshot.data['sys']['sunset'])}',
                                        style: TextStyle(fontSize: 15, color: Colors.white),
                                      ),
                                      Text(
                                        'Wind: ${snapshot.data['wind']['speed']} Mph',
                                        style: TextStyle(fontSize: 15, color: Colors.white),
                                      ),

                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Text("${snapshot.error}");
                      }
                      // By default, show a loading spinner.
                      return CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(Colors.yellow),
                      );
                    },
                  ),
                  ),*/
                ],
              ),
              winfo(),
            ],
          ),
        ),
      ),
    );
  }
}
// ignore: camel_case_types
class buttons extends StatefulWidget {
  const buttons({Key key, this.device}) : super(key: key);
  final BluetoothDevice device;
  @override
  _buttonsState createState() => _buttonsState();
}
class _buttonsState extends State<buttons>
    with SingleTickerProviderStateMixin {
  void getlocdata() async {
    weatherdata = await getlocationweather();
  }
  _setNotificationdouble() async {
    if (charac != null) {


           charac.value.listen((gross1) {
         print('inside listen');
         print('                '+'$gross1[0]'+'                 ');
         if(gross1[0]==80){
           notifiedvalue=80;
           setState(() {
             pwrpressAttention=true;
             stdpressAttention = true;
             bstpressAttention = false;
             hyppressAttention = false;
             dripressAttention = false;
           });


           print('Device turned on');
         }
         else if(gross1[0]==81){
           notifiedvalue=81;
           setState(() {
             pwrpressAttention=false;
             stdpressAttention = false;
             bstpressAttention = false;
             hyppressAttention = false;
             dripressAttention = false;
           });
           showDialog(
               context: context,
               builder: (context) {
                 Future.delayed(const Duration(seconds: 15), () {
                   Navigator.of(context).pop(true);
                 });
                 return AlertDialog(
                   title: Text('Please Remove Battery From The Unit'),
                   content: Countdown(
                     duration: Duration(seconds: 15),
                     builder: (BuildContext ctx, Duration remaining) {
                       return Text(
                         '${remaining.inSeconds}',
                         textAlign: TextAlign.center,
                       );
                     },
                   ),
                 );
               }
               );



           print('Device turned off');
         }
         else if(gross1[0]==97){
           batvalue=97;


           print('battery info a');
           print('Battery B/W 75-100%');
         }
         else if(gross1[0]==98){
           batvalue=98;

           print('battery info b');
           print('Battery B/W 50-75%');
         }
         else if(gross1[0]==99){
           batvalue=99;

           print('battery info c');
           print('Battery B/W 25-50%');
         }
         else if(gross1[0]==100){
           batvalue=100;

           print('battery info d');
           print('Battery B/W 0-25%');
         }
         else if(gross1[0]==48){
           notifiedvalue=48;
           setState(() {
             stdpressAttention = true;
             bstpressAttention = false;
             hyppressAttention = false;
             dripressAttention = false;
           });


           print('STANDARD MODE');
         }
         else if(gross1[0]==49){
           notifiedvalue=49;
           setState(() {
             stdpressAttention = false;
             bstpressAttention = true;
             hyppressAttention = false;
             dripressAttention = false;
           });

           print('BOOST MODE');
         }
         else if(gross1[0]==50){
           notifiedvalue=50;
           setState(() {
             stdpressAttention = false;
             bstpressAttention = false;
             hyppressAttention = true;
             dripressAttention = false;
           });
           print('HYPERBOOST MODE');

         }
         else if(gross1[0]==51){
           notifiedvalue=51;
           setState(() {
             stdpressAttention = false;
             bstpressAttention = false;
             hyppressAttention = false;
             dripressAttention = true;
           });

           print('DRIWASH MODE');
         }
         else if(gross1[0]==102){
           notifiedvalue=102;



           print('device off');
         }
         else if(gross1[0]==101){
           notifiedvalue=101;
           //modevalue=101;
           //charac.write([67]);
           setState(() {
             pwrpressAttention=true;
           });

           print('device on');
         }

        //_onValuesChanged(charac);
      });
    }
  }



  void driwash() async{

    if (pwrpressAttention == true) {
     // await charac.setNotifyValue(false);
     // await charac.write([65]);
      //gross=await charac.read();
     // batvalue=gross[0];
      await charac.write([51]);

    }
  }
  void standard()  async{
    if (pwrpressAttention == true) {
     await charac.write([48]);

    }
  }
  void boost() async{

    if (pwrpressAttention == true) {
      await charac.write([49]);
    }

  }
  void hyperboost() async{

    if (pwrpressAttention == true) {

      await charac.write([50]);
    }
  }
  void poweron() async{

    await charac.write([66]);
  }
  void poweroff() async{
    x2=0;

    await charac.write([66]);

  }

  void getservices() async {
    services = await widget.device.discoverServices();
    services.forEach((service) {
      if (service.uuid.toString() == SERVICE_UUID) {
        service.characteristics.forEach((characteristic) async{

          if (characteristic.uuid.toString() == CHARACTERISTIC_UUID_TX) {
            print('$characteristic.serviceUuid');
            charac = characteristic;
            await charac.setNotifyValue(!charac.isNotifying);

            Timer.periodic(Duration(seconds: 10), (timer) async{
              await charac.write([65]);
              //print(DateTime.now());
            });



            await charac.write([68]);
            print('Current value:$notifiedvalue');
            List<int> n1=await charac.read();
            print('read value=$n1');
            if(notifiedvalue==101 || n1[0]==101){
              print('asked for current mode');


              await charac.write([67]);
              print('Current mode:$notifiedvalue');//asking for mode
            }
            _setNotificationdouble();

          }

        });
      }
    });
  }
  Widget getmodemsg(){
    if(stdpressAttention==true){
      return Text('Standard mode is activated',textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontSize: 20),);
    }else if(bstpressAttention==true){
      return Text('Boost mode is activated',textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontSize: 20),);
    }else if(hyppressAttention==true){
      return Text('Hyperboost mode is activated',textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontSize: 20),);
    }else if(dripressAttention==true){
      return Text('Driwash mode is activated',textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontSize: 20),);
    }else{
      return Text('Power is off',textAlign: TextAlign.center,style: TextStyle(color: Colors.white,fontSize: 20),);
    }
  }
  void settings() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return settingsscreen();
    }));
  }
  void info() async{
    await charac.write([69]);
    ans=await charac.read();
    //print(ans);
    mfgdata=String.fromCharCodes(ans);
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return informationscreen(mfg: mfgdata);
    }));
  }
  @override
  void initState() {
    super.initState();
    x2=0;
    pwrpressAttention=false;
    stdpressAttention=false;
    bstpressAttention=false;
    hyppressAttention=false;
    dripressAttention=false;
    x1 = 0;
    getservices();
  }
@override
  void dispose() {
    super.dispose();
    print('BEFORE DISCONNECT');
    widget.device.disconnect();
    print('AFTER DISCONNECT');
    _timer.cancel();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      //mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            IconButton(
              color: Colors.blue,
              iconSize: 50,
              icon: Image(
                image: AssetImage('images/settings.png'),
              ),
              onPressed: () => settings(),
            ),
            IconButton(
              icon: pwrpressAttention
                  ? Image(
                image: AssetImage('images/power_on.png'),
              )
                  : Image(
                image: AssetImage('images/power_off.png'),
              ),
              onPressed: pwrpressAttention ? () => poweroff() : () => poweron(),
              iconSize: 100,
            ),
            IconButton(
              iconSize: 35,
              icon: Image(
                image: AssetImage('images/information.png'),
              ),
              onPressed: () => info(),
            ),
          ],
        ),
        /*SizedBox(
          height: 10,
        ),*/
        SizedBox(
          height:200,
          width: 330,
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: 65,
                    width: 120,
                    child: RaisedButton(

                      child: Center(
                        child: new Text(
                          'Standard',
                          style: TextStyle(fontSize: 16.5,fontWeight: FontWeight.bold),
                        ),
                      ),
                      textColor: Colors.white,
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(25),
                          side: BorderSide(color: Colors.yellow, width: 2)),
                      color: stdpressAttention ? Colors.yellow : Colors.transparent,
                      onPressed: () => standard(),
                    ),
                  ),
                  SizedBox(
                    height: 70,
                    width: 120,
                  ),
                  SizedBox(
                    height: 65,
                    width: 120,
                    child: RaisedButton(

                      child: Center(
                        child: new Text(
                          'Hyperboost',
                          style: TextStyle(fontSize: 16.5,fontWeight: FontWeight.bold),
                        ),
                      ),
                      textColor: Colors.white,
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(25),
                          side: BorderSide(color: Colors.yellow, width: 2)),
                      color: hyppressAttention ? Colors.yellow : Colors.transparent,
                      onPressed: () => hyperboost(),
                    ),
                  ),


                ],),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Container(color: Colors.yellow, height: 3, width: 90,),
                  Container(color: Colors.yellow, height: 55, width: 3,),
                  Container(
                    height: 30,
                    width: 70,
                    // margin: EdgeInsets.only(top: 40, left: 40, right: 40),
                    decoration: new BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: Colors.yellow, width: 0.0),
                      borderRadius: new BorderRadius.all(Radius.elliptical(70, 30)),
                    ),
                    child: Center(child: Text('Mode',style:TextStyle(color: Colors.yellow,fontWeight: FontWeight.bold),)),
                  ),
                  Container(color: Colors.yellow, height: 55, width: 3,),
                  Container(color: Colors.yellow, height: 3, width: 90,),

                ],),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: 65,
                    width: 120,
                    child: RaisedButton(

                      child: Center(
                        child: new Text(
                          'Boost',
                          style: TextStyle(fontSize: 16.5,fontWeight: FontWeight.bold),
                        ),
                      ),
                      textColor: Colors.white,
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(25),
                          side: BorderSide(color: Colors.yellow, width: 2)),
                      color: bstpressAttention ? Colors.yellow : Colors.transparent,
                      onPressed: () => boost(),
                    ),
                  ),
                  SizedBox(
                    height: 70,
                    width: 120,
                  ),
                  SizedBox(
                    height: 65,
                    width: 120,
                    child: RaisedButton(

                      child: Center(
                        child: new Text(
                          'Driwash',
                          style: TextStyle(fontSize: 16.5,fontWeight: FontWeight.bold),
                        ),
                      ),
                      textColor: Colors.white,
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(25),
                          side: BorderSide(color: Colors.yellow, width: 2)),
                      color: dripressAttention ? Colors.yellow : Colors.transparent,
                      onPressed: () => driwash(),
                    ),
                  ),

                ],),
            ],
          ),
        ),
        // SizedBox(
        //   height: 10,
        // ),
        getmodemsg(),

        ],
    );
  }
}

