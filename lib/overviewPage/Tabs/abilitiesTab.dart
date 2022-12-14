import 'package:cms_for_real/main.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

FutureBuilder AbilitiesTab(BuildContext context, Function mainSetState, {String? listName}) {
  return FutureBuilder(
    future: compiledCharacterFuture,
    builder: (BuildContext context, AsyncSnapshot compiledDataSnapshot) {
      if(compiledDataSnapshot.connectionState != ConnectionState.done) {
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
                //log("snapShotGame ConnectionState is: ${snapshotGame.connectionState.toString()} and does it have data?: ${snapshotGame.hasData}");
                //log(snapshotGame.data.toString());
                return ListView(
                  //crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: buildAbilityWidgetList(compiledDataSnapshot.data, snapshotGame.data, listName),
                );
              }
            }
        );
      }
    }
  );
}

List<Widget> buildAbilityWidgetList(Map compiledCharacter, Map localGameInfo, String? listName) {
  //log(localPlayerData.toString());
  //log(localGameInfo.toString());
  listName ??= "AbiList";
  String prettyName = listName == "AbiList" ? "Abilities" : "Items";
  List<Widget> widgets= [Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 0.0),
      child: Text(
        "Your $prettyName",
        style: const TextStyle(
          fontSize: 30
        ),
      ),
    ),
  )];
  //log(localCharacter.toString());
  if(compiledCharacter == null) {
    widgets.add(const Text("Could not find Character for ability list building process"));
    return widgets;
  }
  if(compiledCharacter[listName] == null || compiledCharacter[listName].length < 1) {
    widgets.add(Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        child: Column(
          children: const [
            Text('No abilities yet, buy some in the "Acquire Menu" at the top'),
            Text("Or don't. What do I care?")
          ],
        ),
      ),
    ));
    return widgets;
  }
  for(int i = 0; i < compiledCharacter[listName].length; i++) {
    //log(localGameInfo.toString());
    //log(localCharacter["abilities"][i]);
    Map? abilityObj = getObjectByUID(localGameInfo, compiledCharacter[listName][i]);
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

List<Widget> buildAffectedStatsColumn(Map gameInfo, Map abilityObj) {
  List<Widget> output = [];
  for(int i = 0; i < abilityObj['AffectedResources'].length; i++) {
    //log(abilityObj["AffectedResources"][i]["UID"]);
    output.add(Text('${getObjectByUID(gameInfo, abilityObj["AffectedResources"][i]["UID"])!["Name"]}: ${abilityObj["AffectedResources"][i]["Amount"].toString()}'),);
  }
  return output;
}