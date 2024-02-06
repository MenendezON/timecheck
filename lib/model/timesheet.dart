import 'package:cloud_firestore/cloud_firestore.dart';

class TimeSheet {
  String? timesheetID, employeeID;
  Timestamp? arrivalTime, departureTime;
  int? timegap;

  TimeSheet({this.timesheetID,
      this.employeeID,
      this.arrivalTime,
      this.departureTime,
      this.timegap
  });
}
