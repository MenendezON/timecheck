import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:timecheck/model/timesheet.dart';
import 'package:timecheck/service/db_timesheet.dart';
import 'package:timecheck/service/showSnackBar.dart';

import '../model/employee.dart';
import '../service/db_employee.dart';
import 'HomeScreen.dart';
import 'admin/AdminScreen.dart';

class QRCodeScreen extends StatefulWidget {
  const QRCodeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late DatabaseTimesheetService _dbTimesheet;
  DatabaseEmployeeService dbemployee = DatabaseEmployeeService();

  Future<String> validEntry = Future.value('');
  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),

          if (result != null)

            if (describeEnum(result!.format) == "qrcode")
              FutureBuilder(
                future: redirectToScreen(result!.code),
                builder: (context, snapshot) {
                  // Handle loading or errors if needed
                  return Container();
                },
              )

        ],
      ),
    );
  }

  Future<void> redirectToScreen(String? code) async {

    //await Future.delayed(const Duration(seconds: 0));
    if(await isExist(dbemployee, code!)) {
      dbemployee.getEmployeeById(code).listen((employee) {
        if (employee != null) {
          if (employee.status == 'admin') {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const AdminScreen()),
            );
          } else {
            showNotification(context, "Level 0");
            _dbTimesheet = DatabaseTimesheetService();
            validEntry.then((result) {
              if (result.isEmpty) {
                validEntry = _dbTimesheet.insertData(code);
              }
            });
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        }
      });
    }else{
      print('Employee not found');
    }
  }

  DateTime getNormalDate(timestamp){
    DateTime date = DateTime.fromMillisecondsSinceEpoch(
      timestamp!.seconds * 1000 + timestamp!.nanoseconds ~/ 1000000,
    );
    return date;
  }

  Future<bool> isExist(DatabaseEmployeeService dbemp, String employeeID) async {
    if(await dbemp.doesEmployeeExist(employeeID)) {
      return true;
    } else {
      return false;
    }
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 225.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      cameraFacing: CameraFacing.front,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
