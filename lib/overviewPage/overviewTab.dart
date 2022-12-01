import 'dart:developer';

import 'package:flutter/material.dart';

import '../main.dart';

/*Layout Variables*/
const double imageHeight = 100;
const double padding = 5;

FutureBuilder OverviewTab() {
  return FutureBuilder(
      future: playerDataFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if(!snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                Text("Loading Data..."),
              ],
            ),
          );
        } else {
          Map? localCharacter = getObjectByAttribute(snapshot.data["characters"], selectedCharacter, "name");
          if(localCharacter == null) {
            return const Center(
              child: Text("Could not get find Character"),
            );
          }
          return FutureBuilder(
            future: compilePlayerData(snapshot.data, localCharacter),
            builder: (BuildContext context, AsyncSnapshot character) {
              if(!character.hasData) {
                return Center(
                  child: Column(
                    children: const [
                      CircularProgressIndicator(),
                      Text("Compiling Data..."),
                    ],
                  ),
                );
              } else {
                //log("asdasdkpasdlkasdkmlaklmasdklmadkalmsd" + character.data.toString());
                return ListView(
                  children: [
                    Card(
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: padding, horizontal: padding),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Image.network(
                                      character.data["image"],
                                      height: imageHeight,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: padding, horizontal: padding),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: getStatsWidgets(character),
                                        ),
                                    ),

                                  ],
                                ),
                              ],
                            ),
                          )
                      ),
                    ),
                    Card(
                      child: Column(
                        children: [
                          const Text("XP"),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 0.0),
                            child: GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: character.data["xpArr"].length,
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
                                              child: Text(character.data["xpArr"][index]["value"].toString(), textScaleFactor: 1.25)
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Text(character.data["xpArr"][index]['name'],),
                                      ),
                                    ],
                                  );
                                }),
                          ),
                        ],
                      )
                    ),
                    Card(
                      child: Column(
                        children: [
                          const Text("Valutas"),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 0.0),
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: character.data["valutas"].length,
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
                                              child: Text(character.data["valutas"][index]["value"].toString(), textScaleFactor: 1.5)
                                          ), //just for testing, will fill with image later
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Text(character.data["valutas"][index]['name'],),
                                    ),
                                  ],
                                );
                              }),
                          )
                        ],
                      ),
                    )
                  ],
                );
              }
            }
          );
        }
      }
  );
}

Future<Map> compilePlayerData(localPlayerData, character) async {
  Map compiledPlayerData = {};
  //Todo compile playerData
  return Future.value(character);
}

List<Widget> getStatsWidgets(character) {
  Map localCharacter = character.data;
  if((localCharacter["stats"] == null || localCharacter["stats"].length < 1) && localCharacter['race'] == null) {
    return const [Text("No Stats")];
  } else if(localCharacter["stats"] == null || localCharacter["stats"].length < 1) {
    return [Text('Race: ' +  localCharacter["race"])];
  }
  List<Widget> widgets = [Text('Race: ' +  localCharacter["race"])];
  for(int i = 0; i < localCharacter["stats"].length; i++) {
    //log(localCharacter["stats"].toString());
    widgets.add(Text(localCharacter["stats"][i]["name"] + ": " + localCharacter["stats"][i]["value"].toString()));
  }
  return widgets;
}