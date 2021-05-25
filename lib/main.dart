import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<Album>> fetchAlbum() async {
  final response =
  await http.get(Uri.http("universities.hipolabs.com", "/search", { "country" : "croatia" }), headers: {"Accept": "application/json"});

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    final jsonData = json.decode(response.body);
    List<Album> retVal = [];
    for (var oneItem in jsonData) {
      String country = oneItem['country'];
      List urls =  oneItem['web_pages'];
      String url = ""; //oneItem['web_pages'];
      for(var oneUrl in urls){
        url = oneUrl;
        break;
      }
      String name = oneItem['name'];
      Album myItem = new Album(name: name, country: country, url: url);
      print('country: $country, name: $name, url: $url');

      retVal.add(myItem);
    }
    return retVal;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class Album {
  final String name;
  final String country;
  final String url;

  Album({
    required this.name,
    required this.country,
    required this.url,
  });
}

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<Album>> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Popis sveučilišta',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Popis sveučilišta'),
        ),
        body: FutureBuilder<List<Album>>(
          future: futureAlbum,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemBuilder: (context,index){
                    return Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(snapshot.data![index].name),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(snapshot.data![index].country),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(snapshot.data![index].url),
                          )
                        ],
                      ),
                    );
                  }
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            // By default, show a loading spinner.
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}