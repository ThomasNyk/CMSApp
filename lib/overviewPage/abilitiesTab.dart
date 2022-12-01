import 'package:cms_for_real/main.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

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
    log(abilityObj.toString());
    abilityObj ??= {"description": "Could not find ability in GameData"};
    widgets.add(Card(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                    child: Text(
                      localCharacter["abilities"][i].toString(),
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                    child: Column(
                      children: buildAffectedStatsColumn(abilityObj),
                    ),
                  )
                ],
              ),
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

List<Widget> buildAffectedStatsColumn(abilityObj) {
  List<Widget> output = [];
  for(int i = 0; i < abilityObj['affectedStats'].length; i++) {
    output.add(Text('${abilityObj["affectedStats"][i]["name"].toString()}: ${abilityObj["affectedStats"][i]["value"].toString()}'),);
  }
  return output;
}