import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:wifi/wifi.dart';
import 'package:ping_discover_network/ping_discover_network.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Light toogle app',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _lampStatus = "off";
  bool _connectivityWifi = false;
  String _deviceAdress = null;
  var subscription;

  void connectedWifiDevices(int port) async {
    final String ip = await Wifi.ip;
    final String subnet = ip.substring(0, ip.lastIndexOf('.'));
    final stream = NetworkAnalyzer.discover2(subnet, port);
    int found = 0;
    stream.listen((NetworkAddress addr) {
      if (addr.exists) {
        found++;
        print('Found device: ${addr.ip}:$port');
        setState(() {
          _deviceAdress = '${addr.ip}:$port';
        });
      }
    }).onDone(() async {
      print('Finish. Found $found device(s)');
      if (found == 0) {
        setState(() {
          _deviceAdress = null;
        });
      } else {
        initLampStatus();
      }
    });
  }

  void initLampStatus() async {
    var response = await http.get("http://$_deviceAdress/status");
    print(response.body);
    if (response.statusCode == 200) {
      String resStatus = json.decode(response.body)['26'];
      print("resStatus " + resStatus);
      setState(() {
        _lampStatus = resStatus;
      });
    } else {
      print("error");
    }
  }

  @override
  initState() {
    super.initState();

    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      // Got a new connectivity status!
      print(" switched ");
      if (result == ConnectivityResult.wifi) {
        print("Connected to wifi ");
        connectedWifiDevices(89);
        setState(() {
          _connectivityWifi = true;
        });
      } else {
        setState(() {
          _connectivityWifi = false;
        });
      }
    });
  }

// Be sure to cancel subscription after you are done
  @override
  dispose() {
    super.dispose();
    subscription.cancel();
  }

  Future<void> _action() async {
    if (_deviceAdress != null) {
      String statusToSend = _lampStatus == "on" ? "off" : "on";
      print(statusToSend);
      var response = await http.get("http://$_deviceAdress/26/$statusToSend");
      print(response.body);
      if (response.statusCode == 200) {
        String resStatus = json.decode(response.body)['status'];
        print(resStatus == "on");
        setState(() {
          _lampStatus = resStatus;
        });
      } else {
        print("error");
      }
    } else {
      print('scan for device');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: _connectivityWifi
                ? _deviceAdress != null
                    ? AvatarGlow(
                        startDelay: Duration(milliseconds: 1000),
                        glowColor:
                            _lampStatus == "on" ? Colors.yellow : Colors.black,
                        endRadius: 100.0,
                        duration: Duration(milliseconds: 2000),
                        repeat: true,
                        showTwoGlows: true,
                        repeatPauseDuration: Duration(milliseconds: 100),
                        child: Material(
                          elevation: 8.0,
                          color: Theme.of(context).primaryColor,
                          shape: CircleBorder(),
                          child: Container(
                            child: IconButton(
                              color: _lampStatus == "on"
                                  ? Colors.yellow
                                  : Colors.grey,
                              icon: Icon(Icons.lightbulb_outline),
                              onPressed: () => _action(),
                            ),
                          ),
                        ),
                        shape: BoxShape.circle,
                        animate: true,
                        curve: Curves.fastOutSlowIn,
                      )
                    : IconButton(
                        icon: Icon(Icons.refresh),
                        onPressed: () => connectedWifiDevices(89),
                      )
                : Text("Please Connect to wifi network")));
  }
}
