import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Buy Menu/buyAbilities.dart';
import 'Buy Menu/raceInfo.dart';
import 'main.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const SizedBox(
            height: 80.0,
            child: DrawerHeader(
              decoration: BoxDecoration(color: Colors.grey),
              margin: EdgeInsets.all(0.0),
              padding: EdgeInsets.all(0.0),
              child: Center(
                child:  Center(
                  child: Text(
                    'Buy Menu',
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                ),
              ),
            ),
          ),
          FutureBuilder(
            future: playerDataFuture,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if(!snapshot.hasData) {
                return Center(
                  child: Column(
                    children: const [
                      CircularProgressIndicator(),
                      Text("Loading Player Data")
                    ],
                  ),
                );
              } else {
                Map? localCharacter = getObjectByAttribute(snapshot.data["characters"], selectedCharacter, "id");
                if(localCharacter == null) {
                  return const Text("Could not find character by the selected name");
                }
                return FutureBuilder(
                  future: gameDataFuture,
                  builder: (BuildContext context, AsyncSnapshot snapshotGame) {
                    if(!snapshotGame.hasData) {
                      return Center(
                        child: Column(
                          children: const [
                            CircularProgressIndicator(),
                            Text("Loading Player Data")
                          ],
                        ),
                      );
                    } else {
                      //log("Drawer");
                      //log(snapshotGame.data.toString());
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: makeDrawerButtons(snapshotGame.data, localCharacter, context, snapshot.data["playerInfo"]["id"])
                      );
                    }
                  }
                );
              }
            }
          ),
          logOutButton(context)
        ],
      ),
    );
  }
}

List<Function> drawerTabs = [
  RaceInfo.new,
  BuyAbilities.new,
];

List<Widget> makeDrawerButtons(Map gameData, Map localCharacter, context, String playerId) {
  List<Widget> output = [
    createButton(context, gameData, localCharacter, "Rulebook", 0, playerId)
  ];
  //log(gameData["AbiList"].toString());
  if(gameData["AbiList"] != null && gameData["AbiList"].length > 0) {
    output.add(createButton(context, gameData, localCharacter, "Abilities", 1, playerId));
  }
  return output;
}

Widget logOutButton(context) {
  return Expanded(
    child: Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 0.0),
        child: TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.black12)
          ),
          onPressed: () => {
            showDialog(context: context, builder: (context) => AlertDialog(
              title: const Text("App has to close"),
              content: const Text("The app has to close now to ensure updated data for next person, this will be updated in a newer version"),
              actions: [
                TextButton(
                  onPressed: () => {
                    storage.delete(key: "id"),
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
                  },
                  child: const Text("OK")
                )
              ],),
            )
          },
          child: const Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: Text(
              "Log Out",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget createButton(BuildContext context, Map gameData, Map localCharacter, String buttonText, int drawerTabsIndex, String playerId) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 0.0),
    child: TextButton(
      style: TextButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(1)),
        )
      ),
      onPressed: () => {
        //log(drawerTabsIndex.toString()),
        Navigator.push(context, MaterialPageRoute(builder: (context) => drawerTabs[drawerTabsIndex](playerID: playerId, character: localCharacter, gameData: gameData))),
      },
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: Text(
            buttonText,
            style: const TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ),
    ),
  );
}