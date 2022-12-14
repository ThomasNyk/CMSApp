import 'dart:developer';
import 'package:cms_for_real/Buy%20Menu/buyList.dart';
import 'package:flutter/material.dart';
import '../../main.dart';

/*Layout Variables*/
const double imageHeight = 100;
const double padding = 5;

FutureBuilder OverviewTab(BuildContext context, Function mainSetState, {String? listName}) {
  return FutureBuilder(
    future: playerDataFuture,
    builder: (BuildContext context, AsyncSnapshot playerDataSnapshot) {
      if(playerDataSnapshot.connectionState == ConnectionState.waiting) {
        if(playerDataSnapshot.hasError) {
          return Center(
            child: Column(
              children: const [
                CircularProgressIndicator(),
                Text("Fetching player data..."),
                Text("Failed, trying again"),
                Text("Make sure internet is working")
              ],
            ),
          );
        } else {
          return Center(
            child: Column(
              children: const [
                CircularProgressIndicator(),
                Text("Fetching player data..."),
              ],
            ),
          );
        }
      } else if (playerDataSnapshot.connectionState != ConnectionState.done) {
          return Center(
            child: Column(
              children: const [
                CircularProgressIndicator(),
                Text("Fetching player data..."),
              ],
            ),
          );
        } else {
          return FutureBuilder(
            future: gameDataFuture,
            builder: (BuildContext context, AsyncSnapshot gameDataSnapshot) {
              if(gameDataSnapshot.connectionState != ConnectionState.done) {
                return Center(
                  child: Column(
                    children: const [
                      CircularProgressIndicator(),
                      Text("Fetching game data..."),
                    ],
                  ),
                );
              } else {
                return FutureBuilder(
                  future: compiledCharacterFuture,
                  builder: (BuildContext context, AsyncSnapshot characterSnapShot) {
                    if(characterSnapShot.connectionState != ConnectionState.done) {
                      return Center(
                        child: Column(
                          children: const [
                            CircularProgressIndicator(),
                            Text("Compiling Data..."),
                          ],
                        ),
                      );
                    } else {
                      if(characterSnapShot.data == null) {
                        //log("Null");
                        //log(characterSnapShot.toString());
                        return RefreshIndicator(
                            onRefresh: () async {
                              mainSetState(() {
                                playerDataFuture = getPlayerDataFuture(playerDataSnapshot.data["playerInfo"]["id"]);
                                compiledCharacterFuture = getCompiledCharacterFuture(playerDataSnapshot.data["playerInfo"]["id"], selectedCharacter);
                                //log(compiledCharacterFuture.toString());
                                showToast("Refreshed");
                              });
                            },
                            child: ListView(
                                children: const [
                                  Text("Failed to load data please refresh..."),
                                ],
                            ),
                        );

                      }
                      List<List<Map>> sections = getSections(characterSnapShot.data, gameDataSnapshot.data);
                      //log("Sections:");
                      //log(sections.toString());
                      //log("http://$ip/${characterSnapShot.data["image"]}");
                      return RefreshIndicator(
                        onRefresh: () async {
                          mainSetState(() {
                            playerDataFuture = getPlayerDataFuture(playerDataSnapshot.data["playerInfo"]["id"]);
                            compiledCharacterFuture = getCompiledCharacterFuture(playerDataSnapshot.data["playerInfo"]["id"], selectedCharacter);
                            showToast("Refreshed");
                          });
                        },
                        child: ListView(
                          children: [
                            GestureDetector(
                              onTap: (() {
                                showDialog(context: context, builder: (context) => AlertDialog(
                                  title: const Text("Oops"),
                                  content: const Text("Contrary to popular belief this is not meant to be a button"),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
                                  ],
                                ));
                              }),
                              child: Card(
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: padding, horizontal: padding),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            characterSnapShot.data.containsKey("image")
                                                ? Image.network(
                                              "http://$ip/${characterSnapShot.data["image"]}",
                                              height:
                                              imageHeight,
                                              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                                return const Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 50),
                                                  child: Text("Failed to load Image"),
                                                );
                                              },
                                            )
                                                : Image.network(
                                              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRYEBKhlYYZa4Saksn04meXChE44J1PU9BCZA&usqp=CAU",
                                              height: imageHeight,
                                              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                                return const Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 50),
                                                  child: Text("Failed to load Image"),
                                                );
                                              },
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: padding, horizontal: padding),
                                              child: FutureBuilder(
                                                future: gameDataFuture,
                                                builder: (BuildContext context, AsyncSnapshot gameInfoSnapshot) {
                                                  if(gameInfoSnapshot.connectionState != ConnectionState.done) {
                                                    return const Text("Loading GameInfo");
                                                  } else {
                                                    return Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: getStatsWidgets(sections[0], gameInfoSnapshot.data),
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            (sections.length > 1 && sections[1].isNotEmpty) ? Card(
                                child: Column(
                                  children: [
                                    const Text("XP"),
                                    Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 0.0),
                                        child: GridView.builder(
                                            physics: const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: sections[1].length,
                                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 2),
                                            itemBuilder: (BuildContext context, int index) {
                                              return Column(
                                                children: [
                                                  Card(
                                                    color: Colors.greenAccent,
                                                    shape: BeveledRectangleBorder(
                                                      borderRadius: BorderRadius.circular(20.0),
                                                    ),
                                                    semanticContainer: false,
                                                    child: GridTile(
                                                      child: Center(
                                                          child: Text(sections[1][index]['Amount'].toString(), textScaleFactor: 1.25)
                                                      ),
                                                    ),
                                                  ),
                                                  Center(
                                                    child: Text(sections[1][index]["Name"].toString(),),
                                                  ),
                                                ],
                                              );
                                            })
                                    ),
                                  ],
                                )
                            )
                            : Container(),
                            (sections.length > 2 && sections[2].isNotEmpty) ? Card(
                              child: Column(
                                children: [
                                  const Text("Valutas"),
                                  Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 0.0),
                                      child: GridView.builder(
                                          physics: const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: sections[2].length,
                                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            childAspectRatio: 1,
                                            crossAxisSpacing: 50,
                                          ),
                                          itemBuilder: (BuildContext context, int index) {
                                            return Column(
                                              children: [
                                                AspectRatio(
                                                  aspectRatio: 1.25 / 1,
                                                  child: Card(
                                                    color: Colors.yellow,
                                                    shape: BeveledRectangleBorder(
                                                      borderRadius: BorderRadius.circular(20.0),
                                                    ),
                                                    semanticContainer: true,
                                                    child: GridTile(
                                                      child: Center(
                                                          child: Text(sections[2][index]["Amount"].toString(), textScaleFactor: 1.5)
                                                      ), //just for testing, will fill with image later
                                                    ),
                                                  ),
                                                ),
                                                Center(
                                                  child: Text(sections[2][index]['Name'],),
                                                ),
                                              ],
                                            );
                                          })
                                  )
                                ],
                              ),
                            )
                            : Container(),
                            (sections.length > 3 && sections[3].isNotEmpty) ? Card(
                              child: Column(
                                children: [
                                  const Text("Miscellaneous"),
                                  Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 0.0),
                                      child: GridView.builder(
                                          physics: const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: sections[3].length,
                                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            childAspectRatio: 1,
                                            crossAxisSpacing: 50,
                                          ),
                                          itemBuilder: (BuildContext context, int index) {
                                            return Column(
                                              children: [
                                                AspectRatio(
                                                  aspectRatio: 1.25 / 1,
                                                  child: Card(
                                                    color: Colors.yellow,
                                                    shape: BeveledRectangleBorder(
                                                      borderRadius: BorderRadius.circular(20.0),
                                                    ),
                                                    semanticContainer: true,
                                                    child: GridTile(
                                                      child: Center(
                                                          child: Text(sections[3][index]["Amount"].toString(), textScaleFactor: 1.5)
                                                      ), //just for testing, will fill with image later
                                                    ),
                                                  ),
                                                ),
                                                Center(
                                                  child: Text(sections[3][index]['Name'],),
                                                ),
                                              ],
                                            );
                                          })
                                  )
                                ],
                              ),
                            )
                            : Container(),
                          ],
                        ),
                      );
                    }
                  },
                );
              }
            }
        );
      }
    },
  );
}

