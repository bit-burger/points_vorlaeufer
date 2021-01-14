import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yallah',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {

  IOWebSocketChannel channel;

  @override
  void initState() {
    connect();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    channel.sink.close();
    super.dispose();
  }
  void connect(){
    setState(() {
      channel?.sink?.close();
      channel = IOWebSocketChannel.connect('ws://192.168.178.69:8080');
    });
    // channel.stream.listen(
    //       (dynamic message) {
    //     debugPrint('message $message');
    //   },
    //   onDone: () {
    //     debugPrint('ws channel closed');
    //   },
    //   onError: (error) {
    //     debugPrint('ws error $error');
    //   },
    // );
    print("reconnected");
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state==AppLifecycleState.resumed) {
      connect();
      print("connected");
    } else {
      channel?.sink?.close();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("famylié app™"),
      ),
      body: StreamBuilder<dynamic>(
          stream: channel.stream,
          initialData: """
        {
        "motto": \"yallah\",
        "counter": 3
        }
        """,
          builder: (context, snapshot) {
            print("data: " + snapshot.data.toString());
            final Map<String,dynamic> data = jsonDecode(snapshot.data.toString());


            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(data["motto"].toString(),style: TextStyle(
                    fontSize: 25,
                  ),
                  ),
                  Text(data["counter"].toString(),style: TextStyle(
                    fontSize: 50,
                  ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: TextField(
                      onSubmitted: (string){
                        channel.sink.add(
                            """
                            {
                            "motto" : "$string"
                            }
                            """
                        );
                      },
                    ),
                  ),
                  FlatButton(
                    child: Text("meeehr"),
                    color: Colors.teal,
                    onPressed: (){
                      channel.sink.add("increase");
                    },
                  ),
                  FlatButton(
                    child: Text("weniger"),
                    color: Colors.redAccent,
                    onPressed: (){
                      channel.sink.add("decrease");
                    },
                  ),
                  FlatButton(
                    child: Text("wallah bille"),
                    color: Colors.yellowAccent,
                    onPressed: (){
                      setState(() {
                        connect();
                      });
                    },
                  ),
                ],
              ),
            );
          }
      ),
    );
  }
}
