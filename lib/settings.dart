import 'package:flutter/material.dart';
import 'custom_neumorphic_sliders.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'main.dart';
import 'constants.dart' as Constants;
import 'package:ionicons/ionicons.dart';
import 'package:flutter_icons/flutter_icons.dart' as icons;
import 'dart:convert';
import 'dart:io';

class Settings extends StatefulWidget {
  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  TextEditingController nameController;
  TextEditingController statusController;
  ScrollController scrollController;

  int color;

  @override
  void dispose() {
    nameController.dispose();
    statusController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    statusController = TextEditingController();
    scrollController = ScrollController();
  }

  String id;

  @override
  Widget build(BuildContext context) {
    // final Widget Function(int) generator = (index) {
    //   return Expanded(
    //     child: Padding(
    //       padding: const EdgeInsets.all(8.0),
    //       child: GestureDetector(onTap: () {
    //         if (color != index)
    //           setState(() {
    //             color = index;
    //             change("color", Constants.colorNames[index]);
    //           });
    //       }, child: LayoutBuilder(builder: (context, constraints) {
    //         return Neumorphic(
    //           child: SizedBox(
    //             height: constraints.maxWidth,
    //             width: constraints.maxWidth,
    //           ),
    //           style: NeumorphicStyle(
    //             color: Constants.colorCodes[Constants.colorNames[index]],
    //             depth: color == index ? 0 : 20,
    //             intensity: 0.75,
    //             boxShape: NeumorphicBoxShape.roundRect(
    //               BorderRadius.circular(constraints.maxWidth / 3.5),
    //             ),
    //             border: color == index
    //                 ? NeumorphicBorder(width: 2, color: Colors.grey[400])
    //                 : NeumorphicBorder(width: 0),
    //           ),
    //         );
    //       })),
    //     ),
    //   );
    // };
    return StreamBuilder(
      initialData: App.data,
      builder: (context, snapshot) {
        print("update");
        if (color == null || Constants.colorNames[color] != App.data["color"]) {
          print("updateColor");
          nameController.text = App.data["name"];
          statusController.text = App.data["status"];
          color = Constants.colorNames.indexOf(App.data["color"]);
        }
        return Scaffold(
          appBar: CustomNeumorphicAppBar(
            title: FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                "Settings",
                style: Constants.titleTextStyle,
              ),
            ),
            buttonStyle: NeumorphicStyle(boxShape: NeumorphicBoxShape.circle()),
            actions: [
              NeumorphicButton(
                child: Icon(
                  Ionicons.log_out_outline,
                ),
                style: NeumorphicStyle(
                  boxShape: NeumorphicBoxShape.circle(),
                ),
                onPressed: () {
                  App.preferences.remove(App.preferencesKey);
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              )
            ],
          ),
          body: Container(
            padding: EdgeInsets.all(25).copyWith(top: 0),
            child: Neumorphic(
              style: NeumorphicStyle(
                boxShape:
                    NeumorphicBoxShape.roundRect(BorderRadius.circular(25)),
              ),
              padding: EdgeInsets.all(10),
              child: SizedBox.expand(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        children: [
                          Neumorphic(
                            style: NeumorphicStyle(
                              depth:
                                  -NeumorphicTheme.currentTheme(context).depth,
                              boxShape: NeumorphicBoxShape.circle(),
                            ),
                            child: GestureDetector(
                              onTap: ([bool i]) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return IconSettings();
                                    },
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(30),
                                child: NeumorphicIcon(
                                  Constants.getIconData(
                                    App.data["logo"],
                                  ),
                                  size: 100,
                                  style: NeumorphicStyle(
                                    intensity: 0.75,
                                    color: Constants.colorCodes[
                                        Constants.colorNames[color]],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom: 7.5,
                                left: 20,
                                top: 10,
                              ),
                              child: Text(
                                "name",
                                style: Constants.labelTextStyle,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Neumorphic(
                              style: NeumorphicStyle(
                                depth: NeumorphicTheme.currentTheme(context)
                                        .depth *
                                    -1,
                                boxShape: NeumorphicBoxShape.roundRect(
                                    BorderRadius.circular(25)),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Theme(
                                data: ThemeData(
                                    textSelectionColor: Colors.grey[400]),
                                child: TextField(
                                  controller: nameController,
                                  enableSuggestions: false,
                                  keyboardType: TextInputType.name,
                                  cursorColor: Colors.grey[700],
                                  cursorWidth: 1.75,
                                  decoration: InputDecoration(
                                    hintStyle:
                                        TextStyle(color: Colors.grey[400]),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                    border: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                    counterText: "",
                                  ),
                                  style: TextStyle(fontFamily: "Courier"),
                                  maxLength: 10,
                                  autocorrect: false,
                                  onSubmitted: (string) {
                                    App.updatePropertyRequest("name", string);
                                  },
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom: 7.5,
                                left: 20,
                                top: 30,
                              ),
                              child: Text(
                                "status",
                                style: Constants.labelTextStyle,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Neumorphic(
                              style: NeumorphicStyle(
                                depth: NeumorphicTheme.currentTheme(context)
                                        .depth *
                                    -1,
                                boxShape: NeumorphicBoxShape.roundRect(
                                    BorderRadius.circular(25)),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Theme(
                                data: ThemeData(
                                    textSelectionColor: Colors.grey[400]),
                                child: TextField(
                                  controller: statusController,
                                  enableSuggestions: false,
                                  keyboardType: TextInputType.name,
                                  cursorColor: Colors.grey[700],
                                  cursorWidth: 1.75,
                                  decoration: InputDecoration(
                                    hintStyle:
                                        TextStyle(color: Colors.grey[400]),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                    border: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                    counterText: "",
                                  ),
                                  style: TextStyle(fontFamily: "Courier"),
                                  maxLength: 20,
                                  autocorrect: false,
                                  onSubmitted: (string) {
                                    App.updatePropertyRequest("status", string);
                                  },
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom: 7.5,
                                left: 10,
                                top: 30,
                              ),
                              child: Text(
                                "color",
                                style: Constants.labelTextStyle,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: List.generate(
                                5,
                                (i) {
                                  return Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.all(6.5),
                                      child: AspectRatio(
                                        aspectRatio: 1,
                                        child: NeumorphicRadio(
                                          style: NeumorphicRadioStyle(
                                            selectedColor: Constants.colorCodes[
                                                Constants.colorNames[i]],
                                            unselectedColor:
                                                Constants.colorCodes[
                                                    Constants.colorNames[i]],
                                            intensity: 0.8,
                                            selectedDepth: 20,
                                            boxShape:
                                                NeumorphicBoxShape.roundRect(
                                                    BorderRadius.circular(15)),
                                          ),
                                          groupValue: color,
                                          value: i,
                                          onChanged: (index) {
                                            setState(() {
                                              color = index;
                                              App.updatePropertyRequest("color",
                                                  Constants.colorNames[index]);
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: List.generate(
                                5,
                                (i) {
                                  return Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.all(6.5),
                                      child: AspectRatio(
                                        aspectRatio: 1,
                                        child: NeumorphicRadio(
                                          style: NeumorphicRadioStyle(
                                            selectedColor: Constants.colorCodes[
                                                Constants.colorNames[i + 5]],
                                            unselectedColor: Constants
                                                    .colorCodes[
                                                Constants.colorNames[i + 5]],
                                            intensity: 0.8,
                                            selectedDepth: 20,
                                            boxShape:
                                                NeumorphicBoxShape.roundRect(
                                                    BorderRadius.circular(15)),
                                          ),
                                          groupValue: color,
                                          value: i + 5,
                                          onChanged: (index) {
                                            setState(() {
                                              color = index;
                                              App.updatePropertyRequest("color",
                                                  Constants.colorNames[index]);
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                        ],
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
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: 20,
                        alignment: Alignment.bottomCenter,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                          end: Alignment.bottomCenter,
                          begin: Alignment.topCenter,
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
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class IconSettings extends StatefulWidget {
  @override
  _IconSettingsState createState() => _IconSettingsState();
}

class _IconSettingsState extends State<IconSettings> {
  int position;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
        stream: App.stream,
        builder: (context, snapshot) {
          String logo = App.data["logo"];
          if (logo == "") logo = "person";
          position = Constants.normalIcons.indexOf(logo) == -1
              ? (Constants.logoIcons.indexOf(logo) +
                  Constants.normalIcons.length)
              : Constants.normalIcons.indexOf(logo);
          return Scaffold(
            appBar: CustomNeumorphicAppBar(
              title: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  "Icons",
                  style: Constants.titleTextStyle,
                ),
              ),
              buttonStyle:
                  NeumorphicStyle(boxShape: NeumorphicBoxShape.circle()),
            ),
            body: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 9,
                      ),
                      itemCount: Constants.logoIcons.length +
                          Constants.normalIcons.length,
                      itemBuilder: (context, index) {
                        return FlatButton(
                          padding: EdgeInsets.zero,
                          color: position == index
                              ? Theme.of(context).focusColor
                              : Colors.transparent,
                          splashColor: Colors.transparent,
                          onPressed: () {
                            if (position == index) return;
                            App.updatePropertyRequest(
                                "logo",
                                index >= Constants.normalIcons.length
                                    ? Constants.logoIcons[
                                        index - Constants.normalIcons.length]
                                    : Constants.normalIcons[index]);
                          },
                          shape: CircleBorder(),
                          child: Icon(() {
                            if (index >= Constants.normalIcons.length) {
                              return icons.Ionicons.getIconData("logo-" +
                                  Constants.logoIcons[
                                      index - Constants.normalIcons.length]);
                            }
                            return icons.Ionicons.getIconData(
                                (Platform.isIOS ? "ios-" : "md-") +
                                    Constants.normalIcons[index]);
                          }()),
                        );
                      }),
                ),
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
                        NeumorphicTheme.of(context)
                            .current
                            .baseColor
                            .withAlpha(0)
                      ],
                    )),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
