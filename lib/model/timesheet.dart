import 'package:cloud_firestore/cloud_firestore.dart';

class TimeSheet {
  String? timesheetID, employeeID;
  Timestamp? arrivalTime, departureTime;
  int? timeGap;

  TimeSheet({this.timesheetID,
      this.employeeID,
      this.arrivalTime,
      this.departureTime,
      this.timeGap
  });

  Map<String, dynamic> toMap() {
    return {
      'employeeID': employeeID,
      'arrivalTime': arrivalTime,
      'departureTime': departureTime,
      'timeGap': timeGap,
    };
  }
}
