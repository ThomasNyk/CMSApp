import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:cms_for_real/Buy%20Menu/buyList.dart';
import 'package:cms_for_real/setup/createCharacter.dart';
import 'package:cms_for_real/setup/createPlayer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'Buy Menu/confirmBuy.dart';
import 'loginPage.dart';
import 'overviewPage/Tabs/abilitiesTab.dart';
import 'overviewPage/Tabs/backstoryTab.dart';
import 'overviewPage/Tabs/careerTab.dart';
import 'overviewPage/navbar.dart';
import 'overviewPage/Tabs/overviewTab.dart';
import 'drawer.dart';
import 'overviewPage/Tabs/raceTab.dart';


const online = true;

const ip = online ? '192.38.10.90:22115' : '127.0.0.1:3000';

//Navigator key used for navigating between pages
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
const storage = FlutterSecureStorage();


String selectedCharacter = "";

//Completers are created so we can create futures that can be completed later
Completer<Map?> _playerDataCompleter = Completer();
Completer<Map?> _gameDataCompleter = Completer();
Completer<Map?> _compiledCharacterCompleter = Completer();

//Like promises in JS
Future<Map?> playerDataFuture = _playerDataCompleter.future;
Future<Map?> gameDataFuture = _gameDataCompleter.future;
Future<Map?> compiledCharacterFuture = _compiledCharacterCompleter.future;

//Since the bottonNavBar is dynamically genenerated a map is used to map an index(bottonNavBarIndex) to an index in an array of constructor-tearoff
Map tabIndexToNameMap = {
  0: 0,
};

//Used to carry id between pages. Not always necessary
class idCarrier {
  final String id;

  idCarrier(this.id);
}

//Used to carry gameDataFuture between pages. Not always necessary
class gameDataFutureCarrier {
  final String id;
  final Future gameDataFuture;

  gameDataFutureCarrier(this.id, this.gameDataFuture);
}

//Start of app
void main() {
  runApp(const MyApp());
  storage.read(key: "selectedCharacter").then((value) => selectedCharacter = value ?? "");
  //log("asdasdasdlkm" + selectedCharacter);
}

//Fetches gamedata and completed the _gameDataCompleter
void fetchGameData() async {
  Map gameData = await jsonDecodeFutureMap(webRequest(true, "/getGameData", {}));
  _gameDataCompleter.complete(gameData);
}

//Not ideal but some functions like populateSideBar needs to be called later. There are surely better solutions. DO NOT TOUCH
void delayed(Function function, argument, delayMs) async {
  await Future.delayed(Duration(milliseconds: delayMs));
  function(argument);
}

//I don't remember why this is necessary
Future<Map?> delayedNavigator(String routeName, dynamic arguments, int delayMs) async {
  await Future.delayed(Duration(milliseconds: delayMs));
  //log(routeName);
  return Future.value(await navigatorKey.currentState!.pushNamed(routeName, arguments: arguments));
}
/*
//Populates the sidebar with buttons d
void populateSidebar (playerData) async {
  var LocalplayerData = await playerData;
  sidebarStream.stream.drain();
  List<String> output = [];
  for(int i = 0; i < (LocalplayerData["characters"] as List).length; i++) {
    log(LocalplayerData["characters"][i]["name"].toString());
    output.add(LocalplayerData["characters"][i]["name"]);
  }
  sidebarStream.add(output);
}
*/

//Gets PlayerData
Future<Map?> getPlayerDataFuture(playerId) async {
  Object requestObj = {
    "id": playerId,
  };
  return Future.value(jsonDecodeFutureMap(webRequest(true, 'client/cms/playerData', requestObj)));
}

//Makes a general webrequest
Future<http.Response> webRequest(bool post, String destination, Object? requestObj) async {
  var url = Uri.http(ip, destination);
  var parsedObj = jsonEncode(requestObj);
  if(post) {
    if(requestObj == null) {
      return Future.error("Require object on post method");
    }
      return http.post(url, body: parsedObj);
  } else {
    return http.get(url);
  }
  /*
  if(response.statusCode != 200) {
    return Future.error("http request failed: ${response.statusCode}");
  } else {
      if(post) {
        return Future.value(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        return Future.value(response);
      }
  }
   */
}


Future<Map> jsonDecodeFutureMap(Future<http.Response> response) async {
  log((await response).toString());
  return jsonDecode(utf8.decode((await response).bodyBytes));
}
Future<List<dynamic>> jsonDecodeFutureList(Future<http.Response> response) async {
  //log((await response).toString());
  return jsonDecode(utf8.decode((await response).bodyBytes));
}


/*
Future<dynamic> webRequest(bool post, String destination, Object? requestObj) async {
  var url = Uri.http(ip, destination);
  var response;
  var parsedObj = jsonEncode(requestObj);
  if(post) {
    if(requestObj == null) {
      return Future.error("Require object on post method");
    }
    try {
      response = await http.post(url, body: parsedObj);
    } catch (e) {
      return Future.error(e.toString());
    }
  } else {
    try {
      response = await http.post(url, body: parsedObj);
    } catch (e) {
      return Future.error(e.toString());
    }
    /*
    response = await http.get(url).onError((error, stackTrace) {
      return Future.error(error.toString());
    });
     */
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
*/

