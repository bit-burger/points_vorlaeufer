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
          AbsorbPointer(
            absorbing: false,
            child: GestureDetector(
              behavior: HitTestBehavior.deferToChild,
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
          ),
        ],
      ),
    );
    return Padding(
            padding: const EdgeInsets.all(Constants.gap).copyWith(top: 0, bottom: 40),
            child: GestureDetector(
              onLongPress: onLongPress,
              child: NeumorphicButton(
                padding: EdgeInsets.zero,
                onPressed: onPressed,
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
