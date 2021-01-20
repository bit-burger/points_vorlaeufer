import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter/services.dart';


class CustomNeumorphicAppBar extends StatefulWidget implements PreferredSizeWidget {
  static const toolbarHeight = kToolbarHeight + 16 * 2;
  static const defaultSpacing = 4.0;

  /// The primary widget displayed in the app bar.
  ///
  /// Typically a [Text] widget that contains a description of the current
  /// contents of the app.
  final Widget title;

  /// A widget to display before the [title].
  ///
  /// Typically the [leading] widget is an [Icon] or an [IconButton].
  ///
  /// Becomes the leading component of the [NavigationToolBar] built
  /// by this widget. The [leading] widget's width and height are constrained to
  /// be no bigger than toolbar's height, which is [kToolbarHeight].
  ///
  /// If this is null and [automaticallyImplyLeading] is set to true, the
  /// [CustomNeumorphicAppBar] will imply an appropriate widget. For example, if the [CustomNeumorphicAppBar] is
  /// in a [Scaffold] that also has a [Drawer], the [Scaffold] will fill this
  /// widget with an [IconButton] that opens the drawer (using [Icons.menu]). If
  /// there's no [Drawer] and the parent [Navigator] can go back, the [CustomNeumorphicAppBar]
  /// will use a [NeumorphicBackButton] that calls [Navigator.maybePop].
  final Widget leading;

  /// Whether the title should be centered.
  ///
  /// Defaults to being adapted to the current [TargetPlatform].
  final bool centerTitle;

  /// Widgets to display in a row after the [title] widget.
  ///
  /// Typically these widgets are [IconButton]s representing common operations.
  /// For less common operations, consider using a [PopupMenuButton] as the
  /// last action.
  ///
  /// The [actions] become the trailing component of the [NavigationToolBar] built
  /// by this widget. The height of each action is constrained to be no bigger
  /// than the toolbar's height, which is [kToolbarHeight].
  final List<Widget> actions;

  /// Controls whether we should try to imply the leading widget if null.
  ///
  /// If true and [leading] is null, automatically try to deduce what the leading
  /// widget should be. If false and [leading] is null, leading space is given to [title].
  /// If leading widget is not null, this parameter has no effect.
  final bool automaticallyImplyLeading;

  /// The spacing around [title] content on the horizontal axis. This spacing is
  /// applied even if there is no [leading] content or [actions]. If you want
  /// [title] to take all the space available, set this value to 0.0.
  ///
  /// Defaults to [NavigationToolbar.kMiddleSpacing].
  final double titleSpacing;

  /// The spacing [actions] left side, useful to have spacing between actions
  ///
  /// Defaults to [CustomNeumorphicAppBar.defaultSpacing].
  final double actionSpacing;

  /// Force background color of the app bar
  final Color color;

  /// Force color of the icon inside app bar
  final IconThemeData iconTheme;

  @override
  final Size preferredSize;

  final NeumorphicStyle buttonStyle;

  final EdgeInsets buttonPadding;

  final TextStyle textStyle;

  final double padding;
  final Widget customBackWidget;

