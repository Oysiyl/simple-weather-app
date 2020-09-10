import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Weather> fetchWeather() async {
  final response =
  await http.post('https://weather-app-288315.uc.r.appspot.com/predict/');

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Weather.fromJson(json.decode(response.body));
//    return json.decode(response.body);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load response. Please, try again in a few sec');
  }
}

class PredictTemperature {
  final Map<String, dynamic> oneday;
  final Map<String, dynamic> sevendays;
  final Map<String, dynamic> tendays;

  PredictTemperature({this.oneday, this.sevendays, this.tendays});
  factory PredictTemperature.fromJson(Map<String, dynamic> json){
    return PredictTemperature(
        oneday: json['1_day'],
        sevendays: json['7_days'],
        tendays: json['10_days'],
    );
  }
}

class Weather {
  final String city;
  final String country;
  final String ip;
  final String temperature;
  final String success;
  final String today;
  PredictTemperature predicttemperature;
  Weather({this.city, this.country, this.ip, this.temperature,
           this.success, this.today, this.predicttemperature});

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      city: json['city'],
      country: json['country'],
      ip: json['ip'],
      temperature: json['temperature'].toString(),
      success: json['success'].toString(),
      today: json['today'],
      predicttemperature: PredictTemperature.fromJson(json['predict_temp']),
    );
  }
}

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<Weather> futureWeather;

  @override
  void initState() {
    super.initState();
    futureWeather = fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Info',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Weather Info'),
        ),
        body: Center(
          child: FutureBuilder<Weather>(
            future: futureWeather,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
//                return Text(snapshot.data.ip);
                var _results = {'one day': snapshot.data.predicttemperature.oneday,
                                'seven days': snapshot.data.predicttemperature.sevendays,
                                'ten days': snapshot.data.predicttemperature.tendays};
                return Center(
                  child: Column(
                    children: <Widget>[
                      Text(snapshot.data.city),
                      Text(snapshot.data.country),
//                      Text(snapshot.data.ip),
                      Text(snapshot.data.today),
                      Text(snapshot.data.temperature),
//                      Text(snapshot.data.success),
                      Container(height: 400, width: 200, child: ListView.builder(
                        itemCount: _results.length,
                        itemBuilder: (BuildContext context, int index) {
                          String key = _results.keys.elementAt(index);
                          return new Column(
                            children: <Widget>[
                              new ListTile(
                                title: new Text("$key"),
                                subtitle: new Text("${_results[key]}"),
                              ),
                              new Divider(
                                height: 2.0,
                              ),
                            ],
                          );
                        },
                      ))
                      ],
                )
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              // By default, show a loading spinner.
              return CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
