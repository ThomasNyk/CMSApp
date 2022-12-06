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
            builder: (BuildContext context, AsyncSnapshot snapshotGame) {
              if(snapshotGame.connectionState != ConnectionState.done) {
                return Center(
                  child: Column(
                    children: const [
                      CircularProgressIndicator(),
                      Text("Loading Game Data")
                    ],
                  ),
                );
              } else {
                log("snapShotGame ConnectionState is: ${snapshotGame.connectionState.toString()} and does it have data?: ${snapshotGame.hasData}");
                //log("Tab");
                //log(snapshotGame.data.toString());
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: buildAbilityWidgetList(snapshot.data, snapshotGame.data),
                );
              }
            }
        );
      }
    }
  );
}

List<Widget> buildAbilityWidgetList(localPlayerData, localGameInfo) {
  //log(localPlayerData.toString());
  //log(localGameInfo.toString());
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
  Map? localCharacter = getObjectByAttribute(localPlayerData["characters"], selectedCharacter, "id");
  //log(localCharacter.toString());
  if(localCharacter == null) {
    widgets.add(const Text("Could not find Character for ability list building process"));
    return widgets;
  }
  if(localCharacter["abilities"] == null || localCharacter["abilities"].length < 1) {
    widgets.add(const Card(
      child: Text("No abilities yet, buy some in the burgermenu at the top"),
    ));
    return widgets;
  }
  for(int i = 0; i < localCharacter["abilities"].length; i++) {
    //log(localGameInfo.toString());
    //log(localCharacter["abilities"][i]);
    Map? abilityObj = getObjectByUID(localGameInfo, localCharacter["abilities"][i]);
    if(abilityObj == null){
       widgets.add(const Card(
         child: Center(
           child: Text("Could not access Ability"),
         ),
       ));
       return widgets;
    }
    widgets.add(Card(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                    child: Text(
                      abilityObj["Name"].toString(),
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                    child: Column(
                      children: buildAffectedStatsColumn(localGameInfo, abilityObj),
                    ),
                  )
                ],
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  child: Text(abilityObj["Description"]),
                ),
              ),

            ],
          ),
        )
      );
  }
  return widgets;
}

List<Widget> buildAffectedStatsColumn(gameInfo ,abilityObj) {
  List<Widget> output = [];
  for(int i = 0; i < abilityObj['AffectedResources'].length; i++) {
    output.add(Text('${getObjectByUID(gameInfo, abilityObj["AffectedResources"][i]["UID"])!["Name"]}: ${abilityObj["affectedResources"][i]["Amount"].toString()}'),);
  }
  return output;
}