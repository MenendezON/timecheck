import 'package:flutter/material.dart';
import 'package:timecheck/service/db_employee.dart';

import '../../model/employee.dart';
class EmployeesScreen extends StatefulWidget {
  @override
  _EmployeesScreenState createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  late Stream<List<Employee>> _employeesStream;
  TextEditingController _searchController = TextEditingController();
DatabaseEmployeeService dbEmployee = DatabaseEmployeeService();
  @override
  void initState() {
    super.initState();
    _employeesStream = dbEmployee.getEmployees();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _employeesStream = dbEmployee.getEmployees();
                    });
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _employeesStream = dbEmployee.searchEmployees(value);
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Employee>>(
              stream: _employeesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No employees found.'));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    Employee employee = snapshot.data![index];
                    return ListTile(
                      title: Text('${employee.firstName} ${employee.lastName}'),
                      subtitle: Text('${employee.email}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
