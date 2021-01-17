import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:points/custom_neumorphic_sliders.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';
import 'package:dio/dio.dart';
// import 'package:flutter_icons/flutter_icons.dart';
import 'constants.dart';
import 'package:ionicons/ionicons.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Login.preferences = await SharedPreferences.getInstance();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NeumorphicApp(
      title: "POINTS",
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      routes: {
        "/home": (context) {
          return MyHomePage();
        },
        "/login": (context) {
          return Login();
        },
        "/settings": (context){
          return Settings();
        }
      },
      initialRoute: "/login",
    );
  }
}

class Login extends StatefulWidget {
  static const String preferencesKey = "id";

  static SharedPreferences preferences;

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  FocusNode firstNode;
  String firstString;

  FocusNode secondNode;
  String secondString;

  @override
  void initState() {
    firstNode = FocusNode();
    secondNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    firstNode.dispose();
    secondNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if (Login.preferences.containsKey(Login.preferencesKey))
    //   Navigator.of(context).pushNamed("/home");
    return Scaffold(
      appBar: CustomNeumorphicAppBar(
        title: Text(
          "Login",
          style: TextStyle(
            fontFamily: "Courier",
            fontSize: 30,
          ),
        ),
        buttonStyle: NeumorphicStyle(boxShape: NeumorphicBoxShape.circle()),
      ),
      body: Container(
        padding: EdgeInsets.all(25).copyWith(top: 0),
        child: Neumorphic(
          style: NeumorphicStyle(
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25)),
          ),
          padding: EdgeInsets.all(20),
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Neumorphic(
                  style: NeumorphicStyle(
                    depth: NeumorphicTheme.currentTheme(context).depth * -1,
                    boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(25)),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Theme(
                    data: ThemeData(textSelectionColor: Colors.grey[400]),
                    child: TextField(
                      focusNode: firstNode,
                      keyboardType: TextInputType.name,
                      autofillHints: [
                        AutofillHints.username,
                        AutofillHints.newUsername
                      ],
                      cursorColor: Colors.grey[700],
                      cursorWidth: 1.75,
                      decoration: InputDecoration(
                        hintText: "username",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                      ),
                      onChanged: (string) {
                        firstString = string;
                      },
                      onSubmitted: (string) {
                        firstNode.unfocus();
                        secondNode.requestFocus();
                      },
                      style: TextStyle(fontFamily: "Courier"),
                    ),
                  ),
                ),
                Neumorphic(
                  style: NeumorphicStyle(
                    depth: NeumorphicTheme.currentTheme(context).depth * -1,
                    boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(25)),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Theme(
                    data: ThemeData(textSelectionColor: Colors.grey[400]),
                    child: TextField(
                      focusNode: secondNode,
                      keyboardType: TextInputType.name,
                      autofillHints: [
                        AutofillHints.password,
                        AutofillHints.newUsername
                      ],
                      cursorColor: Colors.grey[700],
                      cursorWidth: 1.75,
                      decoration: InputDecoration(
                        hintText: "password",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                      ),
                      style: TextStyle(fontFamily: "Courier"),
                      onChanged: (string) {
                        secondString = string;
                      },
                      onSubmitted: (string) async {
                        print("wallah");
                        Dio()
                            .get(
                                "http://192.168.178.26:8080/$firstString/$secondString")
                            .then((value) async {
                          print("Value: " + value.toString());
                          await Login.preferences.setString(
                            Login.preferencesKey,
                            value.toString(),
                          );
                          Navigator.pushNamed(context, "/home",
                              arguments: value.toString());
                        }).catchError((error) {
                          print(error.toString() + " ERROR");
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  IOWebSocketChannel channel;

  Map<String, dynamic> data = {
    "name": "",
    "logo": "",
    "status": "new to points",
    "color": "white",
    "friends": []
  };

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

  void connect() {
    channel?.sink?.close();
    channel = IOWebSocketChannel.connect(
      'ws://localhost:3000',
      headers: {"id": Login.preferences.getString(Login.preferencesKey)},
    );
    channel.stream.listen(
      (data) {
        setState(() {
          this.data = jsonDecode(data);
        });
      },
    );
    print("reconnected");
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      connect();
      print("connected");
    } else {
      channel?.sink?.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomNeumorphicAppBar(
        title: Text(
          data["name"] ?? "",
          style: TextStyle(
            fontFamily: "Courier",
            fontSize: 30,
          ),
        ),
        actions: [
          NeumorphicButton(
            style: NeumorphicStyle(
              boxShape: NeumorphicBoxShape.circle(),
            ),
            onPressed: (){
              Navigator.of(context).pushNamed("/settings");
            },
            child: Icon(
              Ionicons.settings_outline,
            ),
          )
        ],
        buttonStyle: NeumorphicStyle(boxShape: NeumorphicBoxShape.circle()),
      ),
      body: Container(
        child: Stack(
          children: [
            ListView.builder(
              itemCount: (data["friends"] as List).length,
              itemBuilder: (context, i) {
                final friend =
                    (data["friends"] as List)[i] as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20)
                      .copyWith(left: 20, right: 20),
                  child: Neumorphic(
                    style: NeumorphicStyle(
                      boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(27.5)),
                      color: Constants.colorCodes[friend["color"]],
                    ),
                    child: SizedBox(
                      height: 55,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(15, 0, 10, 4),
                            child: Icon(
                              Constants.getIconData(friend["logo"]),
                              size: 35,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                            child: Text(
                              friend["name"],
                              style: TextStyle(
                                  fontFamily: "Courier", fontSize: 20),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(15, 5, 15, 0),
                                child: Text(
                                  friend["status"],
                                  style: TextStyle(
                                    fontFamily: "Courier",
                                    fontSize: 15,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 2,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: (){
                              channel.sink.add(
                                jsonEncode({
                                  "type":"give_plus",
                                  "id":ModalRoute.of(context).settings.arguments,
                                  "friend":friend["id"],
                                }),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(0, 5, 20, 0),
                              child: Text(
                                friend["points"].toString(),
                                style: TextStyle(
                                  fontFamily: "Courier",
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            Container(
              height: 30,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  NeumorphicTheme.of(context).current.baseColor,
                  NeumorphicTheme.of(context).current.baseColor.withAlpha(0)
                ],
              )),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 30,
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    NeumorphicTheme.of(context).current.baseColor,
                    NeumorphicTheme.of(context).current.baseColor.withAlpha(0)
                  ],
                )),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(32.5),
                child: Neumorphic(
                  style: NeumorphicStyle(
                    boxShape: NeumorphicBoxShape.circle(),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(17).copyWith(bottom: 10),
                    child: Text(
                      data["points"].toString(),
                      style: TextStyle(
                        fontFamily: "Courier",
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Settings extends StatefulWidget {
  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomNeumorphicAppBar(
        title: Text("Settings"),
        buttonStyle: NeumorphicStyle(boxShape: NeumorphicBoxShape.circle()),
      ),
      body: Container(
        padding: EdgeInsets.all(25).copyWith(top: 0),
        child: Neumorphic(
          style: NeumorphicStyle(
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(25)),
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Padding(
                child: Text(
                  "Decibel range",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}