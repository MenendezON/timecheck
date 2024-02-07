class Employee {
  String? avatar, email, firstName, lastName, employeeID, status;

  Employee({
    this.employeeID,
    this.avatar,
    this.email,
    this.firstName,
    this.lastName,
    this.status,
  });

  factory Employee.fromMap(String id, Map<String, dynamic> data) {
    return Employee(
      employeeID: id,
      firstName: data['firstName'],
      lastName: data['lastName'],
      avatar: data['avatar'],
      email: data['email'],
      status: data['status'],
    );
  }
}