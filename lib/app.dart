import 'dart:async';
import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';


import 'constants.dart' as Constants;



void updatePropertyRequest(String property, dynamic value, {bool update = true}) {
  data[property] = value;
  channel.sink.add(
      jsonEncode({"type": "change", "property": property, "value": value}));
  if(update) controller.add(data);
}

void customRequest(Map<String, dynamic> map) {
  channel.sink.add(jsonEncode(map));
}

const String preferencesKey = "id";
SharedPreferences preferences;

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

IOWebSocketChannel channel;
StreamController controller;

Stream<Map<String, dynamic>> stream;
Map<String, dynamic> data = {
  "name": "",
  "logo": "",
  "status": "new to points",
  "color": "white",
  "friends": [],
  "requests": [],
  "pending": [],
  "blocks": [],
};

void fs(Map<String, dynamic> friend, String command,
    {String remove, String place}) {
  channel.sink.add(
    jsonEncode({
      "type": command,
      "friend": friend["id"],
    }),
  );
  if (remove != null)
    data[remove] = (data[remove] as List<dynamic>)
        .where((element) => element["id"] != friend["id"])
        .toList();
  if (place != null) data[place].add(friend);
  controller.add(data);
}

void end() {
  controller.close();
  controller = null;

  channel?.sink?.close();
  channel = null;
}

void begin() {
  //ACHTUNG: DEFAULT VALUE VON EINEM STREAMBUILDER MUSS AUF App.data gestellt werden
  if (channel != null) {
    channel?.sink?.close();
    channel = null;
    controller.close();
    controller = null;
  }
  controller = StreamController<Map<String, dynamic>>();
  try {
    channel = IOWebSocketChannel.connect(
      'ws://${Constants.url}:3000',
      headers: {"id": preferences.getString(preferencesKey)},
    );
  } catch (error) {
    print(error);
  }

  channel.stream.listen((event) {
    final Map<String, dynamic> eventData = jsonDecode(event);
    print("data:\n" + eventData.toString());
    if (eventData["type"] == "initialupdate") {
      data = eventData;
    } else if (eventData["type"] == "selfupdate") {
      data[eventData["property"]] = eventData["value"];
    } else if (eventData["type"] == "friendupdate") {
      (data["friends"] + data["pending"] + data["requests"] as List)
              .firstWhere((element) => element["id"] == eventData["friend"])[
          eventData["property"]] = eventData["value"];
      if (eventData.containsKey("points")) data["gives"] -= eventData["points"];
    } else if (eventData["type"] == "fs") {
      final friend = eventData["friend"];
      if (eventData.containsKey("remove")) {
        (data[eventData["remove"]] as List)
            .removeWhere((element) => element["id"] == friend["id"]);
      }
      if (eventData.containsKey("place")) {
        (data[eventData["place"]] as List).add(friend);
      }
    } else if (eventData["type"] == "initialupdate") {
      data = eventData;
    } else {
      throw ErrorDescription("type nonexistnat");
    }
    controller.add(data);
  });
  stream = controller.stream.asBroadcastStream();
}
