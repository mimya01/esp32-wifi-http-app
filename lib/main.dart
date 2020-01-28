import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import 'package:avatar_glow/avatar_glow.dart';

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
  bool _lampStatus = true;
  bool _connectivityWifi = false;
  var subscription;
  /* void ConnectivityWifi() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a wifi network.
    }
  } */
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
    print("presed");
    setState(() {
      _lampStatus = !_lampStatus;
    });
    /*  var response = await http.get('http://46.101.148.188/api/status');
    print(response.body);
    if (response.statusCode == 200) {
      print("success");
      setState(() {
        _lampStatus = !_lampStatus;
      });
    } else {
      print("error");
    } */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child:_connectivityWifi?
      AvatarGlow(
        startDelay: Duration(milliseconds: 1000),
        glowColor: _lampStatus ? Colors.yellow : Colors.black,
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
              color: _lampStatus ? Colors.yellow : Colors.grey,
              icon: Icon(Icons.lightbulb_outline),
              onPressed: () => _action(),
            ),
          ),
        ),
        shape: BoxShape.circle,
        animate: true,
        curve: Curves.fastOutSlowIn,
      ):Text("Please Connect to wifi network")
    ));
  }
}
