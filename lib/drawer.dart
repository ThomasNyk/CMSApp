
import 'package:cms_for_real/Buy%20Menu/redeemToken.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Buy Menu/buyList.dart';
import 'Buy Menu/raceInfo.dart';
import 'admin/adminMenu.dart';
import 'main.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key, required Future this.playerDataFuture, required Future this.gameDataFuture, required this.mainSetState}) : super(key: key);
  final playerDataFuture;
  final gameDataFuture;
  final mainSetState;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(
              height: 56.0,
              child: DrawerHeader(
                decoration: BoxDecoration(color: Colors.grey),
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.all(0.0),
                child: Center(
                  child: Text(
                    'Acquire Menu',
                    style: TextStyle(
                      fontSize: 30,
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
                                children: makeDrawerButtons(snapshotGame.data, localCharacter, context, snapshot.data["playerInfo"]["id"], snapshot.data["playerInfo"]["isAdmin"], mainSetState)
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
      ),
    );
  }
}

List<Function> drawerTabs = [
  RaceInfo.new,
  BuyList.new,
  AdminMenu.new,
  RedeemToken.new,
];

List<Widget> makeDrawerButtons(Map gameData, Map localCharacter, context, String playerId, bool? isAdmin, Function mainSetState) {
  List<Widget> output = [
    //createButton(context, gameData, localCharacter, "Rulebook", 0, playerId, mainSetState)
  ];
  //log(gameData["AbiList"].toString());
  if(gameData["CarList"] != null && gameData["CarList"].isNotEmpty) {
    output.add(createButton(context, gameData, localCharacter, "Career", 1, playerId, "CarList", mainSetState));
  }
  if(gameData["RelList"] != null && gameData["RelList"].isNotEmpty) {
    output.add(createButton(context, gameData, localCharacter, "Religion", 1, playerId, "RelList", mainSetState));
  }
  if(gameData["AbiList"] != null && gameData["AbiList"].isNotEmpty) {
    output.add(createButton(context, gameData, localCharacter, "Abilities", 1, playerId, "AbiList", mainSetState));
  }
  if(gameData["IteList"] != null && gameData["IteList"].isNotEmpty) {
    output.add(createButton(context, gameData, localCharacter, "Item", 1, playerId, "IteList", mainSetState));
  }
  if(true) {
    output.add(createButton(context, gameData, localCharacter, "Redeem Token", 3, playerId, "tokens", mainSetState));
  }


  if(isAdmin != null && isAdmin == true) {
    output.add(createButton(context, gameData, localCharacter, "Admin Menu", 2, playerId, "", mainSetState));
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

Widget createButton(BuildContext context, Map gameData, Map localCharacter, String buttonText, int drawerTabsIndex, String playerId, String listName, Function mainSetState) {
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
        Navigator.push(context, MaterialPageRoute(builder: (context) => drawerTabs[drawerTabsIndex](
            playerId: playerId,
            characterId: localCharacter["id"],
            gameData: gameData,
            mainSetState: mainSetState,
            listName: listName,
            prettyName: buttonText))),
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