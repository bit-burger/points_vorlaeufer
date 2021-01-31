import 'dart:convert';
import 'dart:async';
import 'dart:math';

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

class App {
  static void updatePropertyRequest(String property, value) {
    App.data[property] = value;
    channel.sink.add(
        jsonEncode({"type": "change", "property": property, "value": value}));
    controller.add(App.data);
  }

  static void customRequest(Map<String, dynamic> map) {
    channel.sink.add(jsonEncode(map));
  }

  static const String preferencesKey = "id";
  static SharedPreferences preferences;

  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();

  static IOWebSocketChannel channel;
  static StreamController controller;

  static Stream<Map<String, dynamic>> stream;
  static Map<String, dynamic> data = {
    "name": "",
    "logo": "",
    "status": "new to points",
    "color": "white",
    "friends": [],
    "requests": [],
    "pending": [],
    "blocks": [],
  };

  static void fs(Map<String,dynamic> friend,String command,{String remove,String place}) {
    App.channel.sink.add(
      jsonEncode({
        "type": command,
        "friend": friend["id"],
      }),
    );
    if(remove!=null)
    App.data[remove] =
        (App.data[remove] as List<dynamic>)
            .where((element) =>
        element["id"] != friend["id"])
            .toList();
    if(place!=null)
      App.data[place].add(friend);
    App.controller.add(App.data);
  }

  static void end() {
    App.controller.close();
    App.controller = null;

    App.channel?.sink?.close();
    App.channel = null;
  }

  static void begin() {
    //ACHTUNG: DEFAULT VALUE VON EINEM STREAMBUILDER MUSS AUF App.data gestellt werden
    if (App.channel != null) {
      App.channel?.sink?.close();
      App.channel = null;
      App.controller.close();
      App.controller = null;
    }
    App.controller = StreamController<Map<String, dynamic>>();
    try {
      App.channel = IOWebSocketChannel.connect(
        'ws://192.168.178.26:3000',
        headers: {"id": App.preferences.getString(App.preferencesKey)},
      );
    } catch (error) {
      print(error);
    }

    App.channel.stream.listen((event) {
      final Map<String, dynamic> data = jsonDecode(event);
      print("data:\n" + data.toString());
      if (data["type"] == "initialupdate") {
        App.data = data;
      } else if (data["type"] == "selfupdate") {
        App.data[data["property"]] = data["value"];
      } else if (data["type"] == "friendupdate") {
        (App.data["friends"] + App.data["pending"] + App.data["requests"]
                    as List)
                .firstWhere((element) => element["id"] == data["friend"])[
            data["property"]] = data["value"];
        if(data.containsKey("points")) App.data["gives"] -= data["points"];
      } else if (data["type"] == "fs") {
        final friend = data["friend"];
        if(data.containsKey("remove")) {
          (App.data[data["remove"]] as List).removeWhere((element) => element["id"]==friend["id"]);
        }
        if(data.containsKey("place")) {
          (App.data[data["place"]] as List).add(friend);
        }
      } else if (data["type"] == "initialupdate") {
        App.data = data;
      } else {
        throw ErrorDescription("type nonexistnat");
      }
      App.controller.add(App.data);
    });
    App.stream = App.controller.stream.asBroadcastStream();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  App.preferences = await SharedPreferences.getInstance();
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
      navigatorObservers: [App.routeObserver],
      initialRoute: "/login",
    );
  }
}

