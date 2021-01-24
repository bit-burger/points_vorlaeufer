import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'constants.dart' as Constants;

class FriendRow extends StatelessWidget {
  final String iconData;
  final String title;
  final String status;
  final String colorString;
  final int points;
  final bool isButton;
  final Function onPressed;
  final Function onLongPress;
  FriendRow({
    this.iconData,
    this.title,
    this.status,
    this.colorString,
    this.points,
    this.isButton,
    this.onPressed,
    this.onLongPress,
  });
  @override
  Widget build(BuildContext context) {
    assert(!isButton||onLongPress==null);
    final body = SizedBox(
      height: 55,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(15, 0, 0, 4),
            child: Icon(
              Constants.getIconData(iconData),
              size: 35,
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: "Courier",
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 5, 10, 0),
                child: Text(
                  status,
                  style: TextStyle(
                    fontFamily: "Courier",
                    fontSize: 15,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: isButton ? null : onPressed,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 5, 20, 0),
              child: Text(
                points.toString(),
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
    );
    return isButton
        ? Padding(
            padding: const EdgeInsets.all(20).copyWith(top: 0, bottom: 40),
            child: NeumorphicButton(
              padding: EdgeInsets.zero,
              duration: Duration(milliseconds: 250),
              onPressed: onPressed,
              style: NeumorphicStyle(
                boxShape:
                    NeumorphicBoxShape.roundRect(BorderRadius.circular(27.5)),
                color: Constants.colorCodes[colorString],
              ),
              child: body,
            ),
          )
        : GestureDetector(
            onLongPress: onLongPress,
            child: Padding(
              padding: const EdgeInsets.all(20).copyWith(top: 0, bottom: 40),
              child: Neumorphic(
                duration: Duration(seconds: 1),
                style: NeumorphicStyle(
                  boxShape:
                      NeumorphicBoxShape.roundRect(BorderRadius.circular(27.5)),
                  color: Constants.colorCodes[colorString],
                ),
                child: body,
              ),
            ),
          );
  }
}
