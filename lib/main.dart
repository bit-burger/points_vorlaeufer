import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:ionicons/ionicons.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';

import 'package:web_socket_channel/io.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import 'settings.dart';
import 'rows.dart';
import 'constants.dart' as Constants;
import 'package:points/custom_neumorphic_sliders.dart';

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
        "/settings": (context) {
          return Settings();
        },
        "/discover": (context) {
          return DiscoverFriends();
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

  void login() {
    Dio()
        .get("http://192.168.178.26:8080/$firstString/$secondString")
        .then((value) async {
      print("Value: " + value.toString());
      await Login.preferences.setString(
        Login.preferencesKey,
        value.toString(),
      );
      Navigator.pushNamed(context, "/home", arguments: value.toString());
    }).catchError((error) {
      print(error.toString() + " ERROR");
    });
  }

  bool _login = false;

  @override
  Widget build(BuildContext context) {
    () async {
      print("halal");
      Future.delayed(Duration(milliseconds: 1), () {
        if (Login.preferences.containsKey(Login.preferencesKey) && !_login) {
          _login = true;
          Navigator.of(context).pushNamed("/home",
              arguments: Login.preferences.getString(Login.preferencesKey));
        }
      });
    }();

    return Scaffold(
      appBar: CustomNeumorphicAppBar(
        title: Text(
          "Login",
          style: Constants.titleTextStyle,
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
                      enableSuggestions: false,
                      focusNode: firstNode,
                      keyboardType: TextInputType.name,
                      autofillHints: [
                        AutofillHints.username,
                        AutofillHints.newUsername
                      ],
                      cursorColor: Colors.grey[700],
                      cursorWidth: 1.75,
                      maxLength: 7,
                      decoration: InputDecoration(
                        counterText: "",
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
                      enableSuggestions: false,
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
                        print("submit");
                        login();
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
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  IOWebSocketChannel channel;

  Completer completer;

  Map<String, dynamic> data = {
    "name": "",
    "logo": "",
    "status": "new to points",
    "color": "white",
    "friends": [],
    "requests": [],
    "pending": [],
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
      'ws://192.168.178.26:3000',
      headers: {"id": Login.preferences.getString(Login.preferencesKey)},
    );
    channel.stream.listen(
      (data) {
        final Map<String, dynamic> parsedData = jsonDecode(data);
        if (!parsedData.containsKey("data"))
          setState(() {
            this.data = parsedData;
          });
        else
          completer.complete(parsedData["data"]);
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
          style: Constants.titleTextStyle,
        ),
        customBackWidget: NeumorphicButton(
          onPressed: () {
            print("wal");
            Navigator.pushNamed(
              context,
              "/discover",
              arguments: [
                () {
                  Completer completer = Completer<List<dynamic>>();
                  this.completer = completer;
                  print("aljsd");
                  this.channel.sink.add(
                        jsonEncode(
                          {
                            "type": "batch",
                            "id": Login.preferences
                                .getString(Login.preferencesKey),
                          },
                        ),
                      );
                  return completer.future;
                }(),
                this,
              ],
            );
          },
          style: NeumorphicStyle(
            boxShape: NeumorphicBoxShape.circle(),
          ),
          child: Icon(
            Ionicons.person_add_outline,
            size: 28,
          ),
        ),
        actions: [
          NeumorphicButton(
            style: NeumorphicStyle(
              boxShape: NeumorphicBoxShape.circle(),
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(
                "/settings",
                arguments: this,
              );
            },
            child: Icon(
              Ionicons.settings_outline,
            ),
          )
        ],
        buttonStyle: NeumorphicStyle(boxShape: NeumorphicBoxShape.circle()),
      ),
      body: (data["friends"] + data["requests"] + data["pending"]).length == 0
          ? Column(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      "No friends :(",
                      style: TextStyle(
                        fontFamily: "Courier",
                        fontSize: 30,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: SizedBox(),
                ),
              ],
            )
          : Container(
              child: Stack(
                children: [
                  ListView.builder(
                    padding: EdgeInsets.only(
                      top: 30,
                    ),
                    itemCount: () {
                      if (!data.containsKey("friends")) return 0;
                      var friends = (data["friends"] as List).length;
                      final requests = (data["requests"] as List).length + 1;
                      final pending = (data["pending"] as List).length + 1;
                      if (requests > 1) friends += requests;
                      if (pending > 1) friends += pending;
                      return friends;
                    }(),
                    itemBuilder: (context, i) {
                      final List<dynamic> array = data["friends"] +
                          (data["requests"].isEmpty
                              ? []
                              : (<dynamic>[true] + data["requests"])) +
                          (data["pending"].isEmpty
                              ? []
                              : (<dynamic>[false] + data["pending"]));
                      final _friend = array[i];
                      if (_friend is bool)
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 30, top: 0, bottom: 10),
                            child: Text(
                              _friend == true ? "requests" : "pending",
                              style: Constants.labelTextStyle,
                            ),
                          ),
                        );
                      final friend = _friend as Map<String, dynamic>;
                      final bool notFriend = i > data["friends"].length;
                      final bool notRequest =
                          i > data["friends"].length + data["requests"].length;
                      return FriendRow(
                        iconData: friend["logo"],
                        title: friend["name"],
                        status: friend["status"],
                        colorString: friend["color"],
                        points: friend["points"],
                        isButton: notFriend,
                        onLongPress: (){

                        },
                        onPressed: () {
                          if (!notFriend) {
                            channel.sink.add(
                              jsonEncode({
                                "type": "give_plus",
                                "id": ModalRoute.of(context).settings.arguments,
                                "friend": friend["id"],
                              }),
                            );
                          } else if (!notRequest) {
                            showModalActionSheet(
                              cancelLabel: "Do nothing",
                              actions: [
                                SheetAction(label: "Accept", key: true),
                                SheetAction(label: "Reject", key: false),
                              ],
                              context: context,
                            ).then((value) {
                              if (value) {
                                channel.sink.add(
                                  jsonEncode({
                                    "type": "accept",
                                    "id": ModalRoute.of(context)
                                        .settings
                                        .arguments,
                                    "friend": friend["id"],
                                  }),
                                );
                              } else {
                                channel.sink.add(
                                  jsonEncode({
                                    "type": "reject",
                                    "id": ModalRoute.of(context)
                                        .settings
                                        .arguments,
                                    "friend": friend["id"],
                                  }),
                                );
                              }
                            });
                          } else {
                            showModalActionSheet(
                              cancelLabel: "Do nothing",
                              actions: [
                                SheetAction(label: "Stop request", key: false),
                              ],
                              context: context,
                            ).then((value) {
                              channel.sink.add(
                                jsonEncode({
                                  "type": "kill_pending",
                                  "id": ModalRoute.of(context)
                                      .settings
                                      .arguments,
                                  "friend": friend["id"],
                                }),
                              );
                            });
                          }
                        },
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
                          NeumorphicTheme.of(context)
                              .current
                              .baseColor
                              .withAlpha(0)
                        ],
                      ),
                    ),
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
                          NeumorphicTheme.of(context)
                              .current
                              .baseColor
                              .withAlpha(0)
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
                          padding:
                              const EdgeInsets.all(17).copyWith(bottom: 10),
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

class DiscoverFriends extends StatefulWidget {
  @override
  _DiscoverFriendsState createState() => _DiscoverFriendsState();
}

class _DiscoverFriendsState extends State<DiscoverFriends> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomNeumorphicAppBar(
        title: Text(
          "Discover",
          style: Constants.titleTextStyle,
        ),
        buttonStyle: NeumorphicStyle(
          boxShape: NeumorphicBoxShape.circle(),
        ),
      ),
      body: Stack(
        children: [
          StreamBuilder<Object>(
              stream: ((ModalRoute.of(context).settings.arguments
                      as List<dynamic>)[0] as Future<List<dynamic>>)
                  .asStream(),
              initialData: [],
              builder: (context, snapshot) {
                final List<dynamic> data = snapshot.data;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ListView.builder(
                    padding: EdgeInsets.only(
                      top: 30,
                    ),
                    itemCount: data.length,
                    itemBuilder: (context, i) {
                      final friend = data[i];
                      return FriendRow(
                        iconData: friend["logo"],
                        title: friend["name"],
                        status: friend["status"],
                        colorString: friend["color"],
                        points: friend["points"],
                        isButton: true,
                        onPressed: () {
                          ((ModalRoute.of(context).settings.arguments
                                  as List<dynamic>)[1] as MyHomePageState)
                              .channel
                              .sink
                              .add(jsonEncode({
                                "type": "friend",
                                "id": Login.preferences
                                    .getString(Login.preferencesKey),
                                "friend": friend["id"],
                              }));
                        },
                      );
                    },
                  ),
                );
              }),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 20,
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                end: Alignment.bottomCenter,
                begin: Alignment.topCenter,
                colors: [
                  NeumorphicTheme.of(context).current.baseColor,
                  NeumorphicTheme.of(context).current.baseColor.withAlpha(0)
                ],
              )),
            ),
          ),
        ],
      ),
    );
  }
}
