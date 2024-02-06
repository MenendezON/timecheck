import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/employee.dart';

class DatabaseEmployeeService {

  // Déclaraction et Initialisation
  CollectionReference _employees = FirebaseFirestore.instance.collection('employees');

  // suppression de la voiture
  //Future<void> deleteEmployee(String employeeID) => _employees.doc(employeeID).delete();

  // Récuperation de toutes les voitures en temps réel
  Stream<List<Employee>> get employees {
    Query queryEmployees = _employees.orderBy('lastName', descending: true);
    return queryEmployees.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Employee(
          employeeID: doc.id,
          firstName: doc.get('firstName'),
          lastName: doc.get('lastName'),
          email: doc.get('email'),
          avatar: doc.get('avatar'),
          status: doc.get('status'),
        );
      }).toList();
    });
  }

  Stream<Employee?> getEmployeeById(String employeeId) {
    DocumentReference employeeRef = _employees.doc(employeeId);

    return employeeRef.snapshots().map((snapshot) {
      if (snapshot.exists) {
        return Employee(
          employeeID: snapshot.id,
          firstName: snapshot.get('firstName'),
          lastName: snapshot.get('lastName'),
          email: snapshot.get('email'),
          avatar: snapshot.get('avatar'),
          status: snapshot.get('status'),
        );
      } else {
        // If the document doesn't exist, return null or handle accordingly
        return null;
      }
    });
  }


  Future<bool> doesEmployeeExist(String employeeID) async {
    // Get the document snapshot
    DocumentSnapshot snapshot = await _employees.doc(employeeID).get();
    // Check if the document exists
    return snapshot.exists;
  }
}