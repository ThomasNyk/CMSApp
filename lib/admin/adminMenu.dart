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
late Future tokenListFuture;
Map amounts = {};


Future<List<dynamic>> getPlayerListFuture(String playerId) async {
  List<dynamic> response = await jsonDecodeFutureList(webRequest(true, "/adminPlayerList", {"id": playerId}));
  //return Future.value(response);
  return Future.value(response);
}
Future<List<dynamic>> getTokenListFuture(String playerId) async {
  List<dynamic> response = await jsonDecodeFutureList(webRequest(true, "/getTokens", {"playerId": playerId}));
  //log(response.toString());
  return Future.value(response);
}

class _AdminMenuState extends State<AdminMenu> {


  @override
  void initState() {
    super.initState();
    tokenListFuture = getTokenListFuture(widget.playerId);
  }


  @override
  Widget build(BuildContext context) {
    //log(amounts.toString());
    if(onlyOnceAdmin) {
      onlyOnceAdmin = false;
      playerListFuture = getPlayerListFuture(widget.playerId);
    }

    List<Widget Function(Function setState, BuildContext context, String playerId)> tabs = [
      playerList,
      tokenGenerator,
      tokenList,
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin"),
      ),
      body: tabs[selectedTab](setState, context, widget.playerId),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.amber,
        currentIndex: selectedTab,
        onTap: (value) {
          setState(() {
            //log(value.toString());
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
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on_outlined),
            label: "Token List",
          )
        ],
      ),
    );
  }
}

Widget playerList(Function setState, BuildContext context, String playerId) {
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
                //log(playerListSnapshot.toString());
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

Widget tokenGenerator(Function setState, BuildContext context, String playerId) {
  return FutureBuilder(
    future: gameDataFuture,
    builder: (BuildContext context, AsyncSnapshot gameDataSnapshot) {
      if(gameDataSnapshot.connectionState != ConnectionState.done) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              Text("Loading gameData")
            ],
          ),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
          child: Column(
              children: getTokenGenerators(gameDataSnapshot.data, setState, playerId),
          ),
        );
      }
    },
  );
}

List<Widget> getTokenGenerators(Map? gameData, Function setState, String playerId) {
  if(gameData == null || gameData["ResList"] == null) return [];
  List<Widget> output = [];

  for(int i = 0; i < gameData["ResList"].length; i++) {
    if(gameData["ResList"][i]["Type"] == 0) continue;
    amounts[i.toString()] ??= 0;
    output.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () async {
              setState(() {
                amounts[i.toString()] -= 1;
              });
            },
            icon: const Icon(Icons.remove)
          ),
          Text('${gameData["ResList"][i]["Name"]}: ${amounts[i.toString()]}'),
          Row(
            children: [
              IconButton(
                  onPressed: () async {
                    setState(() {
                      amounts[i.toString()] += 1;
                    });
                  },
                  icon: const Icon(Icons.add)
              ),
              IconButton(
                  onPressed: () async {
                    Map requestObj = {
                      "playerId": playerId,
                      "UID": gameData["ResList"][i]["UID"],
                      "Amount": amounts[i.toString()],
                      "Name": gameData["ResList"][i]["Name"],
                    };
                    Map response = await jsonDecodeFutureMap(webRequest(true, "/generateToken", requestObj));
                    if(response["statusCode"] == 200) {
                      showToast("Generated");
                    } else {
                      showToast("Failed");
                    }
                    showToast("Saved");

                    setState(() {

                    });
                  },
                  icon: const Icon(Icons.save)
              ),
            ],
          )
        ],
      )
    );
  }
  return output;
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

Widget tokenList(Function setState, BuildContext context, String playerId) {
  return Padding(
    padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
    child: FutureBuilder(
      future: tokenListFuture,
      builder: (BuildContext context, AsyncSnapshot tokenListSnapshot) {
        if(tokenListSnapshot.connectionState != ConnectionState.done) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                Text("Loading token list"),
              ],
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.only(left: 0, top: 10, right: 0),
            child: FutureBuilder(
              future: gameDataFuture,
              builder: (BuildContext context, AsyncSnapshot gameDataSnapshot) {
                if(gameDataSnapshot.connectionState != ConnectionState.done) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CircularProgressIndicator(),
                        Text("Loading gameData")
                      ],
                    ),
                  );
                } else {
                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        tokenListFuture = getTokenListFuture(playerId);
                      });
                    },
                    child: ListView.builder(
                        itemCount: tokenListSnapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          //Map? resObj = getObjectByUID(gameDataSnapshot.data, tokenListSnapshot.data[index]["UID"]);
                          return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(tokenListSnapshot.data[index]["Name"], style: const TextStyle(fontSize: 20),),
                                        Text(tokenListSnapshot.data[index]["TokenAmount"].toString(), style: const TextStyle(fontSize: 20))
                                      ],
                                    ),
                                    Text(tokenListSnapshot.data[index]["UID"])
                                  ],
                                ),
                              )
                          );
                        }
                    ),
                  );
                }
              },
            ),
          );
        }
      },
    )
  );
}