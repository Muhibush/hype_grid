import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/foundation.dart';
import 'package:hype_grid/model/hype_event.dart';
import 'package:url_launcher/url_launcher.dart';

class CalendarService {
  static Future<void> addEventToCalendar(HypeEvent event) async {
    final title = event.title;
    final description =
        'Sport: ${event.sport}\nWatch on: ${event.broadcastChannel}\nHype Score: ${event.hypeScore}';
    final location = event.broadcastChannel;
    final startDate = event.startTime;
    final endDate = event.startTime.add(Duration(minutes: event.durationMinutes));

    if (kIsWeb) {
      await _launchGoogleCalendarWeb(
        title,
        description,
        location,
        startDate,
        endDate,
      );
      return;
    }

    final Event calendarEvent = Event(
      title: title,
      description: description,
      location: location,
      startDate: startDate,
      endDate: endDate,
      iosParams: const IOSParams(
        reminder: Duration(minutes: 30),
      ),
      androidParams: const AndroidParams(
        emailInvites: [],
      ),
    );

    try {
      await Add2Calendar.addEvent2Cal(calendarEvent);
    } catch (e) {
      debugPrint('Error adding to calendar: $e');
    }
  }

  static Future<void> _launchGoogleCalendarWeb(
    String title,
    String description,
    String location,
    DateTime start,
    DateTime end,
  ) async {
    final startStr = _formatDateTimeForUrl(start.toUtc());
    final endStr = _formatDateTimeForUrl(end.toUtc());

    final url = Uri.parse(
      'https://www.google.com/calendar/render'
      '?action=TEMPLATE'
      '&text=${Uri.encodeComponent(title)}'
      '&dates=$startStr/$endStr'
      '&details=${Uri.encodeComponent(description)}'
      '&location=${Uri.encodeComponent(location)}',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  static String _formatDateTimeForUrl(DateTime dt) {
    return '${dt.toIso8601String().replaceAll(RegExp(r'[:-]'), '').split('.').first}Z';
  }
}
