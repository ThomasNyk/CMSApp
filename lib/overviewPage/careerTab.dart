import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:cms_for_real/main.dart';
import 'package:flutter/material.dart';

Widget CareerTab() {
  return FutureBuilder(
      future: compiledCharacterFuture,
      builder: (BuildContext context, AsyncSnapshot character) {
        if (!character.hasData) {
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
  for(int i = 0; i < character["careers"].length; i++) {
    Map? career = getObjectByUID(gameData, character["careers"][i]);
    if(career == null) {
      output.add(Text("Unfound career: ${character["careers"][i]["UID"]}"));
    } else {
      output.add(careerWidget(career));
    }

  }
  return output;
}

Widget careerWidget(Map career) {
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
                children: const [Text("ok")],
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