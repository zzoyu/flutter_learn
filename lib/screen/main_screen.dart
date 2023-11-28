import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<dynamic> busList = [];

  @override
  void initState() {
    super.initState();

    getStopInfo();

    // interval 10 sec
    Timer.periodic(const Duration(seconds: 10), (timer) {
      getStopInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🚌우리집 근처 버스정류장🚏'),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          double remainingTime =
              (busList[index]['arrival']['buses'][0]['remainingTime'] / 60);
          return ListTile(
              key: Key(index.toString()),
              tileColor: remainingTime < 2
                  ? Color.fromARGB(
                      (255 * (2 - remainingTime)).toInt(), 255, 0, 0)
                  : Colors.white,
              leading: const Icon(Icons.directions_bus),
              title: Text(busList[index]['name']),
              subtitle: Text(
                  '${remainingTime < 2 ? '곧 도착' : '${double.parse(remainingTime.toStringAsFixed(1))}분 후 도착'}    ${busList[index]['arrival']['buses'][0]['remainingStop']} 정거장 남음'),
              trailing:
                  Text('${busList[index]['arrival']['buses'][0]['plateNo']}번'));
        },
        itemCount: busList.length,
      ),
    );
  }

  Future getStopInfo() async {
    String originalUrl = Uri.encodeComponent(
        "https://map.naver.com/p/api/pubtrans/realtime/bus/arrivals?stopId=102056");
    String url = 'https://corsproxy.io/?$originalUrl';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
      response.statusCode == 200
          ? setState(() {
              busList = json.decode(response.body);
            })
          : throw Exception('Failed to load data');
    } catch (error) {
      print(error);
    }
  }
}
