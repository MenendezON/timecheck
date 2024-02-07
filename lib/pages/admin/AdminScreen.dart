import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timecheck/pages/admin/NewEmployeeForm.dart';
import 'package:timecheck/pages/admin/ListEmployee.dart';

import '../../model/employee.dart';

class AdminScreen extends StatefulWidget {

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    EmployeesScreen(),
    NewEmployeeForm(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employees'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Menu'),
            ),
            ListTile(
              title: Text('List of employees'),
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                  Navigator.pop(context); // Close the drawer
                });
              },
            ),
            ListTile(
              title: Text('Add a new employee'),
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                  Navigator.pop(context); // Close the drawer
                });
              },
            ),
          ],
        ),
      ),
      body:  _pages[_selectedIndex],
    );
  }
}


