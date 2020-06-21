import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Album> fetchAlbum() async {
  final response =
  await http.post('https://prediction-weather-app.herokuapp.com/predict/');

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Album.fromJson(json.decode(response.body));
//    return json.decode(response.body);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class Album {
  final String city;
  final String country;
  final String ip;

  final String temperature;
  final String success;
  final String today;

  Album({this.city, this.country, this.ip, this.temperature, this.success, this.today});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      city: json['city'],
      country: json['country'],
      ip: json['ip'],
      temperature: json['temperature'].toString(),
      success: json['success'].toString(),
      today: json['today']
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
  Future<Album> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Fetch Data Example'),
        ),
        body: Center(
          child: FutureBuilder<Album>(
            future: futureAlbum,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
//                return Text(snapshot.data.ip);
                return Center(
                  child: Column(
                    children: <Widget>[
                      Text(snapshot.data.city),
                      Text(snapshot.data.country),
//                      Text(snapshot.data.ip),
                      Text(snapshot.data.today),
                      Text(snapshot.data.temperature),
//                      Text(snapshot.data.success),
                      ],
                )
                );
//                return new ListView.builder(
//                  itemCount: values.length,
//                  itemBuilder: (BuildContext context, int index) {
//                    String key = values.keys.elementAt(index);
//                    return new Column(
//                      children: <Widget>[
//                        new ListTile(
//                          title: new Text("$key"),
//                          subtitle: new Text("${values[key]}"),
//                        ),
//                        new Divider(
//                          height: 2.0,
//                        ),
//                      ],
//                    );
//                  },
//                );
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
