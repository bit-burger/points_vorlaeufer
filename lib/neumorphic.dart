import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class CustomNeumorphicAppBar extends StatefulWidget
    implements PreferredSizeWidget {
  static const toolbarHeight = kToolbarHeight + 16 * 2;
  static const defaultSpacing = 4.0;
  final Widget title;
  final Widget leading;
  final bool centerTitle;
  final List<Widget> actions;
  final bool automaticallyImplyLeading;
  final double titleSpacing;
  final double actionSpacing;
  final Color color;
  final IconThemeData iconTheme;
  @override
  final Size preferredSize;
  final NeumorphicStyle buttonStyle;
  final EdgeInsets buttonPadding;
  final TextStyle textStyle;
  final double padding;
  final Widget customBackWidget;

  CustomNeumorphicAppBar(
      {Key key,
      this.title,
      this.buttonPadding,
      this.buttonStyle,
      this.iconTheme,
      this.color,
      this.actions,
      this.textStyle,
      this.leading,
      this.automaticallyImplyLeading = true,
      this.centerTitle,
      this.titleSpacing = NavigationToolbar.kMiddleSpacing,
      this.actionSpacing = defaultSpacing,
      this.padding = 16,
      this.customBackWidget})
      : preferredSize = Size.fromHeight(toolbarHeight),
        super(key: key);

  @override
  CustomNeumorphicAppBarState createState() => CustomNeumorphicAppBarState();

  bool _getEffectiveCenterTitle(ThemeData theme, NeumorphicThemeData nTheme) {
    if (centerTitle != null || nTheme.appBarTheme.centerTitle != null)
      return centerTitle ?? nTheme.appBarTheme.centerTitle;
    assert(theme.platform != null);
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return false;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return actions == null || actions.length < 2;
    }
    return null;
  }
}

class CustomNeumorphicAppBarState extends State<CustomNeumorphicAppBar> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final nTheme = NeumorphicTheme.of(context);
    final ModalRoute<dynamic> parentRoute = ModalRoute.of(context);
    final bool canPop = parentRoute?.canPop ?? false;
    final ScaffoldState scaffold = Scaffold.of(context);
    final bool hasDrawer = scaffold?.hasDrawer ?? false;
    final bool hasEndDrawer = scaffold?.hasEndDrawer ?? false;

    Widget leading = widget.leading;
    if (leading == null && widget.automaticallyImplyLeading) {
      if (hasDrawer) {
        leading = NeumorphicButton(
          padding: widget.buttonPadding,
          style: widget.buttonStyle,
          child: nTheme.current.appBarTheme.icons.menuIcon,
          onPressed: _handleDrawerButton,
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
        );
      } else {
        if (canPop)
          leading = widget.customBackWidget ??
              NeumorphicButton(
                style: NeumorphicStyle(
                  boxShape: NeumorphicBoxShape.circle(),
                ),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                child: Icon(Icons.arrow_back),
                onPressed: () => Navigator.maybePop(context),
              );
      }
    }
    if (leading != null) {
      leading = ConstrainedBox(
        constraints: const BoxConstraints.tightFor(width: kToolbarHeight),
        child: leading,
      );
    }

    Widget title = widget.title;
    if (title != null) {
      final AppBarTheme appBarTheme = AppBarTheme.of(context);
      title = DefaultTextStyle(
        style: (appBarTheme.textTheme?.headline5 ??
                Theme.of(context).textTheme.headline5)
            .merge(widget.textStyle ?? nTheme.current.appBarTheme.textStyle),
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        child: title,
      );
    }

    Widget actions;
    if (widget.actions != null && widget.actions.isNotEmpty) {
      actions = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widget.actions
            .map((child) => Padding(
                  padding: EdgeInsets.only(left: widget.actionSpacing),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints.tightFor(
                        width: kToolbarHeight, height: kToolbarHeight),
                    child: child,
                  ),
                ))
            .toList(growable: false),
      );
    } else if (hasEndDrawer) {
      actions = ConstrainedBox(
        constraints: const BoxConstraints.tightFor(
            width: kToolbarHeight, height: kToolbarHeight),
        child: NeumorphicButton(
          padding: widget.buttonPadding,
          style: widget.buttonStyle,
          child: nTheme.current.appBarTheme.icons.menuIcon,
          onPressed: _handleDrawerButtonEnd,
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
        ),
      );
    }
    return Container(
      color: widget.color ?? nTheme.current.appBarTheme.color,
      child: SafeArea(
        bottom: false,
        child: NeumorphicAppBarTheme(
          child: Padding(
            padding: EdgeInsets.all(widget.padding),
            child: IconTheme(
              data: widget.iconTheme ??
                  nTheme.current.appBarTheme.iconTheme ??
                  nTheme.current.iconTheme ??
                  const IconThemeData(),
              child: NavigationToolbar(
                leading: leading,
                middle: title,
                trailing: actions,
                centerMiddle:
                    widget._getEffectiveCenterTitle(theme, nTheme.current),
                middleSpacing: widget.titleSpacing,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleDrawerButton() {
    Scaffold.of(context).openDrawer();
  }

  void _handleDrawerButtonEnd() {
    Scaffold.of(context).openEndDrawer();
  }
}
