import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'widget.dart';
const SERVICE_UUID = 'e14d460c-32bc-457e-87f8-b56d1eb24318';
const CHARACTERISTIC_UUID_TX = '08b332a8-f4f6-4222-b645-60073ac6823f';
List<BluetoothService> services;
BluetoothCharacteristic charac;
List<int> d=[0];
List<int> q=[0];
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
class _FindDevicesScreenState extends State<FindDevicesScreen> {
  void initState() {
    super.initState();
    FlutterBlue.instance.startScan(timeout: Duration(minutes: 4));
  }
  void connection(var r) async {
    await r.device.connect();
    FlutterBlue.instance.stopScan();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return DeviceScreen(
        device: r.device,
      );
    }));
  }
@override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search Screen',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black45,
      ),
      body: Container(
        child: Column(
          children: <Widget>[
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
                      ).toList(),
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

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({Key key, this.device}) : super(key: key);
  final BluetoothDevice device;
  @override
  _DeviceScreenState createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  void button4() async{
    await charac.write([65]);
  }
  void button1()  async{
    await charac.write([65]);
     // await charac.setNotifyValue(true);
      q=await charac.read();
      print('q is ${q[0]}');

  }
  void button2() async{
    await charac.write([65]);
  }
  void button3() async{
    await charac.write([65]);
  }
  void getservices() async {
    services = await widget.device.discoverServices();
    services.forEach((service) {
      if (service.uuid.toString() == SERVICE_UUID) {
        print('service found');
        service.characteristics.forEach((characteristic) async{
          if (characteristic.uuid.toString() == CHARACTERISTIC_UUID_TX) {
            print('$characteristic.serviceUuid');
            charac = characteristic;
            print('charac found');

          }
        });
      }
    });
  }
  Widget _buildServiceTiles() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: new Text(
                  'Button 1',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              textColor: Colors.white,
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(10),
                  side: BorderSide(color: Colors.black, width: 2)),
              color: Colors.grey,
              onPressed: () => button1(),
            ),
            SizedBox(
              width: 30,
            ),
            RaisedButton(
              child: Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: new Text(
                  'Button 2',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              textColor: Colors.white,
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(10),
                  side: BorderSide(color: Colors.black, width: 2)),
              color: Colors.grey,
              onPressed: () => button2(),
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
                  'Button 3',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              textColor: Colors.white,
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(10),
                  side: BorderSide(color: Colors.black, width: 2)),
              color: Colors.grey,
              onPressed: () => button3(),
            ),
            SizedBox(
              width: 30,
            ),
            RaisedButton(
              child: Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: new Text(
                  'Button 4',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              textColor: Colors.white,
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(10),
                  side: BorderSide(color: Colors.black, width: 2)),
              color: Colors.grey,
              onPressed: () => button4(),
            ),
          ],
        ),
        Text('Value :${d[0]}',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20,color: Colors.yellow),
        ),
        Text('Value read:${d[0]}',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20,color: Colors.yellow),
        ),
      ],
    );
  }
  @override
  void initState() {
    super.initState();
    getservices();
  }

@override
  void dispose() {
    super.dispose();
    widget.device.disconnect();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Device Screen'
      ),
      ),
      body: Container(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              _buildServiceTiles(),

            ],
          ),
        ),
      ),
    );
  }
}