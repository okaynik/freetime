import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:time_machine/time_machine.dart';
import 'package:timetable/timetable.dart';
import 'group.dart';


List<List<DateTime>> listOfFreetime = [];
List<BasicEvent> listEvents = [];

List<BasicEvent> exampleEvents = [
BasicEvent(
           id: 0,
           title: 'Free time',
           color: Colors.deepPurple,
           start: LocalDate.today().at(LocalTime(13, 0, 0)),
           end: LocalDate.today().at(LocalTime(15, 0, 0)),
         ),
  BasicEvent(
    id: 1,
    title: 'Free time',
    color: Colors.deepPurple,
    start: LocalDate.today().add(Period(days: 1)).at(LocalTime(10, 0, 0)),
    end: LocalDate.today().add(Period(days: 1)).at(LocalTime(12, 0, 0)),
  ),
  BasicEvent(
    id: 2,
    title: 'Free time',
    color: Colors.deepPurple,
    start: LocalDate.today().add(Period(days: 1)).at(LocalTime(16, 0, 0)),
    end: LocalDate.today().add(Period(days: 1)).at(LocalTime(19, 0, 0)),
  ),
  BasicEvent(
    id: 3,
    title: 'Free time',
    color: Colors.deepPurple,
    start: LocalDate.today().add(Period(days: 2)).at(LocalTime(14, 0, 0)),
    end: LocalDate.today().add(Period(days: 2)).at(LocalTime(16, 0, 0)),
  ),
  BasicEvent(
    id: 4,
    title: 'Free time',
    color: Colors.deepPurple,
    start: LocalDate.today().add(Period(days: 3)).at(LocalTime(11, 0, 0)),
    end: LocalDate.today().add(Period(days: 3)).at(LocalTime(14, 0, 0)),
  ),
  BasicEvent(
    id: 5,
    title: 'Free time',
    color: Colors.deepPurple,
    start: LocalDate.today().add(Period(days: 4)).at(LocalTime(9, 0, 0)),
    end: LocalDate.today().add(Period(days: 4)).at(LocalTime(13, 0, 0)),
  ),
  BasicEvent(
    id: 6,
    title: 'Free time',
    color: Colors.deepPurple,
    start: LocalDate.today().add(Period(days: 5)).at(LocalTime(13, 0, 0)),
    end: LocalDate.today().add(Period(days: 5)).at(LocalTime(16, 0, 0)),
  ),



];

class TimetableExample extends StatefulWidget {
  @override
  _TimetableExampleState createState() => _TimetableExampleState();
}

class _TimetableExampleState extends State<TimetableExample> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  TimetableController<BasicEvent> _controller;

  @override
  void initState() {
    super.initState();

    _controller = TimetableController(
      // A basic EventProvider containing a single event:
      // Change to listEvents
       eventProvider: EventProvider.list(exampleEvents),
//         BasicEvent(
//           id: 0,
//           title: 'My Event',
//           color: Colors.deepPurple,
//           start: LocalDate.today().at(LocalTime(13, 0, 0)),
//           end: LocalDate.today().at(LocalTime(15, 0, 0)),
//         ),
//       ]),

      // For a demo of overlapping events, use this one instead:

      // Or even this short example using a Stream:
      // eventProvider: EventProvider.stream(
      //   eventGetter: (range) => Stream.periodic(
      //     Duration(milliseconds: 16),
      //     (i) {
      //       final start =
      //           LocalDate.today().atMidnight() + Period(minutes: i * 2);
      //       return [
      //         BasicEvent(
      //           id: 0,
      //           title: 'Event',
      //           color: Colors.blue,
      //           start: start,
      //           end: start + Period(hours: 5),
      //         ),
      //       ];
      //     },
      //   ),
      // ),

      // Other (optional) parameters:
      initialTimeRange: InitialTimeRange.range(
        startTime: LocalTime(8, 0, 0),
        endTime: LocalTime(20, 0, 0),
      ),
      initialDate: LocalDate.today(),
      visibleRange: VisibleRange.days(7),
      firstDayOfWeek: DayOfWeek.monday,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
//    if(loading) return CircularProgressIndicator();
    //getFreeTime(selectedUsers);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Time available'),
        backgroundColor: Colors.deepPurple,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.today),
            onPressed: () => _controller.animateToToday(),
            tooltip: 'Jump to today',
          ),
        ],
      ),
      body: Timetable<BasicEvent>(
        controller: _controller,
        theme: TimetableThemeData(
          primaryColor: Colors.deepPurple
        ),
        onEventBackgroundTap: (start, isAllDay) {
          _showSnackBar('Background tapped $start is all day event $isAllDay');
        },
        eventBuilder: (event) {
          return BasicEventWidget(
            event,
            onTap: () => _showSnackBar('Part-day event $event tapped'),
          );
        },
        allDayEventBuilder: (context, event, info) => BasicAllDayEventWidget(
          event,
          info: info,
          onTap: () => _showSnackBar('All-day event $event tapped'),
        ),
      ),
    );
  }

  void _showSnackBar(String content) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(content),
    ));
  }

}

// [[2021-01-12 07:30:00.000Z, 2021-01-12 08:45:00.000Z], [2021-01-12 09:15:00.000Z, 2021-01-12 10:30:00.000Z], [2021-01-12 11:00:00.000Z, 2021-01-12 12:15:00.000Z], [2021-01-12 12:45:00.000Z, 2021-01-12 14:00:00.000Z], [2021-01-12 14:00:00.000Z, 2021-01-12 15:30:00.000Z], [2021-01-13 12:45:00.000Z, 2021-01-13 14:00:00.000Z], [2021-01-13 14:00:00.000Z, 2021-01-13 15:30:00.000Z]]


