import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project/toDoListPage.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late CalendarFormat _calendarController;
  DateTime _focusedDay = DateTime.now();
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendario')
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget> [
            TableCalendar(
              calendarFormat: CalendarFormat.month,
              focusedDay: _focusedDay,
              firstDay: DateTime(2000),
              lastDay: DateTime(2050),
              onFormatChanged: (format) {
                setState(() {

                });
              },
              onDaySelected: (selectedDay, focusedDay) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ToDoListPage(selectedDate: selectedDay),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
