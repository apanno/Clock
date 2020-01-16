// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum _Element {
  background,
  text,
  other,
  location,
}

final _lightTheme = {
  _Element.background: Colors.white ,
  _Element.text: Color(0xFF1a2124) ,
  _Element.other: Color(0xFF1a2124) ,
  _Element.location: Color(0xFF1a2124)
};

final _darkTheme = {
  _Element.background: Colors.white,
  _Element.text: Color(0xFF1a2124) ,
  _Element.other: Color(0xFF1a2124),
  _Element.location: Color(0xFF1a2124)
};

/// A basic digital clock.
///
/// You can do better than this!
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;
  var _condition = '';
  double _temperature;
  var _formatedTemp = '';
  var _unit = '';
  var _location = '';
  bool _is24format = false;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
      _condition = widget.model.weatherString;
      _temperature = widget.model.temperature;
      _unit = widget.model.unitString;
      _formatedTemp = _temperature.round().toString() + _unit;
      _location = widget.model.location;
      _is24format = widget.model.is24HourFormat;
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per minute. If you want to update every second, use the
      // following code.

      // _timer = Timer(
      //   Duration(minutes: 1) -
      //       Duration(seconds: _dateTime.second) -
      //       Duration(milliseconds: _dateTime.millisecond),
      //   _updateTime,
      // );

      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hour =
    DateFormat(widget.model.is24HourFormat ? 'HH':'hh').format(_dateTime);
    final rawHour = DateFormat('HH').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final seconds = DateFormat('s').format(_dateTime);
    final tempSize = MediaQuery.of(context).size.width / 7.0;
    final iconSize = MediaQuery.of(context).size.width / 15; //5

    final customTextStyle = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'Sarabun-Bold',
    );
    final weatherStyle = TextStyle(
      color: colors[_Element.other],
      fontFamily: 'Sarabun-Light',
      fontSize: iconSize,
    );
    final tempStyle = TextStyle(
      color: colors[_Element.other],
      fontFamily: 'Sarabun-Thin',
      fontSize: tempSize,
    );
    final separatorStyle = TextStyle(
      color: changeColor(int.parse(seconds)),
      height: 1.0,
    );

    return Container(
      color: Color(0xFFffffff),
      child: Row(
        children: <Widget>[
          Expanded(
            child: DefaultTextStyle(
              style: customTextStyle,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: FittedBox(
                  alignment: Alignment.center,
                  fit: BoxFit.fitWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      getFormat(_is24format, _dateTime),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(hour),
                          Text(
                            ":",
                            style: separatorStyle,
                          ),
                          Text(minute),
                        ],
                      ),
                      Text(
                        _location,
                        maxLines: 2,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 4,
                          color: colors[_Element.location],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.4218759,
            color: colors[_Element.background],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    getWeather(_condition, int.parse(rawHour)),
                    style: weatherStyle,
                  ),
                  Text(
                    _formatedTemp,
                    style: tempStyle,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String getWeather(String weather, int hour) {
  bool isDay = false;
  if (hour >= 6 && hour < 19) {
    //day
    isDay = true;
  } else {
    //night
    isDay = false;
  }

  if (weather == 'cloudy') {
    if (isDay)
      return 'Cloudy';
    else
      return 'Cloudy';
  } else if (weather == 'foggy') {
    if (isDay)
      return 'Foggy';
    else
      return 'Foggy';
  } else if (weather == 'rainy') {
    return 'Rainy';
  } else if (weather == 'snowy') {
    return 'Snowy';
  } else if (weather == 'sunny') {
    if (isDay)
      return 'Sunny';
    else
      return 'Sunny';
  } else if (weather == 'thunderstorm') {
    return 'Thunderstorm';
  } else if (weather == 'windy') {
    return 'Windy';
  }
}

Color changeColor(int second) {
  if (second % 2 == 0) {
    return Colors.white;
  } else {
    return Color(0xFF1a2124);
  }
}

Text getFormat(bool _is24Format, DateTime _dateTime) {
  if (_is24Format) {
    return Text(
      '',
      style: TextStyle(fontSize: 0),
    );
  } else {
    var ampm = DateFormat('a').format(_dateTime);
    return Text(
      ampm,
      textAlign: TextAlign.end,
      style: TextStyle(
        fontSize: 5,
      ),
    );
  }
}