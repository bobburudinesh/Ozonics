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
BluetoothDevice device1;
bool stdpressAttention = false;
bool bstpressAttention = false;
bool hyppressAttention = false;
bool dripressAttention = false;
List<int> ans=[];
List<int> pwrstatus=[];
List<int> modecont=[];
String mfgdata;
List<int> va = [60];
int x1 = 0;
int x2=0;
Future<dynamic> weatherdata;
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
              return FindDevicesScreen();
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
class FindDevicesScreen extends StatefulWidget {
  @override
  _FindDevicesScreenState createState() => _FindDevicesScreenState();
}
class _FindDevicesScreenState extends State<FindDevicesScreen>
    with TickerProviderStateMixin {
  AnimationController controller;
  AnimationController controller1;
  Animation animation;
  Animation animation1;
  //var weatherdata;
  void initState() {
    super.initState();
    //getlocdata();
    controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    controller1=AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
      lowerBound: 0.6
    );
    animation = CurvedAnimation(parent: controller, curve: Curves.linear);
    animation1 = CurvedAnimation(parent: controller1, curve: Curves.easeIn);
    controller.forward();
    controller.addListener(() {
      setState(() {});
    });
    controller1.forward();
    animation1.addStatusListener((status){
      if(status==AnimationStatus.completed){
        controller1.reverse(from: 1.0);
      }else if(status==AnimationStatus.dismissed){
        controller1.forward();
      }
    });
    controller1.addListener(() {
      setState(() {});
    });
    
    FlutterBlue.instance.startScan(timeout: Duration(minutes: 4));
  }

  void connection(var r) async {
    await r.device.connect();
    device1=r.device;
    FlutterBlue.instance.stopScan();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return DeviceScreen(
        device: r.device,
        //data: weatherdata,
      );
    }));
  }
@override
  void dispose() {
    controller.dispose();
    controller1.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ozonics',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black45,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: <Widget>[
            Container(
              child: Center(
                child: Image(
                  image: AssetImage('images/sitelogo.png'),
                  height: animation.value * 200,
                  width: animation.value * 200,
                ),
              ),
            ),
            Container(
              height: 150,
              width: 150,
              child: Center(
                child: Image(
                  image: AssetImage('images/scan.png'),
                  height: animation1.value * 100,
                  width: animation1.value * 100,
                ),
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
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
      ),
    );
  }
}
// ignore: camel_case_types
class settingsscreen extends StatefulWidget {
  const settingsscreen(this.device);
  final BluetoothDevice device;
  @override
  _settingsscreenState createState() => _settingsscreenState();
}
// ignore: camel_case_types
class _settingsscreenState extends State<settingsscreen> {
  void searchinsettings() {
    Navigator.pop(context);
    Navigator.pop(context);
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
class DeviceScreen extends StatefulWidget {
  const DeviceScreen({Key key, this.device}) : super(key: key);
  final BluetoothDevice device;
  @override
  _DeviceScreenState createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen>
    with SingleTickerProviderStateMixin {
  void getlocdata() async {
    weatherdata = await getlocationweather();
  }
  void driwash() async{
    if (pwrpressAttention == true) {
      await charac.write([65]);
      gross=await charac.read();
      batvalue=gross[0];
      await charac.write([51]);
      setState(() {
        stdpressAttention = false;
        bstpressAttention = false;
        hyppressAttention = false;
        dripressAttention = true;
      });
    }
  }
  void standard()  async{
    if (pwrpressAttention == true) {
      await charac.write([65]);
      gross=await charac.read();
      batvalue=gross[0];
     await charac.write([48]);
      setState(() {
        stdpressAttention = true;
        bstpressAttention = false;
        hyppressAttention = false;
        dripressAttention = false;
      });
    }
  }
  void boost() async{
    if (pwrpressAttention == true) {
      await charac.write([65]);
      gross=await charac.read();
      batvalue=gross[0];
      await charac.write([49]);
      setState(() {
        stdpressAttention = false;
        bstpressAttention = true;
        hyppressAttention = false;
        dripressAttention = false;
      });
    }
  }
  void hyperboost() async{
    if (pwrpressAttention == true) {
      await charac.write([65]);
      gross=await charac.read();
      batvalue=gross[0];
      await charac.write([50]);
      setState(() {
        stdpressAttention = false;
        bstpressAttention = false;
        hyppressAttention = true;
        dripressAttention = false;
      });
    }
  }
  void power() async{
    x2=1;
    await charac.write([65]);
    gross=await charac.read();
    batvalue=gross[0];
    if(!powerstatus){
      if(x1<1){

        await charac.write([67]);
        modeno=await charac.read();
        print('modeno:$modeno');
        x1++;
        _currentmode=modeno[0];
      }
     await charac.write([66]);}
    //print('current mode after power on is:$_currentmode');
setState(() {
  pwrpressAttention = !pwrpressAttention;
});
      if(_currentmode==48){
        setState(() {
          stdpressAttention=true;
        });
      }
      if(_currentmode==49){
        setState(() {
          bstpressAttention=true;
        });
      }
      if(_currentmode==50){
        setState(() {
          hyppressAttention=true;
        });
      }
      if(_currentmode==51){
        setState(() {
          dripressAttention=true;
        });
      }
  }
  void poweron() async{
    x2=0;
    await charac.write([65]);
    gross=await charac.read();
    batvalue=gross[0];
    await charac.write([66]);
    setState(() {
      pwrpressAttention = !pwrpressAttention;
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
        });
  }
  void settings() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return settingsscreen(widget.device);
    }));
  }
  void info() async{
    await charac.write([69]);
    ans=await charac.read();
    //print(ans);
    mfgdata=String.fromCharCodes(ans);
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return informationscreen(device: widget.device, mfg: mfgdata);
      }));
  }
  int _currentmode;
  int batvalue;
  List<int> gross=[];
  Timer _timer;