  CustomNeumorphicAppBar({
    Key key,
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
    this.customBackWidget
  })  : preferredSize = Size.fromHeight(toolbarHeight),
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
    final bool useCloseButton =
        parentRoute is PageRoute<dynamic> && parentRoute.fullscreenDialog;
    final ScaffoldState scaffold = Scaffold.of(context, nullOk: true);
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
          leading = widget.customBackWidget ?? NeumorphicButton(
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
typedef void NeumorphicIconButtonClickListener([bool bool]);

@immutable
class NeumorphicIconButton extends StatefulWidget {
  static const double PRESSED_SCALE = 0.98;
  static const double UNPRESSED_SCALE = 1.0;

  final IconData icon;
  final IconData secondIcon;
  final Color iconColor;
  final double iconSize;
  final NeumorphicStyle style;
  final double minDistance;
  final bool pressed; //null, true, false
  final Duration duration;
  final Curve curve;
  final NeumorphicIconButtonClickListener onPressed;
  final bool drawSurfaceAboveChild;
  final bool provideHapticFeedback;
  final String tooltip;
  final bool on;
  final bool disabled;

  NeumorphicIconButton(this.icon,{
    Key key,
    this.disabled = false,
    this.on = true,
    this.iconSize,
    this.iconColor,
    this.secondIcon,
    this.tooltip,
    this.drawSurfaceAboveChild = true,
    this.pressed, //true/false if you want to change the state of the button
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOut,
    //this.accent,
    this.onPressed,
    this.minDistance = 0,
    this.style,
    this.provideHapticFeedback = true,
  }) : super(key: key);

  bool get isEnabled => onPressed != null;

  @override
  _NeumorphicIconButtonState createState() => _NeumorphicIconButtonState();
}

class _NeumorphicIconButtonState extends State<NeumorphicIconButton> {
  NeumorphicStyle initialStyle;


  double depth;
  bool pressed = false; //overwrite widget.pressed when click for animation
  bool on;
  bool disabled;
  void updateInitialStyle() {
    this.on = widget.on;

    final appBarPresent = NeumorphicAppBarTheme.of(context) != null;
    if (widget.style != initialStyle || initialStyle == null||disabled!=widget.disabled) {
      this.disabled = widget.disabled;
      final theme = NeumorphicTheme.currentTheme(context);
      setState(() {
        this.initialStyle = widget.style ??
            (appBarPresent
                ? theme.appBarTheme.buttonStyle
                : (theme.buttonStyle ?? const NeumorphicStyle()));
        depth = widget.style?.depth ??
            (appBarPresent ? theme.appBarTheme.buttonStyle.depth : theme.depth);
      });
    }
  }

  @override
  void didChangeDependencies() {
    print("UPDATED");
    super.didChangeDependencies();
    updateInitialStyle();
  }


  @override
  void didUpdateWidget(Widget oldWidget) {
    print("OKOK");
    if(widget.disabled!=this.disabled) {
      this.disabled = widget.disabled;
      updateInitialStyle();
    } else {
      setState(() {

      });
    }
    updateInitialStyle();
    super.didUpdateWidget(oldWidget);
  }


  Future<void> _handlePress() async {

    if(disabled) return;
    hasFinishedAnimationDown = false;
    setState(() {
      pressed = true;
      depth = widget.minDistance;
    });

    on = !on;
    await Future.delayed(widget.duration);
    //wait until animation finished
    hasFinishedAnimationDown = true;

    //haptic vibration
    if (widget.provideHapticFeedback) {
      HapticFeedback.lightImpact();
    }

    _resetIfTapUp();
  }

  bool hasDisposed = false;

  @override
  void dispose() {
    super.dispose();
    hasDisposed = true;
  }

  //used to stay pressed if no tap up
  void _resetIfTapUp() {
    if (hasFinishedAnimationDown == true && hasTapUp == true && !hasDisposed) {
      setState(() {
        pressed = false;
        depth = initialStyle.depth;

        hasFinishedAnimationDown = false;
        hasTapUp = false;
      });
    }
  }

  bool get clickable {
    return widget.isEnabled && widget.onPressed != null;
  }

  bool hasFinishedAnimationDown = false;
  bool hasTapUp = false;

  @override
  Widget build(BuildContext context) {
    final result = _build(context);
    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip,
        child: result,
      );
    } else {
      return result;
    }
  }

  Widget _build(BuildContext context) {
    final icon = widget.secondIcon==null ? widget.icon : on ? widget.icon : widget.secondIcon;
    return GestureDetector(
      onTapDown: (detail) {
        hasTapUp = false;
        if (clickable && !pressed) {
          _handlePress();
        }
      },
      onTapUp: (details) {
        if (clickable) {
          if(widget.secondIcon==null) {
            widget.onPressed();
          } else {
            widget.onPressed(on);
          }
        }
        hasTapUp = true;
        _resetIfTapUp();
      },
      onTapCancel: () {
        hasTapUp = true;
        _resetIfTapUp();
      },
      child: AnimatedScale(
          scale: _getScale(),
          child: NeumorphicIcon(
            icon,
            size: widget.iconSize,
            duration: widget.duration,
            curve: widget.curve,
            style: initialStyle.copyWith(
              color: widget.iconColor,
              depth: _getDepth(),
            ),
          )
      ),
    );
  }

  double _getDepth() {
    if (widget.isEnabled) {
      return (this.disabled ? 0.5 : depth);
    } else {
      return 0;
    }
  }

  double _getScale() {
    if (widget.pressed != null) {
      //defined by the widget that use it
      return widget.pressed
          ? NeumorphicIconButton.PRESSED_SCALE
          : NeumorphicIconButton.UNPRESSED_SCALE;
    } else {
      return this.pressed
          ? NeumorphicIconButton.PRESSED_SCALE
          : NeumorphicIconButton.UNPRESSED_SCALE;
    }
  }
}
class AnimatedScale extends StatefulWidget {
  final Widget child;
  final double scale;
  final Duration duration;
  final Alignment alignment;

  const AnimatedScale({
    this.child,
    this.scale = 1,
    this.duration = const Duration(milliseconds: 150),
    this.alignment = Alignment.center,
  });

  @override
  _AnimatedScaleState createState() => _AnimatedScaleState();
}

class _AnimatedScaleState extends State<AnimatedScale>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;
  double oldScale = 1;

  @override
  void initState() {
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: widget.scale, end: widget.scale)
        .animate(_controller);
    super.initState();
  }

  @override
  void didUpdateWidget(AnimatedScale oldWidget) {
    if (oldWidget.scale != widget.scale) {
      _controller.reset();
      oldScale = oldWidget.scale;
      _animation = Tween<double>(begin: oldScale, end: widget.scale)
          .animate(_controller);
      _controller.forward();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      alignment: widget.alignment,
      child: widget.child,
    );
  }
}
