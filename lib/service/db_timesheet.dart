import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/employee.dart';
import '../model/timesheet.dart';

class DatabaseTimesheetService {

  // Déclaraction et Initialisation
  CollectionReference _timesheets = FirebaseFirestore.instance.collection('timesheets');

  Stream<List<TimeSheet>> get timesheets {
    Query queryTimeSheets = _timesheets.orderBy('arrivalTime', descending: true);
    return queryTimeSheets.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return TimeSheet(
          timesheetID: doc.id,
          employeeID: doc.get('employeeID'),
          arrivalTime: doc.get('arrivalTime'),
          departureTime: doc.get('departureTime'),
          timeGap: doc.get('timeGap'),
        );
      }).toList();
    });
  }

  // ajout d'un ticket dans la BDD
  Future<String> addTimesheetDB(TimeSheet timeSheet) async {
    DocumentReference docRef = await _timesheets.add({
      "employeeID":timeSheet.employeeID,
      "arrivalTime":timeSheet.arrivalTime,
      "departureTime":timeSheet.departureTime,
      "timeGap":timeSheet.timeGap,
    });
    return docRef.id;
  }

  Future<void> updateDocument(String? documentId, Map<String, dynamic> updatedData) async {
    try {
      await _timesheets.doc(documentId).update(updatedData);
      print('Document updated successfully!');
    } catch (e) {
      print('Error updating document: $e');
    }
  }

  Future<String> insertData(String code) {
    return addTimesheetDB(
        TimeSheet(
          employeeID: code,
          arrivalTime: Timestamp.now(),
          departureTime: Timestamp.now(),
          timeGap: 0,
        )
    );
  }

  Future<String> addOrUpdateTimeSheet(String employeeID) async {
    String checkState;
    // Check if there's an existing timesheet for the employee today
    QuerySnapshot existingSheets = await _timesheets.where('employeeID', isEqualTo: employeeID).get();

    if (existingSheets.docs.isEmpty) {
      // If no timesheet exists for today, create a new one
      await _timesheets.add(TimeSheet(
        employeeID: employeeID,
        arrivalTime: Timestamp.now(),
        departureTime: Timestamp.now(),
        timeGap: 0,
      ).toMap());
      checkState = "The check-in is well recorded";
    } else {
      // If timesheet exists, update the departure time and calculate time gap
      DocumentSnapshot sheet = existingSheets.docs.first;

      DateTime arrivalTime = (sheet.data() as Map)['arrivalTime'].toDate();
      DateTime departureTime = DateTime.now();
      int timeGap = departureTime.difference(arrivalTime).inMinutes;

      await _timesheets.doc(sheet.id).update({
        'departureTime': departureTime,
        'timeGap': timeGap,
      });
      checkState = "The document updated successfully";
    }
    return checkState;
  }
  /*
  howNotification(context, "Level 1");
                String currentNormalDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
                if((element.employeeID == code) && (DateFormat("yyyy-MM-dd").format(getNormalDate(element.arrivalTime)) == currentNormalDate)) {
                  Map<String, dynamic> updatedData = {
                    'departureTime': Timestamp.now(),
                    'timegap': '0',
                    // add more fields as needed
                  };
                  _dbTimesheet.updateDocument(element.timesheetID, updatedData);
                  showNotification(context, "Document updated successfully!");
                }else{
                  validEntry.then((result) {
                    if (result.isEmpty) {
                      validEntry = _dbTimesheet.addTimesheetDB(
                          TimeSheet(
                            employeeID: code,
                            arrivalTime: Timestamp.now(),
                            departureTime: Timestamp.now(),
                            timegap: 0,
                          )
                      );
                    }
                  });
                  showNotification(context, "Good morning!");
                }
  */

}
