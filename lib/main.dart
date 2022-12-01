import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'loginPage.dart';
import 'overviewPage/abilitiesTab.dart';
import 'overviewPage/backstoryTab.dart';
import 'overviewPage/navbar.dart';
import 'overviewPage/overviewTab.dart';
import 'drawer.dart';
import 'overviewPage/raceTab.dart';

const ip = '192.168.0.139:8000';//'192.168.59.179:8000';//

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
const storage = FlutterSecureStorage();

String selectedCharacter = "Jeff";

Completer _playerDataCompleter = Completer();
Future playerDataFuture = _playerDataCompleter.future;

Completer _gameDataCompleter = Completer();
Future gameDataFuture = _gameDataCompleter.future;

Map tabIndexToNameMap = {
  0: 0
};

void main() {
  runApp(const MyApp());
  getPlayerId().then((id) async => {
    if(id == null) {
      id = await openLoginPage(),
    },
    fetchPlayerData(id).then((playerData) => {
      _playerDataCompleter.complete(playerData),
    })
    .catchError((e) => {
      showToast(e),
    })
  });
  fetchGameData()
  .catchError((e) => {
    showToast(e),
  });
}

Future<void> fetchGameData() async {
  http.Response gameData = await webRequest(false, "gameinfo.json", null);
  _gameDataCompleter.complete(jsonDecode(utf8.decode(gameData.bodyBytes)));
  return Future.value();
}

void delayed(function, argument, delayMs) async {
  await Future.delayed(Duration(milliseconds: delayMs));
  function(argument);
}

void populateSidebar (playerData) async {
  var LocalplayerData = await playerData;
  sidebarStream.stream.drain();
  List<String> output = [];
  for(int i = 0; i < (LocalplayerData["characters"] as List).length; i++) {
    output.add(LocalplayerData["characters"][i]["name"]);
  }
  sidebarStream.add(output);
}

Future<dynamic> fetchPlayerData(playerId) async {
  Object requestObj = {
    "id": playerId,
  };

  return await webRequest(true, 'client/cms/playerData', requestObj);
}

Future<dynamic> webRequest(bool post, String destination, Object? requestObj) async {
  var url = Uri.http(ip, destination);
  var response;
  var parsedObj = jsonEncode(requestObj);
  if(post) {
    if(requestObj == null) {
      return Future.error("Require object on post method");
    }
    response = await http.post(url, body: parsedObj);
  } else {
    response = await http.get(url);
  }
  if(response.statusCode != 200) {
    return Future.error("http request failed: ${response.statusCode}");
  } else {
      if(post) {
        return Future.value(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        return Future.value(response);
      }
  }
}

void showToast(text) {
  Fluttertoast.showToast(
      msg: text.toString(),
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
  );
}

Future<String> openLoginPage() async{
  Map<String, dynamic> loginData = jsonDecode((await navigatorKey.currentState!.pushNamed('/login')).toString());
  //log(loginData['id']);

  if(loginData['rememberMe']) {
    await storage.write(key: "id", value: loginData["id"]);
    showToast("Saved Login");
  }
  return Future.value(loginData['id']);
}

Future<String?> getPlayerId() async {
  String? playerId = await storage.read(key: "id");
  return Future.value(playerId);
}

class _MyHomePageState extends State<MyHomePage> {

  List<Widget Function()> tabs = [
    OverviewTab,
    AbilitiesTab,
    BackstoryTab,
  ];

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      onDrawerChanged: (isOpened) {
        delayed(populateSidebar, playerDataFuture, 10);
      },
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: FutureBuilder(
          future: playerDataFuture,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if(!snapshot.hasData) {
              return const Text("Loading");
            } else {
              return getPlayerDropdown(snapshot, setState);
            }
          },
        ),
      ),
      body: tabs[tabIndexToNameMap[currentIndex]](),
      bottomNavigationBar: FutureBuilder(
        future: getTabsFromData(playerDataFuture, selectedCharacter),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(!snapshot.hasData) {
            return const Text("Loading...");
          } else {
            return FutureBuilder(
                future: playerDataFuture,
                builder: (BuildContext context, AsyncSnapshot snapshotTwo) {
                  //log(snapshotTwo.toString());
                  if(!snapshotTwo.hasData) {
                    return const Text("Loading");
                  } else {
                    if(needsTabs(snapshotTwo.data)) {
                      return BottomNavigationBar(
                          type: BottomNavigationBarType.fixed,
                          selectedItemColor: Colors.amber[800],
                          backgroundColor: Colors.black54,
                          currentIndex: currentIndex,
                          onTap: (index) {
                            if(mounted) {
                              setState(() {
                                currentIndex = index;
                              });
                            } else {
                              log("not mounted");
                            }
                          },
                          items: snapshot.data);
                    }
                    return const BottomAppBar(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Text(
                            textAlign: TextAlign.center,
                            "Nothing to show"
                        ),
                      ),
                    );
                  }
                }
            );
          }
        },
      ),
    );
  }
}

bool needsTabs(localPlayerData) {
  Map? player = getObjectByAttribute(localPlayerData["characters"], selectedCharacter, "name");
  if(player == null) {
    return false;
  }
  if((player["abilities"] != null && player["abilities"].length > 0) || player["backstory"] != "") {
    return true;
  }
  return false;
}

DropdownButton getPlayerDropdown (snapshot, _setState) {
  List<DropdownMenuItem> items = [];
  //log(snapshot.data.toString());
  for(int i = 0; i < snapshot.data["characters"].length; i++) {
    items.add(DropdownMenuItem(value: snapshot.data["characters"][i]["name"],child: Text(snapshot.data["characters"][i]["name"], style: const TextStyle(color: Colors.black),),));
  }
  return DropdownButton(
    style: const TextStyle(),
    items: items,
    value: selectedCharacter,
    isExpanded: true,
    underline: const SizedBox(),
    onChanged: (value) => _setState(() => {
      selectedCharacter = value,
      currentIndex = 0,
    }),
  );
}


Map? getObjectByAttribute(arr, name, attribute) {
  for(int i = 0; i < arr.length; i++) {
    if(arr[i][attribute].toString() == name.toString()) {
      //log(playerData["characters"][i].toString());
      return arr[i];
    }
  }
  return null;
}

StreamController<List<String>> sidebarStream = StreamController<List<String>>.broadcast();

class sideBarItem extends StatelessWidget {
  final data;
  const sideBarItem({
    Key? key,
    this.data,
  }) : super(key: key);

// data.dateTimeUpdated.split('T').first,
  @override
  Widget build(BuildContext context) {
    //log(data.toString());
    return Center(
      child: Text(data),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.grey,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(title: 'Flutter Demo Home Page'),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}