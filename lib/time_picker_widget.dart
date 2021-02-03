import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/constants.dart';
import 'package:flutter_cupertino_date_picker/locale_message.dart';

/// DatePicker widget.
///
/// @author dylan wu
/// @since 2019-05-10
class TimePickerWidget extends StatefulWidget {
  TimePickerWidget(
      {Key key,
      this.showTitleActions: false,
      this.is24 = true,
      this.backgroundColor: Colors.white,
      this.cancel,
      this.confirm,
      this.onCancel,
      this.locale = 'zh',
      this.onChanged2,
      this.onConfirm2,
      this.initialHour = 0,
      this.initialMinute = 0})
      : super(key: key);

  final bool showTitleActions;
  final bool is24;
  final Color backgroundColor;
  final int initialHour, initialMinute;
  final String locale;

  final Widget cancel, confirm;
  final DateVoidCallback onCancel;
  final TimeValueCallback onChanged2, onConfirm2;

  @override
  State<StatefulWidget> createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  FixedExtentScrollController _hourScrollCtrl, _minutesScrollCtrl;

  int _currHour, _currMinute;
  List<int> hourValues = [];

  _TimePickerWidgetState();

  @override
  void initState() {
    if (widget.is24) {
      for (int i = 0; i < 23; i++) {
        hourValues.add(i);
      }
      this._currHour = widget.initialHour ?? 0;
      this._currMinute = widget.initialMinute ?? 0;
    } else {
      for (int i = 1; i < 13; i++) {
        hourValues.add(i);
      }
      int hour = widget.initialHour ?? 0;
      this._currHour = hour > 12 ? hour - 12 : hour;
      this._currMinute = widget.initialMinute ?? 0;
    }

    _hourScrollCtrl = FixedExtentScrollController(initialItem: _currHour);
    _minutesScrollCtrl = FixedExtentScrollController(initialItem: _currMinute);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Material(
          color: Colors.transparent, child: _renderPickerView(context)),
    );
  }

  /// render date picker widgets
  Widget _renderPickerView(BuildContext context) {
    Widget timePickerWidget = _renderTimePickerWidget();
    if (widget.showTitleActions) {
      return Column(
          children: <Widget>[_renderTitleWidget(context), timePickerWidget]);
    }
    return timePickerWidget;
  }

  /// render title action widgets
  Widget _renderTitleWidget(BuildContext context) {
    Widget cancelWidget = widget.cancel;
    if (cancelWidget == null) {
      var cancelText = LocaleMessage.getLocaleCancel(widget.locale);
      cancelWidget = Text(cancelText,
          style: TextStyle(
              color: Theme.of(context).unselectedWidgetColor, fontSize: 16.0));
    }

    Widget confirmWidget = widget.confirm;
    if (confirmWidget == null) {
      var confirmText = LocaleMessage.getLocaleDone(widget.locale);
      confirmWidget = Text(confirmText,
          style:
              TextStyle(color: Theme.of(context).primaryColor, fontSize: 16.0));
    }

    return Container(
      height: DATE_PICKER_TITLE_HEIGHT,
      decoration: BoxDecoration(color: widget.backgroundColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            height: DATE_PICKER_TITLE_HEIGHT,
            child: FlatButton(
                child: cancelWidget, onPressed: () => _onPressedCancel()),
          ),
          Container(
            height: DATE_PICKER_TITLE_HEIGHT,
            child: FlatButton(
                child: confirmWidget, onPressed: () => _onPressedConfirm()),
          ),
        ],
      ),
    );
  }

  /// pressed cancel widget
  void _onPressedCancel() {
    if (widget.onCancel != null) {
      widget.onCancel();
    }
    Navigator.pop(context);
  }

  /// pressed confirm widget
  void _onPressedConfirm() {
    if (widget.onConfirm2 != null) {
      widget.onConfirm2(widget.is24? _currHour: _currHour+12, _currMinute);
    }
    Navigator.pop(context);
  }

  /// render the picker widget of year、month and day
  Widget _renderTimePickerWidget() {
    List<Widget> pickers = List<Widget>();
    String yearAppend = LocaleMessage.getLocaleYearUnit(widget.locale);
    pickers.add(_renderHoursPickerComponent(yearAppend));

    String monthAppend = LocaleMessage.getLocaleMonthUnit(widget.locale);
    pickers.add(_renderMinutesPickerComponent(
      monthAppend,
    ));
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, children: pickers);
  }

  /// render the picker component of year
  Widget _renderHoursPickerComponent(String yearAppend) {
    return Expanded(
      flex: 1,
      child: Container(
        padding: EdgeInsets.all(8.0),
        height: DATE_PICKER_HEIGHT,
        decoration: BoxDecoration(color: widget.backgroundColor),
        child: CupertinoPicker.builder(
          backgroundColor: widget.backgroundColor,
          scrollController: _hourScrollCtrl,
          itemExtent: DATE_PICKER_ITEM_HEIGHT,
          onSelectedItemChanged: (int index) => _changeHourSelection(index),
          childCount: hourValues.length,
          itemBuilder: (context, index) {
            return Container(
              height: DATE_PICKER_ITEM_HEIGHT,
              alignment: Alignment.center,
              child: Text(
                '${hourValues[index]}',
                style: TextStyle(
                    color: DATE_PICKER_TEXT_COLOR,
                    fontSize: DATE_PICKER_FONT_SIZE),
              ),
            );
          },
        ),
      ),
    );
  }

  /// change the selection of year picker
  void _changeHourSelection(int index) {
    _currHour = index;
    _notifyDateChanged();
  }

  /// render the picker component of month
  Widget _renderMinutesPickerComponent(String monthAppend, {String format}) {
    return Expanded(
      flex: 1,
      child: Container(
        padding: EdgeInsets.all(8.0),
        height: DATE_PICKER_HEIGHT,
        decoration: BoxDecoration(color: widget.backgroundColor),
        child: CupertinoPicker.builder(
          backgroundColor: widget.backgroundColor,
          scrollController: _minutesScrollCtrl,
          itemExtent: DATE_PICKER_ITEM_HEIGHT,
          onSelectedItemChanged: (int index) => _changeMinutesSelection(index),
          childCount: 60,
          itemBuilder: (context, index) {
            return Container(
              height: DATE_PICKER_ITEM_HEIGHT,
              alignment: Alignment.center,
              child: Text(
                '$index',
                style: TextStyle(
                    color: DATE_PICKER_TEXT_COLOR,
                    fontSize: DATE_PICKER_FONT_SIZE),
              ),
            );
          },
        ),
      ),
    );
  }

  void _changeMinutesSelection(int index) {
    _currMinute = index;
    _notifyDateChanged();
  }

  /// notify selected date changed
  void _notifyDateChanged() {
    if (widget.onChanged2 != null) {
      widget.onChanged2(widget.is24? _currHour: _currHour+12, _currMinute);
    }
  }
}