List<int> modeno=[];
bool powerstatus=false;
  List<BluetoothService> services;
  BluetoothCharacteristic charac;
  bool pwrpressAttention = false;
  void getservices() async {
    services = await widget.device.discoverServices();
    services.forEach((service) {
      if (service.uuid.toString() == SERVICE_UUID) {
        service.characteristics.forEach((characteristic) async{
          if (characteristic.uuid.toString() == CHARACTERISTIC_UUID_TX) {
            print('$characteristic.serviceUuid');
            charac = characteristic;
            await charac.write([68]);
            pwrstatus=await charac.read();
            //print(pwrstatus); reading to check if device is already on
            if(pwrstatus[0]==101){
              //print('it entered power on loop'); if pwrstatus[0]==101 means device is already on
              await charac.write([65]);  //reading bat value
              gross=await charac.read();
              await charac.write([67]); //asking for mode
              modeno=await charac.read();
              //print('modeno:$modeno'); to get mode number when device is already on
              setState(() {
                pwrpressAttention=true;
                batvalue=gross[0];
                _currentmode=modeno[0];
                if(_currentmode==48){
                    stdpressAttention=true;
                }
                if(_currentmode==49){
                    bstpressAttention=true;
                }
                if(_currentmode==50){
                    hyppressAttention=true;
                }
                if(_currentmode==51){
                    dripressAttention=true;
                }
                powerstatus=true;
                x2=1;
              });
            }
          }
          /*if(characteristic.uuid.toString()==CHARACTERISTIC_UUID_TX){
            await characteristic.setNotifyValue(true);
            characteristic.value.listen((v) {
              // do something with new value
              print(v[0]);
              if (modecont[0] == 48) {
                setState(() {
                  stdpressAttention = true;
                });
              }
              if (modecont[0] == 49) {
                setState(() {
                  bstpressAttention = true;
                });
              }
              if (modecont[0] == 50) {
                setState(() {
                  hyppressAttention = true;
                });
              }
              if (modecont[0] == 51) {
                setState(() {
                  dripressAttention = true;
                });
              }
            });
          }*/
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
  // ignore: missing_return
  Widget battery() {
   if(batvalue==null){
     batvalue=97;
   }
    print('batvalue=$batvalue');
    if (batvalue == 97) {
      return Container(
        child: Image(
          height: 50,
          width: 50,
          image: AssetImage('images/icons8-low-battery-50.png'),
        ),
      );
    } else if (batvalue == 98) {
      return Container(
        child: Image(
          height: 50,
          width: 50,
          image: AssetImage('images/icons8-battery-level-50.png'),
        ),
      );
    } else if (batvalue == 99) {
      return Container(
        child: Image(
          height: 50,
          width: 50,
          image: AssetImage('images/icons8-charged-battery-50.png'),
        ),
      );
    } else if (batvalue == 100) {
      return Container(
        child: Image(
          height: 50,
          width: 50,
          image: AssetImage('images/icons8-full-battery-50.png'),
        ),
      );
    }
  }
  Widget _buildServiceTiles() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: pwrpressAttention
                  ? Image(
                image: AssetImage('images/power_on.png'),
              )
                  : Image(
                image: AssetImage('images/power_off.png'),
              ),
              onPressed: pwrpressAttention ? () => poweron() : () => power(),
              iconSize: 120,
            ),
          ],
        ),
        SizedBox(
          height: 30,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: new Text(
                  ' Standard  ',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              textColor: Colors.white,
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(10),
                  side: BorderSide(color: Colors.yellow, width: 2)),
              color: stdpressAttention ? Colors.yellow : Colors.grey,
              onPressed: () => standard(),
            ),
            SizedBox(
              width: 30,
            ),
            RaisedButton(
              child: Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: new Text(
                  '  Boost   ',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              textColor: Colors.white,
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(10),
                  side: BorderSide(color: Colors.yellow, width: 2)),
              color: bstpressAttention ? Colors.yellow : Colors.grey,
              onPressed: () => boost(),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: new Text(
                  'HyperBoost',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              textColor: Colors.white,
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(10),
                  side: BorderSide(color: Colors.yellow, width: 2)),
              color: hyppressAttention ? Colors.pinkAccent : Colors.grey,
              onPressed: () => hyperboost(),
            ),
            SizedBox(
              width: 30,
            ),
            RaisedButton(
              child: Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: new Text(
                  ' Driwash  ',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              textColor: Colors.white,
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(10),
                  side: BorderSide(color: Colors.yellow, width: 2)),
              color: dripressAttention ? Colors.yellow : Colors.grey,
              onPressed: () => driwash(),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }
  @override
  void initState() {
    super.initState();
    x2=0;
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
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  battery(),
                ],
              ),
              Image(
                height: 160,
                width: 160,
                image: AssetImage('images/sitelogo.png'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    iconSize: 60,
                    icon: Image(
                      image: AssetImage('images/settings.png'),
                    ),
                    onPressed: () => settings(),
                  ),
                  IconButton(
                    iconSize: 50,
                    icon: Image(
                      image: AssetImage('images/information.png'),
                    ),
                    onPressed: () => info(),
                  ),
                ],
              ),
              _buildServiceTiles(),

              Center(child: FutureBuilder<dynamic>(
                future: getlocationweather(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          child: Center(
                            child: Text(
                              'WEATHER INFO',
                              style: TextStyle(color: Colors.orange, fontSize: 20),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Text(
                              'Cityname:        ${snapshot.data['name']} ',
                              style: TextStyle(fontSize: 15, color: Colors.white),
                            ),
                            Text(
                              'Sunrise:    ${readTimestamp(snapshot.data['sys']['sunrise'])}',
                              style: TextStyle(fontSize: 15, color: Colors.white),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Text(
                              'Temperature: ${snapshot.data['main']['temp']} °F',
                              style: TextStyle(fontSize: 15, color: Colors.white),
                            ),
                            Text(
                              'Sunset:     ${readTimestamp(snapshot.data['sys']['sunset'])}',
                              style: TextStyle(fontSize: 15, color: Colors.white),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Text(
                              'Humidity:              ${snapshot.data['main']['humidity']}%',
                              style: TextStyle(fontSize: 15, color: Colors.white),
                            ),
                            Text(
                              'Wind:    ${snapshot.data['wind']['speed']} mph',
                              style: TextStyle(fontSize: 15, color: Colors.white),
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
              ),
              SizedBox(
                height: 25,
              ),
              getmodemsg(),
            ],
          ),
        ),
      ),
    );
  }
}