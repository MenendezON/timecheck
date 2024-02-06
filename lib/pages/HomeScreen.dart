import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timecheck/model/timesheet.dart';
import 'package:timecheck/pages/QRCodeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import 'package:timecheck/service/db_employee.dart';
import 'package:timecheck/service/db_timesheet.dart';
import 'package:weather/weather.dart';
import 'package:timecheck/service/constant.dart';

import '../model/employee.dart';
import '../service/showSnackBar.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final showMessage = "Bonjour Menendez NELSON";
  final WeatherFactory _wf = WeatherFactory(API_KEY);
  Weather? _weather;
  String currentTime = '';
  String currentDate = '';

  @override
  void initState() {
    super.initState();
    _wf.currentWeatherByCityName("Dakar").then((w) => {
      setState(() {
        _weather = w;
      })
    });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    updateCurrentTime();
  }

  void updateCurrentTime() {
    setState(() {
      currentTime = DateFormat("HH:mm:ss").format(DateTime.now());
      currentDate = DateFormat("dd MMMM yyyy").format(DateTime.now());
    });
    // Update the time every second
    Future.delayed(const Duration(seconds: 1), updateCurrentTime);
  }

  @override
  Widget build(BuildContext context) {
    final dim = MediaQuery.of(context).size;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: _buildUI(dim), // This trailing comma makes auto-formatting nicer for build methods.
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const QRCodeScreen(),
            ),
          );
        },
        tooltip: 'Scan your ID',
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }

  Widget _buildUI(dimension){
    final dim = dimension;
    if(_weather == null){
      return const Center(
        child: CircularProgressIndicator(
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(45.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: dim.width / 2,
            child: Column(
              children: [
                Container(
                  width: dim.width / 2,
                  height: 180,
                  decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.3),
                      borderRadius:
                      const BorderRadius.all(Radius.circular(10))),
                  child: Column(
                    children: [
                      Text(
                        currentTime,
                        style: const TextStyle(
                            fontSize: 80, color: Colors.white), //110
                      ),
                      Text(
                        currentDate,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Gap(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width: dim.width / 4.1,
                        height: 162,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius:
                          const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_weather?.areaName ?? "City not found", style: const TextStyle(fontSize: 50),),
                            Text(_weather?.country ?? "Country not found"),
                          ],
                        )
                    ),
                    Container(
                        width: dim.width / 4.1,
                        height: 162,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius:
                          const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage("http://openweathermap.org/img/wn/${_weather?.weatherIcon}@4x.png"),
                                    ),
                                  ),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("${_weather?.temperature?.celsius?.toStringAsFixed(0)}", style: const TextStyle(fontSize: 60),),
                                    const Text("° C", style: TextStyle(fontSize: 20),),
                                  ],
                                )
                              ],
                            ),
                            Text("${_weather?.weatherDescription}".toUpperCase() ?? "", style: const TextStyle(fontWeight: FontWeight.bold, ),),
                          ],
                        )
                    ),
                  ],
                ),
                const Gap(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: dim.width / 4.1,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius:
                        const BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text("Min: ${_weather?.tempMin?.celsius?.toStringAsFixed(0)}° C", style: const TextStyle(fontWeight: FontWeight.bold),),
                              Text("Max: ${_weather?.tempMax?.celsius?.toStringAsFixed(0)}° C", style: const TextStyle(fontWeight: FontWeight.bold),),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text("Wind: ${_weather?.windSpeed?.toStringAsFixed(1)}m/s", style: const TextStyle(fontWeight: FontWeight.bold),),
                              Text("Humidity: ${_weather?.humidity?.toStringAsFixed(0)}%", style: const TextStyle(fontWeight: FontWeight.bold),),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                        width: dim.width / 4.1,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius:
                          const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${_weather?.tempFeelsLike?.celsius?.toStringAsFixed(0)}", style: const TextStyle(fontSize: 60),),
                                const Text("° C", style: TextStyle(fontSize: 20),),
                              ],
                            ),
                            const Text('Temperature feel', style:TextStyle(fontWeight: FontWeight.bold))
                          ],
                        )
                    ),
                  ],
                )
              ],
            ),
          ),
          Container(
            width: dim.width / 2.5,
            decoration: const BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                  image: NetworkImage('https://scontent.fdkr5-1.fna.fbcdn.net/v/t1.6435-9/134063733_1803763243130749_4785379552723994461_n.png?_nc_cat=105&ccb=1-7&_nc_sid=be3454&_nc_eui2=AeGCUN3Zyb9USqMZKHxMNLorn8H4NeL-7z6fwfg14v7vPvQnVqFoW100TsKdlPiu08c&_nc_ohc=tdJ-yxxwbMQAX8aHGT4&_nc_ht=scontent.fdkr5-1.fna&oh=00_AfD6BiFnrzt3YSmbr27fpYZs36z4sFEU6timbK_s26BTbA&oe=65E263AD')
              ),
            ),
          ),
        ],
      ),
    );
  }



  void showTicketDialog(BuildContext context, content) async {
    showNotification(context, content);
  }
}
