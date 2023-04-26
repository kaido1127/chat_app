import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyDateUtil {
  static String getFormattedTime(
      {required BuildContext context, required String time}) {
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(date).format(context);
  }

  static String getLastMessageTime(
      {required BuildContext context, required String time}) {
    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();
    if (now.day == sent.day && now.month == sent.month && now.year == sent.year)
      return TimeOfDay.fromDateTime(sent).format(context);
    else
      return '${sent.day} ${_getMonth(sent)}';
  }

  static String _getMonth(DateTime time) {
    return 'Tháng ${time.month}';
  }

  static String getLastActiveTime(
      {required BuildContext context, required String lastActive}) {
    final int i = int.tryParse(lastActive) ?? -1;
    if (i == -1) return '';
    DateTime now = DateTime.now();
    DateTime time = DateTime.fromMillisecondsSinceEpoch(i);
    String formatTime = TimeOfDay.fromDateTime(time).format(context);
    if (time.day == now.day && time.month == now.month && now.year == time.year)
      return 'Online $formatTime hôm nay';
    return 'Online ${time.day} ${_getMonth(time)} ${time.year} $formatTime';
  }
  static String getCreatedTime(
      {required BuildContext context, required String created}) {
    final int i = int.tryParse(created) ?? -1;
    if (i == -1) return '';
    DateTime now = DateTime.now();
    DateTime time = DateTime.fromMillisecondsSinceEpoch(i);
    String formatTime = TimeOfDay.fromDateTime(time).format(context);
    if (time.day == now.day && time.month == now.month && now.year == time.year)
      return 'Tham gia hôm nay';
    return 'Tham gia ${time.day} ${_getMonth(time)} ${time.year} ';
  }
  static String getTime(
      {required BuildContext context, required String ftime}) {
    final int i = int.tryParse(ftime) ?? -1;
    if (i == -1) return '';
    DateTime now = DateTime.now();
    DateTime time = DateTime.fromMillisecondsSinceEpoch(i);
    String formatTime = TimeOfDay.fromDateTime(time).format(context);
    if (time.day == now.day && time.month == now.month && now.year == time.year)
      return formatTime;
    return '$formatTime ${time.day} ${_getMonth(time)} ${time.year} ';
  }
}
