import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

import 'constants.dart' as Constants;

class FriendRow extends StatelessWidget {
  final String iconData;
  final String name;
  final String status;
  final String colorString;
  final int points;
  final bool isButton;
  final Function onPressed;
  final Function onLongPress;

  FriendRow({
    this.iconData,
    this.name,
    this.status,
    this.colorString,
    this.points,
    this.isButton,
    this.onPressed,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context)  {
    print(name + ", " + status);
    return Padding(
      padding:
      const EdgeInsets.all(Constants.gap).copyWith(top: 0, bottom: 40),
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
          child: SizedBox(
            height: 55,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(15, 0, 10, 4),
                  child: Icon(
                    Constants.getIconData(iconData),
                    size: 35,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10, 5, 20, 0),
                    child: Text(
                      name,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: "Courier",
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
                      child: Text(
                        status,
                        maxLines: 2,
                        style: TextStyle(
                          fontFamily: "Courier",
                          fontSize: 15,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 60,
                    maxWidth: (MediaQuery.of(context).size.width-17*5)/4,
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.deferToChild,
                    onTap: isButton ? null : onPressed,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Align(
                        alignment: Alignment.center,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                              maxHeight: 50
                          ),
                          child: FittedBox(
                            fit: BoxFit.contain,
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
