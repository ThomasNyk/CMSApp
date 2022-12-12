import 'dart:developer';

import 'package:cms_for_real/main.dart';
import 'package:flutter/material.dart';

import 'adminPlayer.dart';

class AdminMenu extends StatefulWidget {
  final String playerId;
  final String characterId;
  final Map gameData;
  final Function mainSetState;
  final String listName;
  final String prettyName;
  const AdminMenu({Key? key, required this.playerId, required this.characterId, required this.gameData, required this.mainSetState, required this.listName, required this.prettyName}) : super(key: key);

  @override
  State<AdminMenu> createState() => _AdminMenuState();
}

int selectedTab = 0;
TextEditingController searchController = TextEditingController();
bool onlyOnceAdmin = true;
late Future playerListFuture;

Future<List<dynamic>> getPlayerListFuture(String playerId) async {
  List<dynamic> response = await webRequest(true, "/adminPlayerList", {"id": playerId});
  //return Future.value(response);
  return Future.value(response);
}

class _AdminMenuState extends State<AdminMenu> {

  @override
  Widget build(BuildContext context) {

    if(onlyOnceAdmin) {
      onlyOnceAdmin = false;
      playerListFuture = getPlayerListFuture(widget.playerId);
    }

    List<Widget Function(Function setState, BuildContext context)> tabs = [
      playerList,
      tokenGenerator,
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin"),
      ),
      body: tabs[selectedTab](setState, context),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.amber,
        currentIndex: selectedTab,
        onTap: (value) {
          setState(() {
            log(value.toString());
            selectedTab = value;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.accessibility),
            label: "Player list",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: "Token gen",
          )
        ],
      ),
    );
  }
}

Widget playerList(Function setState, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
    child: Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search)
          ),
          controller: searchController,
          maxLines: 1,
          onChanged: (value) {
            setState(() {
            });
          },
        ),
        Expanded(
          child: FutureBuilder(
            future: playerListFuture,
            builder: (BuildContext context, AsyncSnapshot playerListSnapshot) {
              if(playerListSnapshot.connectionState != ConnectionState.done) {
                return Center(
                  child: Column(
                    children: const [
                      CircularProgressIndicator(),
                      Text("Getting playerList"),
                    ],
                  ),
                );
              } else {
                log(playerListSnapshot.toString());
                List<Map> searched = getSearchComplyingPlayers(playerListSnapshot.data);
                return ListView.builder(
                  itemCount: searched.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if(index >= searched.length) {
                      if(searched.isEmpty) {
                        return const Center(
                          child: Text("No matches"),
                        );
                      }
                      return const Center(
                        child: Text("No more"),
                      );
                    }
                    return GestureDetector(
                      onTap: () async {
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => PlayerView(playerId: playerListSnapshot.data[index]["id"],)));
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                          child: Text(searched[index]["name"]),
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    )
  );
}

Widget tokenGenerator(Function setState, BuildContext context) {
  return Container(
    child: Text("asd"),
  );
}

List<Map> getSearchComplyingPlayers(List<dynamic> players) {
  List<Map> output = [];
  for(dynamic player in players) {
    if(player["name"].toLowerCase().contains(searchController.text.toLowerCase())) {
      output.add(player);
    }
  }
  return output;
}