import 'dart:developer';

import 'package:flutter/material.dart';

import 'Buy Menu/buyAbilities.dart';
import 'Buy Menu/raceInfo.dart';
import 'main.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const SizedBox(
            height: 55.0,
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
                Map? localCharacter = getObjectByAttribute(snapshot.data["characters"], selectedCharacter, "name");
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
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: makeDrawerButtons(snapshotGame.data, localCharacter, context)
                      );
                    }
                  }
                );
              }
            }
          ),
        ],
      ),
    );
  }
}

List<Function> drawerTabs = [
  RaceInfo.new,
  BuyAbilities.new,
];

List<Widget> makeDrawerButtons(Map gameData, Map localCharacter, context) {
  List<Widget> output = [
    createButton(context, gameData, localCharacter, "Race Info", 0)
  ];
  if(gameData["abilities"] != null && gameData["abilities"].length > 0) {
    output.add(createButton(context, gameData, localCharacter, "Abilities", 1));
  }
  return output;
}

Widget createButton(BuildContext context, Map gameData, Map localCharacter, String buttonText, drawerTabsIndex) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 0.0),
    child: TextButton(
      style: TextButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.zero),
        )
      ),
      onPressed: () => {
        log(drawerTabsIndex.toString()),
        Navigator.push(context, MaterialPageRoute(builder: (context) => drawerTabs[drawerTabsIndex](character: localCharacter, gameData: gameData))),
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