class Login extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<Login> {
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
    App.data = {
      "name": "",
      "logo": "",
      "status": "new to points",
      "color": "white",
      "friends": [],
      "requests": [],
      "pending": [],
      "blocks": [],
    };
    Dio()
        .get("http://192.168.178.26:8080/$firstString/$secondString")
        .then((value) async {
      print("Value: " + value.toString());
      await App.preferences.setString(
        App.preferencesKey,
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
      Future.delayed(Duration(milliseconds: 1), () {
        if (App.preferences.containsKey(App.preferencesKey) && !_login) {
          _login = true;
          Navigator.of(context).pushNamed("/home",
              arguments: App.preferences.getString(App.preferencesKey));
        }
      });
    }();

    return Scaffold(
      appBar: CustomNeumorphicAppBar(
        title: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            "Login",
            style: Constants.titleTextStyle,
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
                      enableSuggestions: false,
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
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
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
                      textInputAction: TextInputAction.next,
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
                      autocorrect: false,
                      obscureText: true,
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

class MyHomePageState extends State<MyHomePage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  bool schonGeladen = false;

  AnimationController _controller;

  bool isReversingAnimation = false;

  int bulk = 1;

  void checkIfBulkValid() {
    while (bulk > App.data["gives"] && bulk != 1) {
      bulk ~/= 10;
    }
  }

  @override
  void initState() {
    connect();
    WidgetsBinding.instance.addObserver(this);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 750),
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    App.end();
    _controller.dispose();
    super.dispose();
  }

  void connect() {
    App.begin();
    App.stream.listen(
      (_data) {
        print("data has come to us ; )");
        setState(() {
          checkIfBulkValid();
        });
        // final Map<String, dynamic> parsedData = jsonDecode(data);
        // if (!parsedData.containsKey("data"))
        //   setState(() {
        //     checkIfBulkValid();
        //   });
        // else
        //   completer.complete(parsedData["data"]);
      },
    );
    print("reconnected");
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!schonGeladen) {
      schonGeladen = true;
    } else if (state == AppLifecycleState.resumed) {
      connect();
      print("connected");
    } else {
      App.end();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomNeumorphicAppBar(
        title: Text(
          App.data["name"] ?? "",
          style: Constants.titleTextStyle,
        ),
        customBackWidget: NeumorphicButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              "/discover",
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
                "/settings"
              );
            },
            child: Icon(
              Ionicons.settings_outline,
            ),
          )
        ],
        buttonStyle: NeumorphicStyle(boxShape: NeumorphicBoxShape.circle()),
      ),
      body: SafeArea(
        minimum: EdgeInsets.only(bottom: Constants.gap),
        child: Container(
          child: Stack(
            children: [
              (App.data["friends"] + App.data["requests"] + App.data["pending"])
                          .length ==
                      0
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
                  : ListView.builder(
                      padding: EdgeInsets.only(
                        top: 30,
                      ),
                      itemCount: () {
                        if (!App.data.containsKey("friends")) return 0;
                        var friends = (App.data["friends"] as List).length;
                        final requests =
                            (App.data["requests"] as List).length + 1;
                        final pending =
                            (App.data["pending"] as List).length + 1;
                        if (requests > 1) friends += requests;
                        if (pending > 1) friends += pending;
                        return friends;
                      }(),
                      itemBuilder: (context, i) {
                        final List<dynamic> array = App.data["friends"] +
                            (App.data["requests"].isEmpty
                                ? []
                                : (<dynamic>[true] + App.data["requests"])) +
                            (App.data["pending"].isEmpty
                                ? []
                                : (<dynamic>[false] + App.data["pending"]));
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
                        final bool notFriend = i > App.data["friends"].length;
                        final bool notRequest = i >
                            App.data["friends"].length +
                                App.data["requests"].length;
                        return Dismissible(
                          key: Key(friend["id"]),
                          direction: notFriend
                              ? DismissDirection.endToStart
                              : DismissDirection.horizontal,
                          onDismissed: (direction) {
                            setState(() {
                              if ((App.data["friends"] as List)
                                      .where((element) =>
                                          element["id"] == friend["id"])
                                      .length ==
                                  1) {
                                App.channel.sink.add(
                                  jsonEncode({
                                    "type": "unfriend",
                                    "friend": friend["id"],
                                  }),
                                );
                                App.data["friends"] =
                                    (App.data["friends"] as List<dynamic>)
                                        .where((element) =>
                                            element["id"] != friend["id"])
                                        .toList();
                              } else if ((App.data["requests"] as List)
                                      .where((element) =>
                                          element["id"] == friend["id"])
                                      .length ==
                                  1) {
                                App.data["requests"] =
                                    (App.data["requests"] as List<dynamic>)
                                        .where((element) =>
                                            element["id"] != friend["id"])
                                        .toList();
                                print(App.data);
                                App.channel.sink.add(
                                  jsonEncode({
                                    "type": "reject",
                                    "friend": friend["id"],
                                  }),
                                );
                              } else if ((App.data["pending"] as List)
                                      .where((element) =>
                                          element["id"] == friend["id"])
                                      .length ==
                                  1) {
                                App.data["pending"] =
                                    (App.data["pending"] as List<dynamic>)
                                        .where((element) =>
                                            element["id"] != friend["id"])
                                        .toList();
                                App.channel.sink.add(
                                  jsonEncode({
                                    "type": "kill_pending",
                                    "friend": friend["id"],
                                  }),
                                );
                              }
                            });
                          },
                          child: FriendRow(
                            iconData: friend["logo"],
                            title: friend["name"],
                            status: friend["status"],
                            colorString: friend["color"],
                            points: friend["points"],
                            isButton: true,
                            onLongPress: notFriend
                                ? null
                                : () {
                                    showModalActionSheet(
                                      cancelLabel: "Do nothing",
                                      actions: [
                                        SheetAction(
                                            label: "Unfriend", key: true),
                                        SheetAction(label: "Block", key: false),
                                      ],
                                      context: context,
                                    ).then((value) {
                                      if (value==true) {
                                        App.fs(friend,"unfriend",remove: "friends");
                                      } else if (value==false) {
                                        App.fs(friend,"unfriend_block",remove: "friends",place: "blocks");
                                      }
                                    });
                                  },
                            onPressed: () {
                              if (!notFriend) {
                                App.channel.sink.add(
                                  jsonEncode({
                                    "type": "plus",
                                    "friend": friend["id"],
                                    "amount": bulk,
                                  }),
                                );
                                setState(() {
                                  if (App.data["gives"] >= bulk) {
                                    friend["points"] += bulk;
                                    App.data["gives"] -= bulk;
                                  }
                                  checkIfBulkValid();
                                });
                              } else if (!notRequest) {
                                showModalActionSheet(
                                  cancelLabel: "Do nothing",
                                  actions: [
                                    SheetAction(label: "Accept", key: 0),
                                    SheetAction(label: "Reject", key: 1),
                                    SheetAction(label: "Block", key: 2),
                                  ],
                                  context: context,
                                ).then((value) {
                                  if (value == 0) {
                                    App.fs(friend, "accept", remove: "requests", place: "friends");
                                  } else if (value == 1) {
                                    App.fs(friend,"reject",remove: "requests");
                                  } else if (value == 2) {
                                    App.fs(friend,"reject_block",remove: "requests",place: "blocks");
                                  }
                                });
                              } else {
                                showModalActionSheet(
                                  cancelLabel: "Do nothing",
                                  actions: [
                                    SheetAction(
                                        label: "Stop request", key: true),
                                  ],
                                  context: context,
                                ).then((value) {
                                  if (value == null) return;
                                  App.fs(friend,"kill_pending",remove: "pending");
                                });
                              }
                            },
                          ),
                          confirmDismiss: (direction) {
                            if (!notFriend &&
                                direction == DismissDirection.startToEnd) {
                              print("yallah haalblblbl");
                              showModalActionSheet(
                                cancelLabel: "Do nothing",
                                actions: [
                                  SheetAction(label: "Unfriend", key: true),
                                  SheetAction(label: "Block", key: false),
                                ],
                                context: context,
                              ).then((value) {
                                if (value == true) {
                                  App.fs(friend,"unfriend",remove: "friends");
                                } else if (value == false) {
                                  App.fs(friend,"unfriend_block",remove: "friends",place: "blocks");
                                }
                              });
                              return Future(() => false);
                            }
                            return Future(() => true);
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
                          .withAlpha(0),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
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
                    AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Container(
                            color:
                                NeumorphicTheme.of(context).current.baseColor,
                            height: pow(_controller.value, 3) * 90,
                          );
                        })
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: Constants.gap),
                child: LayoutBuilder(
                  builder: (context, outerConstraints) {
                    return Align(
                      alignment: Alignment.bottomRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            flex: 1,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return AnimatedBuilder(
                                  animation: _controller,
                                  child: OverflowBox(
                                    maxWidth: (outerConstraints.maxWidth -
                                        (outerConstraints.maxWidth -
                                                constraints.maxWidth) *
                                            _controller.value),
                                    alignment: Alignment.bottomLeft,
                                    child: OverflowBox(
                                      maxWidth:
                                          constraints.maxWidth - Constants.gap,
                                      alignment: Alignment.topLeft,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          top: 5,
                                          left: 10,
                                          right: 10,
                                        ),
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Text(
                                            App.data["gives"].toString(),
                                            style: TextStyle(
                                              fontFamily: "Courier",
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  builder: (context, child) {
                                    double animationValue = isReversingAnimation
                                        ? pow(_controller.value, 2)
                                        : pow(_controller.value, 1);
                                    return OverflowBox(
                                      maxWidth: outerConstraints.maxWidth -
                                          (outerConstraints.maxWidth -
                                                  constraints.maxWidth) *
                                              _controller.value,
                                      alignment: Alignment.bottomLeft,
                                      child: Container(
                                        alignment: Alignment.bottomRight,
                                        child: Stack(
                                          alignment: Alignment.bottomRight,
                                          children: [
                                            SizedBox(
                                              width: constraints.maxWidth *
                                                  animationValue,
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: 30,
                                                    bottom: sqrt(
                                                            _controller.value) *
                                                        60),
                                                child: OverflowBox(
                                                  maxWidth:
                                                      constraints.maxWidth,
                                                  child: Align(
                                                    alignment:
                                                        Alignment.bottomLeft,
                                                    child: Opacity(
                                                      opacity: pow(
                                                          animationValue, 3),
                                                      child: Text(
                                                        "gives",
                                                        style: Constants
                                                            .labelTextStyle,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 55,
                                              width: _controller.value *
                                                      (constraints.maxWidth -
                                                          55) +
                                                  55,
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    right: Constants.gap),
                                                child: Neumorphic(
                                                  style: NeumorphicStyle(
                                                    boxShape: NeumorphicBoxShape
                                                        .roundRect(
                                                      BorderRadius.circular(
                                                        27.5,
                                                      ),
                                                    ),
                                                    depth: 4 * animationValue,
                                                  ),
                                                  child: Opacity(
                                                    opacity: animationValue,
                                                    child: child,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return AnimatedBuilder(
                                  animation: _controller,
                                  child: OverflowBox(
                                    maxWidth: (outerConstraints.maxWidth -
                                        (outerConstraints.maxWidth -
                                                constraints.maxWidth) *
                                            _controller.value),
                                    alignment: Alignment.bottomLeft,
                                    child: OverflowBox(
                                      maxWidth: constraints.maxWidth,
                                      alignment: Alignment.topLeft,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          top: 5,
                                          left: 10,
                                          right: 10,
                                        ),
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Text(
                                            bulk.toString(),
                                            style: TextStyle(
                                              fontFamily: "Courier",
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  builder: (context, child) {
                                    double animationValue = isReversingAnimation
                                        ? pow(_controller.value, 5)
                                        : pow(_controller.value, 2.5);
                                    return OverflowBox(
                                      maxWidth: outerConstraints.maxWidth -
                                          (outerConstraints.maxWidth -
                                                  constraints.maxWidth) *
                                              _controller.value,
                                      alignment: Alignment.bottomLeft,
                                      child: Container(
                                        alignment: Alignment.bottomRight,
                                        child: Stack(
                                          alignment: Alignment.bottomRight,
                                          children: [
                                            SizedBox(
                                              width: constraints.maxWidth *
                                                  animationValue,
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: 30,
                                                    bottom: sqrt(
                                                            _controller.value) *
                                                        60),
                                                child: OverflowBox(
                                                  maxWidth:
                                                      constraints.maxWidth,
                                                  child: Align(
                                                    alignment:
                                                        Alignment.bottomLeft,
                                                    child: Opacity(
                                                      opacity: pow(
                                                          animationValue, 3),
                                                      child: Text(
                                                        "bulk",
                                                        style: Constants
                                                            .labelTextStyle,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 55,
                                              width: _controller.value *
                                                      (constraints.maxWidth -
                                                          55) +
                                                  55,
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    right: Constants.gap),
                                                child: NeumorphicButton(
                                                  padding: EdgeInsets.zero,
                                                  onPressed: () {
                                                    setState(() {
                                                      if (App.data["gives"] >
                                                          bulk * 10) {
                                                        bulk *= 10;
                                                      } else {
                                                        bulk = 1;
                                                      }
                                                    });
                                                  },
                                                  style: NeumorphicStyle(
                                                    boxShape: NeumorphicBoxShape
                                                        .roundRect(
                                                      BorderRadius.circular(
                                                        27.5,
                                                      ),
                                                    ),
                                                    depth: 4 * animationValue,
                                                  ),
                                                  child: Opacity(
                                                    opacity: animationValue,
                                                    child: child,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return AnimatedBuilder(
                                  animation: _controller,
                                  child: OverflowBox(
                                    maxWidth: (outerConstraints.maxWidth -
                                        (outerConstraints.maxWidth -
                                                constraints.maxWidth) *
                                            _controller.value),
                                    alignment: Alignment.bottomLeft,
                                    child: OverflowBox(
                                      maxWidth: constraints.maxWidth,
                                      alignment: Alignment.topLeft,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          top: 5,
                                          left: 10,
                                          right: 10,
                                        ),
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Text(
                                            App.data["blocks"].length
                                                .toString(),
                                            style: TextStyle(
                                              fontFamily: "Courier",
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  builder: (context, child) {
                                    double animationValue = isReversingAnimation
                                        ? pow(_controller.value, 15)
                                        : pow(_controller.value, 7.5);
                                    return OverflowBox(
                                      maxWidth: outerConstraints.maxWidth -
                                          (outerConstraints.maxWidth -
                                                  constraints.maxWidth) *
                                              _controller.value,
                                      alignment: Alignment.bottomLeft,
                                      child: Container(
                                        alignment: Alignment.bottomRight,
                                        child: Stack(
                                          alignment: Alignment.bottomRight,
                                          children: [
                                            SizedBox(
                                              width: constraints.maxWidth *
                                                  animationValue,
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: 30,
                                                    bottom: sqrt(
                                                            _controller.value) *
                                                        60),
                                                child: OverflowBox(
                                                  maxWidth:
                                                      constraints.maxWidth,
                                                  child: Align(
                                                    alignment:
                                                        Alignment.bottomLeft,
                                                    child: Opacity(
                                                      opacity: pow(
                                                          animationValue, 3),
                                                      child: Text(
                                                        "blocks",
                                                        style: Constants
                                                            .labelTextStyle,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 55,
                                              width: _controller.value *
                                                      (constraints.maxWidth -
                                                          55) +
                                                  55,
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    right: Constants.gap),
                                                child: Neumorphic(
                                                  style: NeumorphicStyle(
                                                    boxShape: NeumorphicBoxShape
                                                        .roundRect(
                                                      BorderRadius.circular(
                                                        27.5,
                                                      ),
                                                    ),
                                                    depth: 4 * animationValue,
                                                  ),
                                                  child: Opacity(
                                                    opacity: animationValue,
                                                    child: child,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          Expanded(child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  AnimatedBuilder(
                                      animation: _controller,
                                      builder: (context, child) {
                                        double animationValue =
                                            isReversingAnimation
                                                ? pow(_controller.value, 25)
                                                : pow(_controller.value, 12.5);
                                        return SizedBox(
                                          width: constraints.maxWidth *
                                              animationValue,
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                left: 30,
                                                bottom:
                                                    sqrt(_controller.value) *
                                                        60),
                                            child: OverflowBox(
                                              maxWidth: constraints.maxWidth,
                                              child: Align(
                                                alignment: Alignment.bottomLeft,
                                                child: Opacity(
                                                  opacity:
                                                      pow(animationValue, 3),
                                                  child: Text(
                                                    "points",
                                                    style: Constants
                                                        .labelTextStyle,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(right: Constants.gap),
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: SizedBox(
                                        height: 55,
                                        child: NeumorphicButton(
                                          onPressed: () {
                                            if (_controller.isAnimating) return;
                                            if (_controller.isCompleted) {
                                              _controller.reverse();
                                              isReversingAnimation = true;
                                            } else {
                                              _controller.forward();
                                              isReversingAnimation = false;
                                            }
                                          },
                                          style: NeumorphicStyle(
                                            boxShape:
                                                NeumorphicBoxShape.roundRect(
                                                    BorderRadius.circular(
                                                        27.5)),
                                          ),
                                          padding: EdgeInsets.zero,
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                              left: 10.0,
                                              right: 10.0,
                                              top: 5,
                                            ),
                                            child: SizedBox.expand(
                                              child: FittedBox(
                                                fit: BoxFit.contain,
                                                child: Text(
                                                  App.data["points"].toString(),
                                                  style: TextStyle(
                                                    fontFamily: "Courier",
                                                    fontSize: 30,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          )),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
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

  final Future<Response<String>> future = Dio()
      .get("http://192.168.178.26:8080/batch/${App.preferences.getString(App.preferencesKey)}");


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomNeumorphicAppBar(
        title: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            "Discover",
            style: Constants.titleTextStyle,
          ),
        ),
        buttonStyle: NeumorphicStyle(
          boxShape: NeumorphicBoxShape.circle(),
        ),
      ),
      body: Stack(
        children: [
          StreamBuilder<Response<String>>(
              stream: future.asStream(),
              builder: (context, snapshot) {
                List<dynamic> data;
                if(snapshot.hasData) {
                  data = jsonDecode(snapshot.data.data)["data"];
                } else {
                  data = List.empty();
                }
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
                          if((App.data["pending"] as List<dynamic>).where((element) => element["id"]==friend["id"]).length==0) {
                            (App.data["pending"] as List<dynamic>).add(friend);
                            App.controller.add(App.data);
                            App.channel.sink.add(jsonEncode({
                              "type": "request",
                              "friend": friend["id"],
                            }));
                          }

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