List<List<Map>> getSections(Map character, Map gameData) {
  List<List<Map>> output = [];
  //log("Sections");
  if(character["ResList"] == null) character["ResList"] = [];
  if(character["RacList"][0] != null) {
    output.add([{
      "RacList": ["${character["RacList"][0]}"]
    }]);
  }
  for(Map item in character["ResList"]) {
    //log(item.toString());
    Map? gameDataItem = getObjectByUID(gameData, item["UID"]);
    if(gameDataItem == null) {
      continue;
    }
    gameDataItem["Amount"] = item["Amount"];
    //log("Get Sections: ${gameDataItem["Type"].toString()} : ${output.length}");
    while(gameDataItem["Type"] >= output.length) {
      output.add([]);
    }
    output[gameDataItem["Type"]].add(gameDataItem);
  }
  return output;
}

List<Widget> getStatsWidgets(List<Map> elements, Map gameInfo) {
  //log("getStatsWidgets");
  //log(elements.toString());

  Map? raceObj = getObjectByUID(gameInfo, elements[0]["RacList"][0]);
  raceObj ??= {"Name": "Race not found"};


  if(elements.isEmpty) {
    return const [Text("No Stats")];
  }


  List<Widget> widgets = [Text('Race: ' + raceObj["Name"])];

  for(int i = 1; i < elements.length; i++) {
    //log(localCharacter["stats"].toString());
    widgets.add(Text("${elements[i]["Name"].toString().capitalize()}: ${elements[i]["Amount"]}"));
  }

  return widgets;
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}

