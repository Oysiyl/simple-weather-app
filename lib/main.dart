import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:math';
import 'package:charts_flutter/src/text_element.dart' as TextElement;
import 'package:charts_flutter/src/text_style.dart' as style;

class PopulationData {
  String date;
  int temp;
  charts.Color barColor;
  PopulationData({
    @required this.date,
    @required this.temp,
    @required this.barColor
  });
}

class PopulationData2 {
  String hour;
  int temp;
  charts.Color barColor;
  PopulationData2({
    @required this.hour,
    @required this.temp,
    @required this.barColor
  });
}

_getSeriesData(data) {
  List<PopulationData> data2 = [];
  for (String key in data.keys) {
    data2.add(PopulationData(
        date: key,
        temp: data[key],
        barColor: charts.ColorUtil.fromDartColor(Colors.lightBlue)));
  }
  List<charts.Series<PopulationData, String>> series = [
    charts.Series(
        id: "Population",
        data: data2,
        domainFn: (PopulationData series, _) => series.date,
        measureFn: (PopulationData series, _) => series.temp,
        colorFn: (PopulationData series, _) => series.barColor
    )
  ];
  return series;
}

_getSeriesData2(data) {
  List<PopulationData2> data2 = [];
  int index = 0;
  for (String key in data.keys) {
    key = index.toString() + "_hour";
    index = index + 1;
    data2.add(PopulationData2(
        hour: key,
        temp: data[key],
        barColor: charts.ColorUtil.fromDartColor(Colors.lightBlue)));
  }
  List<charts.Series<PopulationData2, String>> series = [
    charts.Series(
        id: "Population",
        data: data2,
        domainFn: (PopulationData2 series, _) => series.hour,
        measureFn: (PopulationData2 series, _) => series.temp,
        colorFn: (PopulationData2 series, _) => series.barColor
    )
  ];
  return series;
}

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
  final Map<String, dynamic> hourtemp;
  Weather({this.city, this.country, this.ip, this.temperature,
           this.success, this.today, this.predicttemperature, this.hourtemp});

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      city: json['city'],
      country: json['country'],
      ip: json['ip'],
      temperature: json['temperature'].toString(),
      success: json['success'].toString(),
      today: json['today'],
      hourtemp: json['hour_temp'],
      predicttemperature: PredictTemperature.fromJson(json['predict_temp']),
    );
  }
}

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  final List data;
  static String selected_day;
  static String selected_hour;
  MyApp({Key key, this.data}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState(this.data);
}

class _MyAppState extends State<MyApp> {
  final List data;
  static String selected_day;
  static String selected_hour;
  Future<Weather> futureWeather;
  _MyAppState(this.data);
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
                                'ten days': snapshot.data.predicttemperature.tendays,
                                'hour temp': snapshot.data.hourtemp};
                return Center(
                  child: Column(
                    children: <Widget>[
                      Text(snapshot.data.city),
                      Text(snapshot.data.country),
//                      Text(snapshot.data.ip),
                      Text(snapshot.data.today),
                      Text(snapshot.data.temperature),
//                      Text(snapshot.data.success),
//                       Container(height: 400, width: 200, child: ListView.builder(
//                         itemCount: _results.length,
//                         itemBuilder: (BuildContext context, int index) {
//                           String key = _results.keys.elementAt(index);
//                           return new Column(
//                             children: <Widget>[
//                               new ListTile(
//                                 title: new Text("$key"),
//                                 subtitle: new Text("${_results[key]}"),
//                               ),
//                               new Divider(
//                                 height: 2.0,
//                               ),
//                             ],
//                           );
//                         },
//                       )),
                      Container(
                        height: 260,
                        padding: EdgeInsets.all(10),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Column(
                              children: <Widget>[
                                Text(
                                  "Predicted temperature for the next 10 days",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                                SizedBox(height: 10,),
                                Expanded(
                                  child: charts.BarChart(
                                    _getSeriesData(_results['ten days']),
                                    selectionModels: [
                                      charts.SelectionModelConfig(
                                          changedListener: (charts.SelectionModel model) {
                                            if(model.hasDatumSelection)
                                              selected_day = model.selectedSeries[0].measureFn(model.selectedDatum[0].index).toString();
                                          }
                                      )
                                    ],
                                    behaviors: [
                                      charts.LinePointHighlighter(
                                          symbolRenderer: CustomCircleSymbolRenderer())
                                    ],
                                    animate: true,
                                    domainAxis: charts.OrdinalAxisSpec(
                                        renderSpec: charts.SmallTickRendererSpec(labelRotation: 60)
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 260,
                        padding: EdgeInsets.all(10),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Column(
                              children: <Widget>[
                                Text(
                                  "Temperatures for each hour for the current day",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                                SizedBox(height: 10,),
                                Expanded(
                                  child: charts.BarChart(
                                    _getSeriesData2(_results['hour temp']),
                                    selectionModels: [
                                      charts.SelectionModelConfig(
                                          changedListener: (charts.SelectionModel model) {
                                            if(model.hasDatumSelection)
                                              selected_hour = model.selectedSeries[0].measureFn(model.selectedDatum[0].index).toString();
                                          }
                                      )
                                    ],
                                    behaviors: [
                                      charts.LinePointHighlighter(
                                          symbolRenderer: CustomCircleSymbolRenderer2())
                                    ],
                                    animate: true,
                                    domainAxis: charts.OrdinalAxisSpec(
                                        renderSpec: charts.SmallTickRendererSpec(labelRotation: 60)
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
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

class CustomCircleSymbolRenderer extends charts.CircleSymbolRenderer {
  @override
  void paint(charts.ChartCanvas canvas, Rectangle<num> bounds, {List<int> dashPattern, charts.Color fillColor, charts.FillPatternType fillPattern, charts.Color strokeColor, double strokeWidthPx}) {
    super.paint(canvas, bounds, dashPattern: dashPattern, fillColor: fillColor,fillPattern: fillPattern, strokeColor: strokeColor, strokeWidthPx: strokeWidthPx);
    canvas.drawRect(
        Rectangle(bounds.left - 5, bounds.top - 30, bounds.width + 10, bounds.height + 10),
        fill: charts.Color.white
    );
    var textStyle = style.TextStyle();
    textStyle.color = charts.Color.black;
    textStyle.fontSize = 15;
    canvas.drawText(

        TextElement.TextElement(_MyAppState.selected_day, style: textStyle),
        (bounds.left).round(),
        (bounds.top - 28).round()
    );
  }
}

class CustomCircleSymbolRenderer2 extends charts.CircleSymbolRenderer {
  @override
  void paint(charts.ChartCanvas canvas, Rectangle<num> bounds, {List<int> dashPattern, charts.Color fillColor, charts.FillPatternType fillPattern, charts.Color strokeColor, double strokeWidthPx}) {
    super.paint(canvas, bounds, dashPattern: dashPattern, fillColor: fillColor,fillPattern: fillPattern, strokeColor: strokeColor, strokeWidthPx: strokeWidthPx);
    canvas.drawRect(
        Rectangle(bounds.left - 5, bounds.top - 30, bounds.width + 10, bounds.height + 10),
        fill: charts.Color.white
    );
    var textStyle = style.TextStyle();
    textStyle.color = charts.Color.black;
    textStyle.fontSize = 15;
    canvas.drawText(

        TextElement.TextElement(_MyAppState.selected_hour, style: textStyle),
        (bounds.left).round(),
        (bounds.top - 28).round()
    );
  }
}