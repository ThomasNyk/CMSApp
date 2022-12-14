import 'dart:developer';

import 'package:cms_for_real/overviewPage/Tabs/abilitiesTab.dart';
import 'package:flutter/cupertino.dart';
import 'package:cms_for_real/main.dart';
import 'package:flutter/material.dart';

Widget CareerTab(BuildContext context, Function mainSetState, {String? listName}) {
  return FutureBuilder(
      future: compiledCharacterFuture,
      builder: (BuildContext context, AsyncSnapshot character) {
        //log(character.toString());
        if (character.connectionState != ConnectionState.done) {
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
          if (character.data == null) {
            return const Center(
              child: Text("Could not find Character"),
            );
          }
          return FutureBuilder(
              future: gameDataFuture,
              builder: (BuildContext context, AsyncSnapshot gameData) {
                if(gameData.connectionState != ConnectionState.done) {
                  return Center(
                    child: Column(
                      children: const [
                        CircularProgressIndicator(),
                        Text("Loading GameData")
                      ],
                    ),
                  );
                } else {
                  if(character.data["CarList"] == null || character.data["CarList"].isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Text("No Careers"),
                          Text("GET A JOB", style: TextStyle(fontSize: 30, color: Colors.amber),),
                          Text('From the "Acquire Menu" possibly?', style: TextStyle(color: Colors.black54),)
                        ],
                      ),
                    );
                  }
                  return Column(
                    children: buildCareerWidgetList(gameData.data, character.data),
                  );
                }
              }
          );
        }
      }
  );
}

List<Widget> buildCareerWidgetList(Map gameData, Map character) {
  List<Widget> output = [];
  //log(character.toString());
  //log(gameData.toString());
  for(int i = 0; i < character["CarList"].length; i++) {
    Map? career = getObjectByUID(gameData, character["CarList"][i]);
    if(career == null) {
      output.add(Text("Unfound career: ${character["CarList"][i]["UID"]}"));
    } else {
      output.add(careerWidget(career, gameData));
    }

  }
  return output;
}

Widget careerWidget(Map career, Map gameData) {
  return Card(
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
              child: Text(
                career["Name"].toString(),
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
              child: Column(
                children: buildAffectedStatsColumn(gameData, career),
              ),
            )
          ],
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            child: Text(career["Description"]),
          ),
        ),
      ],
    ),
  );
}