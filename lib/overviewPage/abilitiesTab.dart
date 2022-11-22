import 'package:cms_for_real/main.dart';
import 'package:flutter/material.dart';

FutureBuilder AbilitiesTab() {
  return FutureBuilder(
    future: playerDataFuture,
    builder: (BuildContext context, AsyncSnapshot snapshot) {
      if(!snapshot.hasData) {
        return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              Text("Loading Player Data.."),
            ],
          );
      } else {
        return FutureBuilder(
          future: gameDataFuture,
          builder: (BuildContext context, AsyncSnapshot snapshotTwo) {
            if(!snapshotTwo.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  Text("Loading Game Data.."),
                ],
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: buildAbilityWidgetList(snapshot.data, snapshotTwo.data),
              );
            }
          },
        );
      }
    }
  );
}

List<Widget> buildAbilityWidgetList(localPlayerData, localGameInfo) {
  List<Widget> widgets= [const Center(
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 0.0),
      child: Text(
        "Your Abilities",
        style: TextStyle(
          fontSize: 30
        ),
      ),
    ),
  )];
  Map? localCharacter = getObjectByAttribute(localPlayerData["characters"], selectedCharacter, "name");
  if(localCharacter == null) {
    widgets.add(const Text("Could not find Character for ability list building"));
    return widgets;
  }
  if(localCharacter["abilities"] == null || localCharacter["abilities"].length < 1) {
    widgets.add(const Card(
      child: Text("No abilities yet, buy some in the burgermenu at the top"),
    ));
    return widgets;
  }
  for(int i = 0; i < localCharacter["abilities"].length; i++) {
    Map? abilityObj = getObjectByAttribute(localGameInfo["abilities"], localCharacter["abilities"][i], "name");
    abilityObj ??= {"description": "Could not find ability in GameData"};
    widgets.add(Card(
          child: Column(
            children: [
              Text(localCharacter["abilities"][i].toString()),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  child: Text(abilityObj["description"]),
                ),
              ),

            ],
          ),
        )
      );
  }
  return widgets;
}