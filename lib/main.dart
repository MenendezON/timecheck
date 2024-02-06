import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:timecheck/pages/HomeScreen.dart';
import 'package:timecheck/pages/QRCodeScreen.dart';
import 'package:timecheck/pages/admin/AdminScreen.dart';
import 'package:timecheck/service/db_employee.dart';

import 'model/employee.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    routes: {
      '/': (context) => const HomeScreen(),
      '/admin': (context) => const AdminScreen(),
      '/qrcode': (context) => const QRCodeScreen(),
    },
  )
  );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState(){
    super.initState();
  }

  Future<void> isExist(DatabaseEmployeeService dbemployee, String employeeID) async {
    if(await dbemployee.doesEmployeeExist(employeeID))
    print('yes it exists too');
    else
    print('employee did not found');
  }

  @override
  Widget build(BuildContext context) {
    DatabaseEmployeeService dbemployee = DatabaseEmployeeService();
    dbemployee.employees.listen((List<Employee> employees) {
      for (var element in employees) {
        print(element.employeeID);
      }
    });
    print("---------------");
    isExist(dbemployee, '8Qcr3lQNRmqPtKOvjQTT');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Toc toc'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '11',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
