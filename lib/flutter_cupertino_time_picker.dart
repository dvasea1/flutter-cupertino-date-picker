///
/// author: Dylan Wu
/// since: 2018/06/21
///
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/constants.dart';
import 'package:flutter_cupertino_date_picker/time_picker_widget.dart';

class TimePicker {
  ///
  /// Display date picker bottom sheet.
  ///
  /// cancel: Custom cancel button
  /// confirm: Custom confirm button
  ///
  static void showTimePicker(BuildContext context,
      {bool showTitleActions: true,
      Widget? cancel,
      Widget? confirm,
      DateVoidCallback? onCancel,
      TimeValueCallback? onChanged2,
      TimeValueCallback? onConfirm2,
      locale: DATE_PICKER_LOCALE_DEFAULT,
      bool is24 = true,
      required int initialHour,
      initialMinute}) {
    Navigator.push(
      context,
      new _TimePickerRoute(
        showTitleActions: showTitleActions,
        is24: is24,
        initialHour: initialHour,
        initialMinute: initialMinute,
        cancel: cancel,
        confirm: confirm,
        onChanged2: onChanged2,
        onConfirm2: onConfirm2,
        onCancel: onCancel,
        locale: locale,
        theme: Theme.of(context, ),
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
      ),
    );
  }
}

class _TimePickerRoute<T> extends PopupRoute<T> {
  _TimePickerRoute({
    this.showTitleActions = true,
    this.cancel,
    this.confirm,
    this.is24 = true,
    required this.initialMinute,
    this.onChanged2,
    this.onConfirm2,
    this.onCancel,
    this.theme,
    this.barrierLabel,
    required this.locale,
    required this.initialHour,
    RouteSettings? settings,
  }) : super(settings: settings);

  final bool showTitleActions;

  final Widget? cancel, confirm;
  final VoidCallback? onCancel;

  final TimeValueCallback? onChanged2;
  final TimeValueCallback? onConfirm2;
  final bool is24;
  final int initialHour, initialMinute;

  final ThemeData? theme;
  final String locale;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  bool get barrierDismissible => true;

  @override
  final String? barrierLabel;

  @override
  Color get barrierColor => Colors.black54;

  late AnimationController _animationController;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    _animationController =
        BottomSheet.createAnimationController(navigator!.overlay!);
    return _animationController;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    Widget bottomSheet = new MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: _TimePickerComponentStateless(
        route: this,
        pickerHeight: showTitleActions
            ? DATE_PICKER_TITLE_HEIGHT + DATE_PICKER_HEIGHT
            : DATE_PICKER_HEIGHT,
      ),
    );
    if (theme != null) {
      bottomSheet = new Theme(data: theme!, child: bottomSheet);
    }
    return bottomSheet;
  }
}

class _TimePickerComponentStateless extends StatelessWidget {
  final _TimePickerRoute route;
  final double _pickerHeight;

  _TimePickerComponentStateless(
      {Key? key, required this.route, required pickerHeight})
      : this._pickerHeight = pickerHeight;

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      child: new AnimatedBuilder(
        animation: route.animation!,
        builder: (BuildContext context, Widget? child) {
          return new ClipRect(
            child: new CustomSingleChildLayout(
              delegate: new _BottomPickerLayout(route.animation!.value,
                  pickerHeight: _pickerHeight),
              child: TimePickerWidget(
                showTitleActions: route.showTitleActions,
                locale: route.locale,
                cancel: route.cancel,
                confirm: route.confirm,
                onCancel: route.onCancel,
                onChanged2: route.onChanged2,
                onConfirm2: route.onConfirm2,
                is24: route.is24,
                initialHour: route.initialHour,
                initialMinute: route.initialMinute,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BottomPickerLayout extends SingleChildLayoutDelegate {
  _BottomPickerLayout(this.progress, {required this.pickerHeight});

  final double progress;
  final double pickerHeight;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return new BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      minHeight: 0.0,
      maxHeight: pickerHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double height = size.height - childSize.height * progress;
    return new Offset(0.0, height);
  }

  @override
  bool shouldRelayout(_BottomPickerLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