//Shows the popup messages called toasts
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

//Home page state. SetState function from StateFullWidget class generates a new MyHomePageState
class _MyHomePageState extends State<MyHomePage> {

  List<Widget Function(BuildContext context, Function mainSetState, {String? listName})> tabs = [
    OverviewTab,
    AbilitiesTab,
    BackstoryTab,
    CareerTab,
    RaceTab,
    RaceTab,
    AbilitiesTab,
  ];

  @override
  Widget build(BuildContext context) {



    getOnlineData(gameDataFuture);
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    String? listName = getListName(tabIndexToNameMap[currentIndex]);
    //Returns a scaffold. Main screen widget that supports drawer, appbar, body, bottomNavigationBar and more.
    return Scaffold(
      onDrawerChanged: (isOpened) {
        //delayed(populateSidebar, playerDataFuture, 10);
      },
      drawer: MyDrawer(playerDataFuture: playerDataFuture, gameDataFuture: gameDataFuture, mainSetState: setState,),
      appBar: AppBar(
        title: FutureBuilder(
          future: playerDataFuture,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            //log(snapshot.toString());
            if(!snapshot.hasData) {
              return const Text("Loading");
            } else {
              return getCharacterDropdown(snapshot, setState, context);
            }
          },
        ),
      ),
      //The array tab that return a tab dependent on currentIndex(from bottomBar) translated by tabIndexToNameMap
      body: tabs[tabIndexToNameMap[currentIndex]](context, setState, listName: listName),
      bottomNavigationBar: FutureBuilder(
        //Dynamically gets tabs as all tabs are not always shown
        future: getTabsFromData(selectedCharacter),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          //Futurebuilder creates new snapshots when its future is changed. This means we can change what Futurebuilder returns based on a future
          if(!snapshot.hasData) {
            return const Text("Loading...");
          } else {
            return FutureBuilder(
                future: playerDataFuture,
                builder: (BuildContext context, AsyncSnapshot snapshotTwo) {
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
                              //Setstate creates a new state of MyHomePageState
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
                            "Nothing to show, acquire some stuff"
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
  
  //Gets all futures from server. Opens LoginScreen if necessary
  bool onlyOnce = false;
  void getOnlineData(Future gameDataFuture) async {
    if(onlyOnce) {
      return;
    }
    onlyOnce = true;
    getPlayerId().then((id) async {
      id ??= await openLoginPage();

      bool gotData = false;
      while(!gotData) {
        Completer continueCompleter = Completer();
        Future continueLoop = continueCompleter.future;
        getPlayerDataFuture(id).then((playerData) async {
          gotData = true;
          
          while (playerData == null || playerData.isEmpty ||
              playerData["playerInfo"] == null) {
            playerData ??= {};
            playerData["playerInfo"] =
            //opens createPlayerPage if no playerData exists
            (await navigatorKey.currentState!.pushNamed('/createPlayer', arguments: idCarrier(id!)));
          }
          //opens createCharacterPage if no characterData exists
          while(playerData["characters"] == null) {
            playerData["characters"] = [(await navigatorKey.currentState!.pushNamed('/createCharacter', arguments: gameDataFutureCarrier(id!, gameDataFuture)))];
            selectedCharacter = playerData["characters"][playerData["characters"].length - 1]["id"].toString();
            storage.write(key: "selectedCharacter", value: selectedCharacter);
            playerDataFuture = getPlayerDataFuture(playerData["playerInfo"]["id"]);
          }
          //Gets GameData
          gameDataFuture.then((gameData) async {
            if(getObjectByAttribute(playerData!["characters"], selectedCharacter, "id") == null) selectedCharacter = playerData["characters"][0]["id"];
            compiledCharacterFuture = getCompiledCharacterFuture(playerData["playerInfo"]["id"], selectedCharacter);
          });
          //Completes playerDataFuture
          setState(() {
            _playerDataCompleter.complete(playerData);
          });
          continueCompleter.complete(true);
        })
        .catchError((e) {
          continueCompleter.complete(false);
        });
        await continueLoop;
      }
    });
    fetchGameData();

    onlyOnce = true;
  }
  
  
  String? getListName(int tabIndexToNameMap) {
    switch (tabIndexToNameMap) {
      case 4:
        return "RacList";
      case 5:
        return "RelList";
      case 1:
        return "AbiList";
      case 6:
        return "IteList";
      default:
        return null;
    }
  }
}


bool needsTabs(localPlayerData) {
  Map? player = getObjectByAttribute(localPlayerData["characters"], selectedCharacter, "id");
  if(player == null) {
    return false;
  }
  if((player["abilities"] != null && player["abilities"].length > 0)|| player["backstory"] != "") {
    return true;
  }
  return false;
}

DropdownButton getCharacterDropdown (snapshot, Function _setState, BuildContext context) {
  List<DropdownMenuItem> DropdownItems = [];
  //log("getPlayerDropdown");
  //log(snapshot.data.toString());
  for(int i = 0; i < snapshot.data["characters"].length; i++) {
    //log("CreateDropDownMenuItem");
    //log(snapshot.data["characters"][i]["id"]);
    DropdownItems.add(DropdownMenuItem(
      value: snapshot.data["characters"][i]["id"],
      child: Text(snapshot.data["characters"][i]["name"],
      style: const TextStyle(color: Colors.black),),));
  }
  DropdownItems.add(DropdownMenuItem(
    value: "createCharacter",
    child: Row(
      children: const [
        Icon(Icons.add),
        Text("New Character", style: TextStyle(color: Colors.black),)
      ],
    ))
  );
  //log("Dropdown creation SelectedCharacter" + selectedCharacter);
  if(getObjectByAttribute(snapshot.data["characters"], selectedCharacter, "id") == null) selectedCharacter = snapshot.data["characters"][0]["id"];
  return DropdownButton(
    style: const TextStyle(),
    items: DropdownItems,
    value: selectedCharacter,
    isExpanded: true,
    underline: const SizedBox(),
    onChanged: (value) async {
      if (value == "createCharacter") {
        //log("Open createCharacter");
        await navigatorKey.currentState!.pushNamed('/createCharacter',
            arguments: gameDataFutureCarrier(
                snapshot.data["playerInfo"]["id"], gameDataFuture));
        playerDataFuture = getPlayerDataFuture(snapshot.data["playerInfo"]["id"]);
      } else {
        _setState(() {
          //log("Value:");
          //log(value.toString());
          value != null ? selectedCharacter = value : null;
          storage.write(key: "selectedCharacter", value: selectedCharacter);
          currentIndex = 0;
          compiledCharacterFuture = getCompiledCharacterFuture(snapshot.data["playerInfo"]["id"], selectedCharacter);
        });
      }
    });
}


Map? getObjectByAttribute(List arr, String target, String attribute) {
  //log("$arr\nName: $name\nAttribute: $attribute");
  for(int i = 0; i < arr.length; i++) {
    if(arr[i][attribute].toString() == target.toString()) {
      //log(arr[i].toString());
      return arr[i];
    }
  }
  log("Could not find object with given attribute: $target as $attribute\n ${arr.toString()}");
  return null;
}

//Future but can be completed multiple times.
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
      //Routes for navigating to pages
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(title: 'Flutter Demo Home Page'),
        '/login': (context) => const LoginPage(),
        '/createCharacter': (context) => const CreateCharacter(),
        '/createPlayer' : (context) => const CreatePlayer(),
        '/confirmBuy' : (context) => const ConfirmBuy(),
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

//Runs through character data and checks for affected resources and such. Runs every time a character webrequest has been made
Future<Map?> compileCharacterData(Map? character, Map gameData) async {
  //log(character.toString());
  character ??= {};
  List<String> toCheck = ["AbiList", "RacList", "ResList", "CarList"];
  for(String listName in toCheck) {
    if(character[listName] == null) continue;
    for(dynamic listItem in character[listName]) {
      Map? obj;
      if(listItem.runtimeType == String) {
        obj = getObjectByUID(gameData, listItem);
      } else {
        obj = getObjectByUID(gameData, listItem["UID"]);
      }
      if(obj != null) {
        if(obj["AffectedResources"] != null) {
          for(Map affected in obj["AffectedResources"]) {
            String UIDType =  affected["UID"].split("-/")[0];
            int? index = getObjectIndexByUID(character, affected["UID"]);

            if(character[UIDType] == null) character[UIDType] = [];

            if(index == null) {
              //showToast("Could not find ${affected["UID"]} in character");
              character[UIDType].add({"UID": affected["UID"], "Amount": affected["Amount"]});
            } else {
              character[UIDType][index]["Amount"] += affected["Amount"];
            }
          }
        }
      }


    }
  }
  return character;
}

Map? getObjectByUID(Map? mapToCheck, String uid) {
  String uidType = uid.split("-/")[0];
  if(mapToCheck== null) {
    return null;
  }
  if(mapToCheck[uidType] == null) {
    return null;
  }
  for(int i = 0; i < mapToCheck[uidType].length; i++) {
    if(mapToCheck[uidType][i]["UID"] == uid) {
      return mapToCheck[uidType][i];
    }
  }
  return null;
}

int? getObjectIndexByUID(Map? mapToCheck, String uid) {
  String uidType = uid.split("-/")[0];
  if(mapToCheck== null) {
    return null;
  }
  if(mapToCheck[uidType] == null) {
    return null;
  }
  for(int i = 0; i < mapToCheck[uidType].length; i++) {
    if(mapToCheck[uidType][i]["UID"] == uid) {
      return i;
    }
  }
  return null;
}