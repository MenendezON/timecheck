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
          timegap: doc.get('timegap'),
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
      "timegap":timeSheet.timegap,
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


}
